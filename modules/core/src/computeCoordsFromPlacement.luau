-- Copyright (c) 2021-present Floating UI contributors
--!strict

local _Package = script.Parent

local getAlignment, getAlignmentAxis, getAxisLength, getSide, getSideAxis = nil, nil, nil, nil, nil
do
	local Packages = _Package.Parent

	local utils = require(Packages["floating-ui-utils"])

	getAlignment, getAlignmentAxis, getAxisLength, getSide, getSideAxis =
		utils.getAlignment, utils.getAlignmentAxis, utils.getAxisLength, utils.getSide, utils.getSideAxis
end

local _types = require(_Package.types)

type Coords = _types.Coords
type ElementRects = _types.ElementRects
type Placement = _types.Placement

function computeCoordsFromPlacement(_elementRects: ElementRects, placement: Placement, rtl: boolean?): Coords
	local reference, floating = _elementRects.reference, _elementRects.floating

	local sideAxis = getSideAxis(placement)
	local alignmentAxis = getAlignmentAxis(placement)
	local alignLength = getAxisLength(alignmentAxis :: any)
	local side = getSide(placement)
	local isVertical = sideAxis == "y"

	local commonX = reference.x + reference.width / 2 - floating.width / 2
	local commonY = reference.y + reference.height / 2 - floating.height / 2
	local commonAlign = reference[alignLength] / 2 - floating[alignLength] / 2

	local coords: Coords
	if side == "top" then
		coords = { x = commonX, y = reference.y - floating.height }
	elseif side == "bottom" then
		coords = { x = commonX, y = reference.y + reference.height }
	elseif side == "right" then
		coords = { x = reference.x + reference.width, y = commonY }
	elseif side == "left" then
		coords = { x = reference.x - floating.width, y = commonY }
	else
		coords = { x = reference.x, y = reference.y }
	end

	local _alignment = getAlignment(placement)
	if _alignment == "start" then
		coords[alignmentAxis :: any] -= commonAlign * (if rtl and isVertical then -1 else 1)
	elseif _alignment == "end" then
		coords[alignmentAxis :: any] += commonAlign * (if rtl and isVertical then -1 else 1)
	end

	return coords
end

return {
	computeCoordsFromPlacement = computeCoordsFromPlacement,
}
