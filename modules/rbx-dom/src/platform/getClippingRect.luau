-- Copyright (c) 2021-present Floating UI contributors
--!strict

local Package = script.Parent.Parent
local Packages = Package.Parent

local types = require(Package.types)
local core = require(Packages["floating-ui-core"])

local max, min = math.max, math.min
local rectToClientRect = core.rectToClientRect
local Array = require(Packages.Collections).Array
local isElement = require(Package.platform.isElement).isElement
local getViewportRect = require(Package.utils.getViewportRect).getViewportRect
local getDocumentRect = require(Package.utils.getDocumentRect).getDocumentRect
local getDocumentElement = require(Package.platform.getDocumentElement).getDocumentElement
local getBoundingClientRect = require(Package.utils.getBoundingClientRect).getBoundingClientRect

type Rect = core.Rect
type Element = types.Element
type Strategy = core.Strategy
type Boundary = core.Boundary
type RootBoundary = core.RootBoundary
type ClientRectObject = core.ClientRectObject

local function getInnerBoundingClientRect(element: Element, _strategy: Strategy): Rect
	-- FIXME: use strategy and `getScale()` here?
	local clientRect = getBoundingClientRect(element)
	local top = clientRect.top + element.AbsolutePosition.X
	local left = clientRect.left + element.AbsolutePosition.Y
	local width = element.AbsoluteSize.X
	local height = element.AbsoluteSize.Y
	local x = left
	local y = top

	return {
		width = width,
		height = height,
		x = x,
		y = y,
	}
end

local function getClientRectFromClippingAncestor(
	element: Element,
	clippingAncestor: Element | RootBoundary,
	strategy: Strategy
): ClientRectObject
	local rect: Rect

	if clippingAncestor == "viewport" then
		rect = getViewportRect()
	elseif clippingAncestor == "document" then
		rect = getDocumentRect(getDocumentElement(element))
	elseif isElement(clippingAncestor) then
		-- FIXME: Luau doesn't know that it can narrow the type down to
		-- GuiObject.
		rect = getInnerBoundingClientRect(clippingAncestor :: GuiObject, strategy)
	else
		-- FIXME: Luau doesn't know that it can narrow the type down to
		-- Rect.
		rect = table.clone(clippingAncestor :: Rect)
	end

	return rectToClientRect(rect)
end

local function getClippingRect(args: {
	element: Element,
	strategy: Strategy,
	boundary: Boundary,
	rootBoundary: RootBoundary,
}): Rect
	local element, strategy, boundary, rootBoundary = args.element, args.strategy, args.boundary, args.rootBoundary
	local clippingAncestors = { boundary, rootBoundary }
	local firstClippingAncestor = boundary

	local clippingRect = Array.reduce(clippingAncestors, function(accRect: ClientRectObject, clippingAncestor)
		local rect = getClientRectFromClippingAncestor(element, clippingAncestor, strategy :: any)

		accRect.top = max(rect.top, accRect.top)
		accRect.right = min(rect.right, accRect.bottom)
		accRect.bottom = min(rect.bottom, accRect.bottom)
		accRect.left = max(rect.left, accRect.left)

		return accRect
	end, getClientRectFromClippingAncestor(element, firstClippingAncestor, strategy :: any))

	return {
		width = clippingRect.right - clippingRect.left,
		height = clippingRect.bottom - clippingRect.top,
		x = clippingRect.left,
		y = clippingRect.top,
	}
end

return {
	getClippingRect = getClippingRect,
}
