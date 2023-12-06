-- Copyright (c) 2021-present Floating UI contributors
--!strict

local _Package = script.Parent.Parent
local _Packages = _Package.Parent

local _types = require(_Package.types)
local Promise = require(_Packages.Promise)
local Boolean = require(_Packages.Boolean)
local _utils = require(_Packages["floating-ui-utils"])

local clamp, evaluate, getAlignment, getAlignmentAxis, getAxisLength, getPaddingObject, mathMin, _merge, await =
	_utils.clamp,
	_utils.evaluate,
	_utils.getAlignment,
	_utils.getAlignment,
	_utils.getAxisLength,
	_utils.getPaddingObject,
	_utils.min,
	_utils.merge,
	_utils.await

type Promise<T...> = Promise.TypedPromise<T...>

type Derivable<T> = _types.Derivable<T>
type Middleware = _types.Middleware
type Padding = _types.Padding

export type ArrowOptions = {
	--[[
		The arrow element to be positioned.
		@default undefined
	]]
	element: any?,
	--[[
		The padding between the arrow element and the floating element edges.
		Useful when the floating element has rounded corners.
		@default 0
	]]
	padding: Padding?,
}

--[[
	Provides data to position an inner element of the floating element so that it
	appears centered to the reference element.
	@see https://floating-ui.com/docs/arrow
]]
local arrow = function(options: ArrowOptions | Derivable<ArrowOptions>): Middleware
	return {
		name = "arrow",
		options = options,
		fn = function(state)
			local x, y, placement, rects, platform, elements, middlewareData =
				state.x, state.y, state.placement, state.rects, state.platform, state.elements, state.middlewareData
			-- Since `element` is required, we don't Partial<> the type.
			local element, padding = nil, nil
			do
				local evaluated = evaluate(options, state) or {} :: any
				element, padding = evaluated.element, evaluated.padding or 0
			end

			if element == nil then
				return {}
			end

			local paddingObject = getPaddingObject(padding)
			local coords = { x = x, y = y }
			local axis = getAlignmentAxis(placement :: any)
			local length = getAxisLength(axis :: any)
			local arrowDimensions = await(platform.getDimensions(element))
			local isYAxis = axis == "y"
			local minProp = if isYAxis then "top" else "left"
			local maxProp = if isYAxis then "bottom" else "right"
			local clientProp = if isYAxis then "clientHeight" else "clientWidth"

			local endDiff = rects.reference[length] + rects.reference[axis] - coords[axis] - rects.floating[length]
			local startDiff = coords[axis] - rects.reference[axis]

			local arrowOffsetParent = await(if platform.getOffsetParent then platform.getOffsetParent(element) else nil)
			local clientSize = if arrowOffsetParent then arrowOffsetParent[clientProp] else 0

			-- DOM platform can return `window` as the `offsetParent`
			if
				not Boolean.toJSBoolean(clientSize)
				or not await(if platform.isElement then platform.isElement(arrowOffsetParent) else nil)
			then
				clientSize = elements.floating[clientProp] or rects.floating[length]
			end

			local centerToReference = endDiff / 2 - startDiff / 2

			-- If the padding is large enough that it causes the arrow to no longer be
			-- centered, modify the padding so that it is centered.
			local largestPossiblePadding = clientSize / 2 - arrowDimensions[length] / 2 - 1
			local minPadding = mathMin(paddingObject[minProp], largestPossiblePadding)
			local maxPadding = mathMin(paddingObject[maxProp], largestPossiblePadding)

			-- Make sure the arrow doesn't overflow the floating element if the center
			-- point is outside the floating element's bounds.
			local min = minPadding
			local max = clientSize - arrowDimensions[length] - maxPadding
			local center = clientSize / 2 - arrowDimensions[length] / 2 + centerToReference
			local offset = clamp(min, center, max)

			-- If the reference is small enough that the arrow's padding causes it to
			-- to point to nothing for an aligned placement, adjust the offset of the
			-- floating element itself. To ensure `shift()` continues to take action,
			-- a single reset is performed when this is true.
			local shouldAddOffset = not middlewareData.arrow
				and getAlignment(placement :: any) ~= nil
				and center ~= offset
				and rects.reference[length] / 2
						- (if center < min then minPadding else maxPadding)
						- arrowDimensions[length] / 2
					< 0
			local alignmentOffset = if shouldAddOffset then if center < min then center - min else center - max else 0

			return {
				[axis] = coords[axis] + alignmentOffset,
				data = _merge({
					[axis] = offset,
					centerOffset = center - offset - alignmentOffset,
				}, if shouldAddOffset then { alignmentOffset = alignmentOffset } else nil),
				reset = shouldAddOffset,
			}
		end,
	}
end

return {
	arrow = arrow,
}
