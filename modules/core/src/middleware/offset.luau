-- Copyright (c) 2021-present Floating UI contributors
--!strict

local _Package = script.Parent.Parent
local _Packages = _Package.Parent

local _types = require(_Package.types)
local Promise = require(_Packages.Promise)
local _utils = require(_Packages["floating-ui-utils"])

local Array = require(_Packages.Collections).Array
local evaluate, getAlignment, getSide, getSideAxis, _merge, await =
	_utils.evaluate, _utils.getAlignment, _utils.getSide, _utils.getSideAxis, _utils.merge, _utils.await

type Promise<T...> = Promise.TypedPromise<T...>

type Coords = _types.Coords
type Derivable<T> = _types.Derivable<T>
type Middleware = _types.Middleware
type MiddlewareState = _types.MiddlewareState

type OffsetValue = number | {
	--[[
		The axis that runs along the side of the floating element. Represents
		the distance (gutter or margin) between the reference and floating
		element.
		@default 0
	]]
	mainAxis: number?,
	--[[
		The axis that runs along the alignment of the floating element.
		Represents the skidding between the reference and floating element.
		@default 0
	]]
	crossAxis: number?,
	--[[
		The same axis as `crossAxis` but applies only to aligned placements
		and inverts the `end` alignment. When set to a number, it overrides the
		`crossAxis` value.

		A positive number will move the floating element in the direction of
		the opposite edge to the one that is aligned, while a negative number
		the reverse.
		@default null
	]]
	alignmentAxis: number?,
}

-- For type backwards-compatibility, the `OffsetOptions` type was also
-- Derivable.
export type OffsetOptions = OffsetValue | Derivable<OffsetValue>

local function convertValueToCoords(state: MiddlewareState, options: OffsetOptions): Promise<Coords>
	local placement, platform, elements = state.placement, state.platform, state.elements
	local rtl = await(if platform.isRTL then platform.isRTL(elements.floating) else nil)

	local side = getSide(placement :: any)
	local alignment = getAlignment(placement :: any)
	local isVertical = getSideAxis(placement :: any) == "y"
	local mainAxisMulti = if Array.includes({ "left", "top" }, side) then -1 else 1
	local crossAxisMulti = if rtl and isVertical then -1 else 1
	local rawValue = evaluate(options, state)

	local _cookedValue = if type(rawValue) == "number"
		then { mainAxis = rawValue, crossAxis = 0, alignmentAxis = nil }
		else _merge({ mainAxis = 0, crossAxis = 0, alignmentAxis = nil }, rawValue)
	local mainAxis, crossAxis, alignmentAxis = _cookedValue.mainAxis, _cookedValue.crossAxis, _cookedValue.alignmentAxis

	if alignment and type(alignmentAxis) == "number" then
		crossAxis = if alignment == "end" then alignmentAxis * -1 else alignmentAxis
	end

	return Promise.resolve(if isVertical
		then {
			x = crossAxis * crossAxisMulti,
			y = mainAxis * mainAxisMulti,
		}
		else {
			x = mainAxis * mainAxisMulti,
			y = crossAxis * crossAxisMulti,
		})
end

--[[
	Modifies the placement by translating the floating element along the
	specified axes.
	A number (shorthand for `mainAxis` or distance), or an axes configuration
	object may be passed.
	@see https://floating-ui.com/docs/offset
]]
local offset = function(options: OffsetOptions?): Middleware
	options = options or 0
	return {
		name = "offset",
		options = options,
		fn = function(state)
			local x, y, placement, middlewareData = state.x, state.y, state.placement, state.middlewareData
			local diffCoords = await(convertValueToCoords(state, options :: any))

			-- If the placement is the same and the arrow caused an alignment offset
			-- then we don't need to change the positioning coordinates.
			if
				placement == (if middlewareData.offset then middlewareData.offset.placement else nil)
				and (if middlewareData.arrow then middlewareData.arrow.alignmentOffset else nil)
			then
				return {}
			end

			return {
				x = x + diffCoords.x,
				y = y + diffCoords.y,
				data = _merge(diffCoords, { placement = placement }),
			}
		end,
	}
end

return {
	offset = offset,
	convertValueToCoords = convertValueToCoords,
}
