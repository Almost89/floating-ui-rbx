-- Copyright (c) 2021-present Floating UI contributors
--!strict

local _Package = script.Parent.Parent
local _Packages = _Package.Parent

local _types = require(_Package.types)
local Promise = require(_Packages.Promise)
local _utils = require(_Packages["floating-ui-utils"])
local _detectOverflow = require(_Package.detectOverflow)

local detectOverflow = _detectOverflow.detectOverflow
local evaluate, getAlignment, getSide, getSideAxis, max, min, _merge, await =
	_utils.evaluate,
	_utils.getAlignment,
	_utils.getSide,
	_utils.getSideAxis,
	_utils.max,
	_utils.min,
	_utils.merge,
	_utils.await

type Promise<T...> = Promise.TypedPromise<T...>

type DetectOverflowOptions = _detectOverflow.Options

type Derivable<T> = _types.Derivable<T>
type Middleware = _types.Middleware
type MiddlewareState = _types.MiddlewareState

export type SizeOptions = DetectOverflowOptions & {
	--[[
		Function that is called to perform style mutations to the floating element
		to change its size.
		@default undefined
	]]
	apply: (args: MiddlewareState & { availableWidth: number, availableHeight: number }) -> nil, -- Promise<nil>,
}

--[[
	Provides data that allows you to change the size of the floating element —
	for instance, prevent it from overflowing the clipping boundary or match the
	width of the reference element.
	@see https://floating-ui.com/docs/size
]]
local size = function(options: (SizeOptions | Derivable<SizeOptions>)?): Middleware
	options = options or {}
	return {
		name = "size",
		options = options,
		fn = function(state)
			local placement, rects, platform, elements = state.placement, state.rects, state.platform, state.elements

			local apply, detectOverflowOptions = nil, nil
			do
				local evaluated = evaluate(options, state)
				local evaluatedClone = table.clone(evaluated)

				evaluatedClone.apply = nil
				apply, detectOverflowOptions = evaluated.apply, evaluatedClone
			end

			local overflow = await(detectOverflow(state, detectOverflowOptions))
			local side = getSide(placement :: any)
			local alignment = getAlignment(placement :: any)
			local isYAxis = getSideAxis(placement :: any) == "y"
			local width, height = rects.floating.width, rects.floating.height

			local heightSide: "top" | "bottom"
			local widthSide: "left" | "right"

			if side == "top" or side == "bottom" then
				heightSide = side
				widthSide = if alignment
						== (
							if await(if platform.isRTL then platform.isRTL(elements.floating) else false)
								then "start"
								else "end"
						)
					then "left"
					else "right"
			else
				widthSide = side
				heightSide = if alignment == "end" then "top" else "bottom"
			end

			local overflowAvailableHeight = height - overflow[heightSide]
			local overflowAvailableWidth = width - overflow[widthSide]

			local noShift = not state.middlewareData.shift

			local availableHeight = overflowAvailableHeight
			local availableWidth = overflowAvailableWidth

			if isYAxis then
				local maximumClippingWidth = width - overflow.left - overflow.right
				availableWidth = if alignment or noShift
					then min(overflowAvailableWidth, maximumClippingWidth)
					else maximumClippingWidth
			else
				local maximumClippingHeight = height - overflow.top - overflow.bottom
				availableHeight = if alignment or noShift
					then min(overflowAvailableHeight, maximumClippingHeight)
					else maximumClippingHeight
			end

			if noShift and not alignment then
				local xMin = max(overflow.left, 0)
				local xMax = max(overflow.right, 0)
				local yMin = max(overflow.top, 0)
				local yMax = max(overflow.bottom, 0)

				if isYAxis then
					availableWidth = width
						- 2 * (if xMin ~= 0 or xMax ~= 0 then xMin + xMax else max(overflow.left, overflow.right))
				else
					availableHeight = height
						- 2 * (if yMin ~= 0 or yMax ~= 0 then yMin + yMax else max(overflow.top, overflow.bottom))
				end
			end

			await(apply(_merge(state, { availableWidth = availableWidth, availableHeight = availableHeight })))

			local nextDimensions = await(platform.getDimensions(elements.floating))

			if width ~= nextDimensions.width or height ~= nextDimensions.height then
				return {
					reset = {
						rects = true,
					},
				}
			end

			return {}
		end,
	}
end

return {
	size = size,
}
