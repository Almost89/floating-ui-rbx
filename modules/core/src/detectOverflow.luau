-- Copyright (c) 2021-present Floating UI contributors
--!strict

local _Package = script.Parent
local _Packages = _Package.Parent

local _types = require(_Package.types)
local Promise = require(_Packages.Promise)
local _utils = require(_Packages["floating-ui-utils"])

local evaluate, getPaddingObject, rectToClientRect, _merge, await =
	_utils.evaluate, _utils.getPaddingObject, _utils.rectToClientRect, _utils.merge, _utils.await

type Promise<T...> = Promise.TypedPromise<T...>

type Boundary = _types.Boundary
type Derivable<T> = _types.Derivable<T>
type ElementContext = _types.ElementContext
type MiddlewareState = _types.MiddlewareState
type Padding = _types.Padding
type RootBoundary = _types.RootBoundary
type SideObject = _types.SideObject
type Promisable<T> = _types.Promisable<T>

export type Options = {
	--[[
		The clipping element(s) or area in which overflow will be checked.
  		@default 'clippingAncestors'
	]]
	boundary: Boundary?,
	--[[
		The root clipping area in which overflow will be checked.
  		@default 'viewport'
	]]
	rootBoundary: RootBoundary?,

	--[[
		The element in which overflow is being checked relative to a boundary.
   		@default 'floating'
	]]
	elementContext: ElementContext?,

	--[[
		Whether to check for overflow using the alternate element's boundary
   		(`clippingAncestors` boundary only).
   		@default false
	]]
	altBoundary: boolean?,

	--[[
		Virtual padding for the resolved overflow detection offsets.
   		@default 0
	]]
	padding: Padding?,
}

--[[
	Resolves with an object of overflow side offsets that determine how much the
	element is overflowing a given clipping boundary on each side.
	- positive = overflowing the boundary by that number of pixels
	- negative = how many pixels left before it will overflow
	- 0 = lies flush with the boundary
	@see https://floating-ui.com/docs/detectOverflow
]]
function detectOverflow(state: MiddlewareState, options: (Options | Derivable<Options>)?): Promise<SideObject>
	local _options = options or {}
	local x, y, platform, rects, elements, strategy =
		(state :: any).x, (state :: any).y, state.platform, state.rects, state.elements, state.strategy

	local _evaluated: Options = evaluate(options, state)
	local boundary, rootBoundary, elementContext, altBoundary, padding =
		_evaluated.boundary or "clippingAncestors",
		_evaluated.rootBoundary or "viewport",
		_evaluated.elementContext or "floating",
		_evaluated.altBoundary or false,
		_evaluated.padding or 0

	local paddingObject = getPaddingObject(padding)
	local altContext = if elementContext == "floating" then "reference" else "floating"
	local element = elements[if altBoundary then altContext else elementContext]

	local clippingClientRect = rectToClientRect(await(platform.getClippingRect({
		element = if (if platform.isElement then await(platform.isElement(element)) else true)
			then element
			else element.contextElement or (if platform.getDocumentElement
				then await(platform.getDocumentElement(element.floating))
				else nil),
		boundary = boundary,
		rootBoundary = rootBoundary :: any,
		strategy = strategy :: any,
	})))

	local rect: _types.Rect = if elementContext == "floating"
		then _merge(rects.floating, { x = x, y = y })
		else rects.reference

	local offsetParent = if platform.getOffsetParent then await(platform.getOffsetParent(elements.floating)) else nil
	local offsetScale = if (if platform.isElement then await(platform.isElement(offsetParent)) else nil)
		then (if platform.getScale then await(platform.getScale(offsetParent)) else nil) or { x = 1, y = 1 }
		else { x = 1, y = 1 }

	local elementClientRect = rectToClientRect(if platform.convertOffsetParentRelativeRectToViewportRelativeRect
		then await(platform.convertOffsetParentRelativeRectToViewportRelativeRect({
			rect = rect,
			offsetParent = offsetParent,
			strategy = strategy :: any,
		}))
		else rect)

	return Promise.resolve({
		top = (clippingClientRect.top - elementClientRect.top + paddingObject.top) / offsetScale.y,
		bottom = (elementClientRect.bottom - clippingClientRect.bottom + paddingObject.bottom) / offsetScale.y,
		left = (clippingClientRect.left - elementClientRect.left + paddingObject.left) / offsetScale.x,
		right = (elementClientRect.right - clippingClientRect.right + paddingObject.right) / offsetScale.x,
	} :: SideObject)
end

return {
	detectOverflow = detectOverflow,
}
