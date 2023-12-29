-- Copyright (c) 2021-present Floating UI contributors
--!strict

local _Package = script.Parent.Parent
local _Packages = _Package.Parent

local _types = require(_Package.types)
local Promise = require(_Packages.Promise)
local _utils = require(_Packages["floating-ui-utils"])
local _detectOverflow = require(_Package.detectOverflow)

local Array = require(_Packages.Collections).Array
local detectOverflow = _detectOverflow.detectOverflow
local evaluate, getAlignment, getAlignmentSides, getOppositeAlignmentPlacement, getSide, ALL_PLACEMENTS, _merge, await =
	_utils.evaluate,
	_utils.getAlignment,
	_utils.getAlignmentSides,
	_utils.getOppositeAlignmentPlacement,
	_utils.getSide,
	_utils.placements,
	_utils.merge,
	_utils.await

type DetectOverflowOptions = _detectOverflow.DetectOverflowOptions

type Alignment = _types.Alignment
type Derivable<T> = _types.Derivable<T>
type Middleware = _types.Middleware
type Placement = _types.Placement

function getPlacementList(alignment: Alignment?, autoAlignment: boolean, allowedPlacements: { Placement })
	local allowedPlacementsSortedByAlignment = if alignment
		then Array.concat(
			{},
			Array.filter(allowedPlacements, function(placement)
				return getAlignment(placement) == alignment
			end),
			Array.filter(allowedPlacements, function(placement)
				return getAlignment(placement) ~= alignment
			end)
		)
		else Array.filter(allowedPlacements, function(placement)
			return getSide(placement) == placement
		end)

	return Array.filter(allowedPlacementsSortedByAlignment, function(placement)
		if alignment then
			return getAlignment(placement) == alignment
				or (if autoAlignment then getOppositeAlignmentPlacement(placement) ~= placement else false)
		end

		return true
	end)
end

export type AutoPlacementOptions = DetectOverflowOptions & {
	--[[
		The axis that runs along the alignment of the floating element. Determines
		whether to check for most space along this axis.
		@default false
	]]
	crossAxis: boolean?,

	--[[
		Choose placements with a particular alignment.
		@default undefined
	]]
	alignment: Alignment?,

	--[[
		Whether to choose placements with the opposite alignment if the preferred
    	alignment does not fit.
    	@default true
	]]
	autoAlignment: boolean?,

	--[[
		Which placements are allowed to be chosen. Placements must be within the
    	`alignment` option if explicitly set.
    	@default allPlacements (variable)
	]]
	allowedPlacements: { Placement }?,
}

--[[
	Optimizes the visibility of the floating element by choosing the placement
	that has the most space available automatically, without needing to specify a
	preferred placement. Alternative to `flip`.
	@see https://floating-ui.com/docs/autoPlacement
]]
local autoPlacement = function(options: (AutoPlacementOptions | Derivable<AutoPlacementOptions>)?): Middleware
	options = options or {}
	return {
		name = "autoPlacement",
		options = options,
		fn = function(state)
			local rects, middlewareData, placement, platform, elements =
				state.rects, state.middlewareData, state.placement, state.platform, state.elements

			local crossAxis, alignment, allowedPlacements, autoAlignment, detectOverflowOptions =
				nil, nil, nil, nil, nil
			do
				local evaluated = evaluate(options, state)
				local evaluatedClone = table.clone(evaluated)

				evaluatedClone.crossAxis, evaluatedClone.alignment, evaluatedClone.allowedPlacements, evaluatedClone.autoAlignment =
					nil, nil, nil, nil
				crossAxis, alignment, allowedPlacements, autoAlignment, detectOverflowOptions =
					evaluated.crossAxis or false,
					evaluated.alignment,
					evaluated.allowedPlacements or ALL_PLACEMENTS,
					evaluated.autoAlignment or true,
					evaluatedClone
			end

			local placements = if alignment ~= nil or allowedPlacements == ALL_PLACEMENTS
				then getPlacementList(alignment, autoAlignment, allowedPlacements)
				else allowedPlacements

			local overflow = await(detectOverflow(detectOverflowOptions))

			local currentIndex = if middlewareData.autoPlacement and middlewareData.autoPlacement.index
				then middlewareData.autoPlacement.index
				else 1
			local currentPlacement = placements[currentIndex]

			if currentPlacement == nil then
				return {}
			end

			local alignmentSides = getAlignmentSides(
				currentPlacement,
				rects,
				await(if platform.isRTL then platform.isRTL(elements.floating) else nil)
			)

			-- Make `computeCoords` start from the right place.
			if placement ~= currentPlacement then
				return {
					reset = {
						placement = placements[1],
					},
				}
			end

			local currentOverflows = {
				overflow[getSide(currentPlacement)],
				overflow[alignmentSides[1]],
				overflow[alignmentSides[2]],
			}

			local allOverflows = _merge(
				if middlewareData.autoPlacement and middlewareData.autoPlacement.overflows
					then middlewareData.autoPlacement.overflows
					else {},
				{ { placement = currentPlacement, overflows = currentOverflows } }
			)

			local nextPlacement = placements[currentIndex + 1]

			-- There are more placements to check.
			if nextPlacement then
				return {
					data = {
						index = currentIndex + 1,
						overflows = allOverflows,
					},
					reset = {
						placement = nextPlacement,
					},
				}
			end

			local placementsSortedByMostSpace = Array.map(allOverflows, function(d)
				local alignment = getAlignment(d.placement)
				return {
					d.placement,
					if alignment and crossAxis
						then Array.reduce(Array.slice(d.overflows, 0, 2), function(acc, v)
							return acc + v
						end, 0)
						else d.overflows[1],
				}
			end)

			local placementsThatFitOnEachSide = Array.filter(placementsSortedByMostSpace, function(d)
				return Array.every(Array.slice(d[3], 0, if getAlignment(d[1]) then 2 else 3), function(v)
					return v <= 0
				end)
			end)

			local resetPlacement = if placementsThatFitOnEachSide[1] and placementsThatFitOnEachSide[1][1]
				then placementsThatFitOnEachSide[1][1]
				else placementsSortedByMostSpace[1][1]

			if resetPlacement ~= placement then
				return {
					data = {
						index = currentIndex + 1,
						overflows = allOverflows,
					},
					reset = {
						placement = resetPlacement,
					},
				}
			end
		end,
	}
end

return {
	autoPlacement = autoPlacement,
	getPlacementList = getPlacementList,
}
