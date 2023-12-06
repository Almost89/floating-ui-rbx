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
local evaluate, getAlignmentSides, getExpandedPlacements, getOppositeAxisPlacements, getOppositePlacement, getSide, _merge, await =
	_utils.evaluate,
	_utils.getAlignmentSides,
	_utils.getExpandedPlacements,
	_utils.getOppositeAxisPlacements,
	_utils.getOppositePlacement,
	_utils.getSide,
	_utils.merge,
	_utils.await

type Promise<T...> = Promise.TypedPromise<T...>

type DetectOverflowOptions = _detectOverflow.DetectOverflowOptions

type Derivable<T> = _types.Derivable<T>
type Middleware = _types.Middleware
type Placement = _types.Placement

export type FlipOptions = DetectOverflowOptions & {
	--[[
		The axis that runs along the side of the floating element. Determines
    	whether overflow along this axis is checked to perform a flip.
    	@default true
	]]
	mainAxis: boolean?,
	--[[
		The axis that runs along the alignment of the floating element. Determines
    	whether overflow along this axis is checked to perform a flip.
    	@default true
	]]
	crossAxis: boolean?,
	--[[
		Placements to try sequentially if the preferred `placement` does not fit.
    	@default [oppositePlacement] (computed)
	]]
	fallbackPlacements: { Placement }?,
	--[[
		What strategy to use when no placements fit.
     	@default 'bestFit'
	]]
	fallbackStrategy: ("bestFit" | "initialPlacement")?,
	--[[
		Whether to allow fallback to the perpendicular axis of the preferred
    	placement, and if so, which side direction along the axis to prefer.
    	@default 'none' (disallow fallback)
	]]
	fallbackAxisSideDirection: ("none" | "start" | "end")?,
	--[[
		Whether to flip to placements with the opposite alignment if they fit
   		better.
    	@default true
	]]
	flipAlignment: boolean?,
}

--[[
	Optimizes the visibility of the floating element by flipping the `placement`
	in order to keep it in view when the preferred placement(s) will overflow the
	clipping boundary. Alternative to `autoPlacement`.
	@see https://floating-ui.com/docs/flip
]]
local flip = function(options: (FlipOptions | Derivable<FlipOptions>)?): Middleware
	options = options or {}
	return {
		name = "flip",
		options = options,
		fn = function(state)
			local placement, middlewareData, rects, initialPlacement, platform, elements =
				state.placement,
				state.middlewareData,
				state.rects,
				state.initialPlacement,
				state.platform,
				state.elements

			local detectOverflowOptions = nil
			local checkMainAxis, checkCrossAxis, specifiedFallbackPlacements, fallbackStrategy, fallbackAxisSideDirection, flipAlignment =
				nil, nil, nil, nil, nil, nil
			do
				local evaluated = evaluate(options, state)
				local evaluatedClone = table.clone(evaluated)

				checkMainAxis, checkCrossAxis, specifiedFallbackPlacements, fallbackStrategy, fallbackAxisSideDirection, flipAlignment =
					evaluated.mainAxis or true,
					evaluated.crossAxis or true,
					evaluated.fallbackPlacements,
					evaluated.fallbackStrategy or "bestFit",
					evaluated.fallbackAxisSideDirection or "none",
					evaluated.flipAlignment or true
				evaluatedClone.mainAxis, evaluatedClone.crossAxis, evaluatedClone.fallbackPlacements, evaluatedClone.fallbackStrategy, evaluatedClone.fallbackAxisSideDirection, evaluatedClone.flipAlignment =
					nil, nil, nil, nil, nil, nil
				detectOverflowOptions = evaluatedClone
			end

			-- If a reset by the arrow was caused due to an alignment offset being
			-- added, we should skip any logic now since `flip()` has already done its
			-- work.
			-- https://github.com/floating-ui/floating-ui/issues/2549#issuecomment-1719601643
			if middlewareData.arrow and middlewareData.arrow.alignmentOffset then
				return {}
			end

			local side = getSide(placement :: any)
			local isBasePlacement = getSide(initialPlacement :: any) == initialPlacement
			local rtl = await(if platform.isRTL then platform.isRTL(elements.floating) else nil)

			local fallbackPlacements = specifiedFallbackPlacements
				or (
					if isBasePlacement or not flipAlignment
						then { getOppositePlacement(initialPlacement) }
						else getExpandedPlacements(initialPlacement :: any)
				)

			if not specifiedFallbackPlacements and fallbackAxisSideDirection ~= "none" then
				for _, _oppositeAxisPlacement in
					getOppositeAxisPlacements(initialPlacement, flipAlignment, fallbackAxisSideDirection, rtl)
				do
					table.insert(fallbackPlacements, _oppositeAxisPlacement)
				end
			end

			local placements = Array.concat({ initialPlacement }, fallbackPlacements)

			local overflow = await(detectOverflow(state, detectOverflowOptions))

			local overflows = {}
			local overflowsData = if middlewareData.flip then middlewareData.flip.overflows else {}

			if checkMainAxis then
				table.insert(overflows, overflow[side])
			end

			if checkCrossAxis then
				local sides = getAlignmentSides(placement, rects, rtl)
				table.insert(overflows, overflow[sides[1]])
				table.insert(overflows, overflow[sides[2]])
			end

			overflowsData = Array.concat(overflowsData, { { placement = placement, overflows = overflows } })

			-- One or more sides is overflowing.
			if not Array.every(overflows, function(side)
				return side <= 0
			end) then
				local nextIndex = (middlewareData.flip and middlewareData.flip.index or 0) + 1
				local nextPlacement = placements[nextIndex]

				if nextPlacement then
					-- Try next placement and re-run the lifecycle.
					return {
						data = {
							index = nextIndex,
							overflows = overflowsData,
						},
						reset = {
							placement = nextPlacement,
						},
					}
				end
			end

			-- First, find the candidates that fit on the mainAxis side of overflow,
			-- then find the placement that fits the best on the main crossAxis side.
			local _resetPlacement = Array.sort(
				Array.filter(overflowsData, function(d)
					return d.overflows[1] <= 0
				end),
				function(a, b)
					return a.overflows[2] - b.overflows[2]
				end
			)[1]
			local resetPlacement = if _resetPlacement then _resetPlacement.placement else nil

			-- Otherwise fallback.
			if not resetPlacement then
				if fallbackStrategy == "bestFit" then
					local _placement = Array.sort(
						Array.map(overflowsData, function(d)
							return {
								d.placement,
								Array.reduce(
									Array.filter(d.overflows, function(overflow)
										return overflow > 0
									end),
									function(acc, overflow)
										return acc + overflow
									end,
									0
								),
							}
						end),
						function(a, b)
							return a[2] - b[2]
						end
					)[1]
					local placement = if _placement then _placement[1] else nil
					if placement then
						resetPlacement = placement
					end
				elseif fallbackStrategy == "initialPlacement" then
					resetPlacement = initialPlacement
				end
			end

			if placement ~= resetPlacement then
				return {
					reset = {
						placement = resetPlacement,
					},
				}
			end

			return {}
		end,
	}
end

return {
	flip = flip,
}
