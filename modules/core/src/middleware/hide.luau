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
local evaluate, sides, _merge, await = _utils.evaluate, _utils.sides, _utils.merge, _utils.await

type Promise<T...> = Promise.TypedPromise<T...>

type DetectOverflowOptions = _detectOverflow.Options

type Derivable<T> = _types.Derivable<T>
type Middleware = _types.Middleware
type Rect = _types.Rect
type SideObject = _types.SideObject

local function getSideOffsets(overflow: SideObject, rect: Rect): SideObject
	return {
		top = overflow.top - rect.height,
		right = overflow.right - rect.width,
		bottom = overflow.bottom - rect.height,
		left = overflow.left - rect.width,
	}
end

local function isAnySideFullyClipped(overflow: SideObject): boolean
	return Array.some(sides, function(side: string)
		return overflow[side] >= 0
	end)
end

export type HideOptions = DetectOverflowOptions & {
	--[[
		The strategy used to determine when to hide the floating element.
	]]
	strategy: ("referenceHidden" | "escaped")?,
}

--[[
	Provides data to hide the floating element in applicable situations, such as
	when it is not in the same clipping context as the reference element.
	@see https://floating-ui.com/docs/hide
]]
local hide = function(options: (HideOptions | Derivable<HideOptions>)?): Middleware
	options = options or {}
	return {
		name = "hide",
		options = options,
		fn = function(state)
			local rects = state.rects

			local strategy, detectOverflowOptions = nil, nil
			do
				local evaluated = evaluate(options, state)
				local evaluatedClone = table.clone(evaluated)

				evaluatedClone.strategy = nil
				strategy, detectOverflowOptions = evaluated.strategy or "referenceHidden", evaluatedClone
			end

			if strategy == "referenceHidden" then
				local overflow =
					await(detectOverflow(state, _merge(detectOverflowOptions, { elementContext = "reference" })))
				local offsets = getSideOffsets(overflow, rects.reference)
				return {
					data = {
						referenceHiddenOffsets = offsets,
						referenceHidden = isAnySideFullyClipped(offsets),
					},
				}
			elseif strategy == "escaped" then
				local overflow = await(detectOverflow(state, _merge(detectOverflowOptions, { altBoundary = true })))
				local offsets = getSideOffsets(overflow, rects.floating)
				return {
					data = {
						escapedOffsets = offsets,
						escaped = isAnySideFullyClipped(offsets),
					},
				}
			else
				return {}
			end
		end,
	}
end

return {
	hide = hide,
}
