-- Copyright (c) 2021-present Floating UI contributors
--!strict

local _Packages = script.Parent

local _types = require(script.types)
local String = require(_Packages.String)
local Promise = require(_Packages.Promise)

local Array = require(_Packages.Collections).Array

type Promise<T...> = Promise.TypedPromise<T...>

export type Alignment = _types.Alignment
export type Axis = _types.Axis
export type ClientRectObject = _types.ClientRectObject
export type ElementRects = _types.ElementRects
export type Length = _types.Length
export type Padding = _types.Padding
export type Placement = _types.Placement
export type Rect = _types.Rect
export type Side = _types.Side
export type SideObject = _types.SideObject
export type PartialSideObject = _types.PartialSideObject
export type Strategy = _types.Strategy
export type AlignedPlacement = _types.AlignedPlacement
export type VirtualElement = _types.VirtualElement

local sides: { Side } = table.freeze({ "top", "right", "bottom", "left" }) :: any
local alignments: { Alignment } = table.freeze({ "start", "end" }) :: any
local placements: { Placement } = table.freeze(Array.reduce(sides, function(acc: { Placement }, side)
	return Array.concat(acc, side, `{side}-{alignments[1]}`, `{side}-{alignments[2]}`) :: any
end))

local min = math.min
local max = math.max
local round = math.round
local floor = math.floor
local createCoords = function(v: number)
	return { x = v, y = v }
end

local oppositeSideMap = table.freeze({
	left = "right",
	right = "left",
	bottom = "top",
	top = "bottom",
})

local oppositeAlignmentMap = table.freeze({
	start = "end",
	["end"] = "start",
})

-- extra utils start
local function await<T>(value: T | Promise<T>): T
	return if Promise.is(value) then select(2, (value :: Promise<T>):await()) :: any else value
end
local function merge(...: { [any]: any }?): { [any]: any }
	local merged = nil
	for index = 1, select("#", ...) do
		local t = select(index, ...)
		if type(t) == "table" then
			if not merged then
				merged = table.clone(t)
			else
				for key, value in t do
					merged[key] = value
				end
			end
		end
	end
	return merged or {}
end
-- extra utils end

function clamp(start: number, value: number, _end: number): number
	return max(start, min(value, _end))
end

function evaluate<T, P>(value: T | ((param: P) -> T), param: P): T
	return if type(value) == "function" then value(param) else value
end

function getSide(placement: Placement): Side
	return String.split(placement, "-")[1] :: Side
end

function getAlignment(placement: Placement): Alignment?
	return String.split(placement, "-")[2] :: any
end

function getOppositeAxis(axis: Axis): Axis
	return if axis == "x" then "y" else "x"
end

function getAxisLength(axis: Axis): Length
	return if axis == "y" then "height" else "width"
end

function getSideAxis(placement: Placement): Axis
	return if Array.includes({ "top", "bottom" }, getSide(placement)) then "y" else "x"
end

function getAlignmentAxis(placement: Placement): Axis
	return getOppositeAxis(getSideAxis(placement))
end

function getAlignmentSides(placement: Placement, rects: ElementRects, rtl: boolean?): { Side }
	local _rtl = rtl or false
	local alignment: Alignment? = getAlignment(placement)
	local alignmentAxis: Axis = getAlignmentAxis(placement)
	local length: Length = getAxisLength(alignmentAxis)

	local mainAlignmentSide: Side = if alignmentAxis == "x"
		then if alignment == (if _rtl then "end" else "start") then "right" else "left"
		else if alignment == "start" then "bottom" else "top"

	if rects.reference[length] > rects.floating[length] then
		mainAlignmentSide = getOppositePlacement(mainAlignmentSide)
	end

	return { mainAlignmentSide, getOppositePlacement(mainAlignmentSide) }
end

function getExpandedPlacements(placement: Placement): { Placement }
	local oppositePlacement = getOppositePlacement(placement)

	return {
		getOppositeAlignmentPlacement(placement),
		oppositePlacement,
		getOppositeAlignmentPlacement(oppositePlacement),
	}
end

function getOppositeAlignmentPlacement<T>(placement: T & string): T
	-- lua patterns aren't as good as RegExp. orignal code:
	-- placement.replace(
	--  /start|end/g,
	--  (alignment) => oppositeAlignmentMap[alignment as Alignment],
	-- ) as T;
	local side, alignment = getSide(placement :: any), getAlignment(placement :: any)
	return (if alignment then `{side}-{oppositeAlignmentMap[alignment]}` else side) :: any
end

function getSideList(side: Side, isStart: boolean, rtl: boolean?): { Placement }
	local lr: { Placement } = table.freeze({ "left", "right" }) :: any
	local rl: { Placement } = table.freeze({ "right", "left" }) :: any
	local tb: { Placement } = table.freeze({ "top", "bottom" }) :: any
	local bt: { Placement } = table.freeze({ "bottom", "top" }) :: any

	if side == "top" or side == "bottom" then
		if rtl then
			return if isStart then rl else lr
		end
		return if isStart then lr else rl
	elseif side == "left" or side == "right" then
		return if isStart then tb else bt
	else
		return {}
	end
end

function getOppositeAxisPlacements(
	placement: Placement,
	flipAlignment: boolean,
	direction: "none" | Alignment,
	rtl: boolean?
): { Placement }
	local alignment = getAlignment(placement)
	local list = getSideList(getSide(placement), direction == "start", rtl)

	if alignment then
		list = Array.map(list, function(side)
			return `{side}-{alignment}` :: any
		end)

		if flipAlignment then
			list = Array.concat(list, Array.map(list, getOppositeAlignmentPlacement))
		end
	end

	return list
end

function getOppositePlacement<T>(placement: T & string): T
	-- lua patterns aren't as good as RegExp. orignal code:
	-- placement.replace(
	--  /left|right|bottom|top/g,
	--  (side) => oppositeSideMap[side as Side],
	-- ) as T;
	local side, alignment = oppositeSideMap[getSide(placement :: any)], getAlignment(placement :: any)
	return (if alignment then `{side}-{alignment}` else side) :: any
end

function expandPaddingObject(padding: PartialSideObject): SideObject
	return merge({ top = 0, right = 0, bottom = 0, left = 0 }, padding)
end

function getPaddingObject(padding: Padding): SideObject
	return if type(padding) ~= "number"
		then expandPaddingObject(padding)
		else { top = padding, right = padding, bottom = padding, left = padding }
end

function rectToClientRect(rect: Rect): ClientRectObject
	return merge(rect, {
		top = rect.y,
		left = rect.x,
		right = rect.x + rect.width,
		bottom = rect.y + rect.height,
	})
end

return {
	min = min,
	max = max,
	round = round,
	floor = floor,
	createCoords = createCoords,
	sides = sides,
	alignments = alignments,
	placements = placements,
	clamp = clamp,
	evaluate = evaluate,
	getSide = getSide,
	getAlignment = getAlignment,
	getOppositeAxis = getOppositeAxis,
	getAxisLength = getAxisLength,
	getSideAxis = getSideAxis,
	getAlignmentAxis = getAlignmentAxis,
	getAlignmentSides = getAlignmentSides,
	getExpandedPlacements = getExpandedPlacements,
	getOppositeAlignmentPlacement = getOppositeAlignmentPlacement,
	getOppositeAxisPlacements = getOppositeAxisPlacements,
	getOppositePlacement = getOppositePlacement,
	expandPaddingObject = expandPaddingObject,
	getPaddingObject = getPaddingObject,
	rectToClientRect = rectToClientRect,

	await = await,
	merge = merge,
}
