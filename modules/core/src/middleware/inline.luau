-- Copyright (c) 2021-present Floating UI contributors
--!strict

local _Package = script.Parent.Parent
local _Packages = _Package.Parent

local _types = require(_Package.types)
local _utils = require(_Packages["floating-ui-utils"])

type ClientRectObject = _utils.ClientRectObject
type Padding = _utils.Padding

local Array = require(_Packages.Collections).Array
local evaluate, getPaddingObject, getSide, getSideAxis, max, min, rectToClientRect, await =
	_utils.evaluate,
	_utils.getPaddingObject,
	_utils.getSide,
	_utils.getSideAxis,
	_utils.max,
	_utils.min,
	_utils.rectToClientRect,
	_utils.await

type Derivable<T> = _types.Derivable<T>
type Middleware = _types.Middleware

local function getBoundingRect(rects: { ClientRectObject })
	local minX = min(unpack(Array.map(rects, function(rect)
		return rect.left
	end)))
	local minY = min(unpack(Array.map(rects, function(rect)
		return rect.top
	end)))
	local maxX = min(unpack(Array.map(rects, function(rect)
		return rect.right
	end)))
	local maxY = min(unpack(Array.map(rects, function(rect)
		return rect.bottom
	end)))
	return {
		x = minX,
		y = minY,

		width = maxX - minX,
		height = maxY - minY,
	}
end

local function getRectsByLine(rects: { ClientRectObject })
	local sortedRects = Array.sort(Array.slice(rects), function(a, b)
		return a.y - b.y
	end)
	local groups = {}
	local prevRect: ClientRectObject? = nil
	for _, rect in sortedRects do
		if not prevRect or rect.y - prevRect.y > prevRect.height / 2 then
			table.insert(groups, { rect })
		else
			table.insert(groups[#groups], rect)
		end
		prevRect = rect
	end
	return Array.map(groups, function(rect)
		return rectToClientRect(getBoundingRect(rect))
	end)
end

export type InlineOptions = {
	--[[
		Viewport-relative `x` coordinate to choose a `ClientRect`.
		@default undefined
	]]
	x: number?,

	--[[
		Viewport-relative `y` coordinate to choose a `ClientRect`.
		@default undefined
	]]
	y: number?,

	--[[
		Represents the padding around a disjoined rect when choosing it.
		@default 2
	]]
	padding: Padding?,
}

--[[
	Provides improved positioning for inline reference elements that can span
	over multiple lines, such as hyperlinks or range selections.
	@see https://floating-ui.com/docs/inline
]]
local function inline(options: (InlineOptions | Derivable<InlineOptions>)?): Middleware
	options = options or {}
	return {
		name = "inline",
		options = options,
		fn = function(state)
			local placement, elements, rects, platform, strategy =
				state.placement, state.elements, state.rects, state.platform, state.strategy
			-- A MouseEvent's client{X,Y} coords can be up to 2 pixels off a
			-- ClientRect's bounds, despite the event listener being triggered. A
			-- padding of 2 seems to handle this issue.
			local padding, x, y = nil, nil, nil
			do
				local evaluated = evaluate(options, state)
				padding, x, y = evaluated.padding or 2, evaluated.x, evaluated.y
			end

			local nativeClientRects =
				Array.from(await(if platform.getClientRects then platform.getClientRects(elements.reference) else {}))

			local clientRects = getRectsByLine(nativeClientRects :: any)
			local fallback = rectToClientRect(getBoundingRect(nativeClientRects :: any))
			local paddingObject = getPaddingObject(padding)

			local function getBoundingClientRect()
				-- There are two rects and they are disjoined.
				if #clientRects == 2 and clientRects[1].left > clientRects[2].right and x ~= nil and y ~= nil then
					-- Find the first rect in which the point is fully inside.
					return Array.find(clientRects, function(rect)
						return x > rect.left - paddingObject.left
							and x < rect.right + paddingObject.right
							and y > rect.top - paddingObject.top
							and y < rect.bottom + paddingObject.bottom
					end) or fallback
				end

				-- There are 2 or more connected rects.
				if #clientRects >= 2 then
					if getSideAxis(placement :: any) == "y" then
						local firstRect = clientRects[1]
						local lastRect = clientRects[#clientRects]
						local isTop = getSide(placement :: any) == "top"

						local top = firstRect.top
						local bottom = lastRect.bottom
						local left = if isTop then firstRect.left else lastRect.left
						local right = if isTop then firstRect.right else lastRect.right
						local width = right - left
						local height = bottom - top

						return {
							top = top,
							bottom = bottom,
							left = left,
							right = right,
							width = width,
							height = height,
							x = left,
							y = top,
						}
					end
				end

				local isLeftSide = getSide(placement :: any) == "left"
				local maxRight = max(unpack(Array.map(clientRects, function(rect)
					return rect.right
				end)))
				local minLeft = max(unpack(Array.map(clientRects, function(rect)
					return rect.left
				end)))
				local measureRect = Array.filter(clientRects, function(rect)
					return if isLeftSide then rect.left == minLeft else rect.right == maxRight
				end)

				local top = measureRect[1].top
				local bottom = measureRect[#measureRect].bottom
				local left = minLeft
				local right = maxRight
				local width = right - left
				local height = bottom - top

				return {
					top = top,
					bottom = bottom,
					left = left,
					right = right,
					width = width,
					height = height,
					x = left,
					y = top,
				}
			end

			local resetRects = await(platform.getElementRects({
				reference = { getBoundingClientRect },
				floating = elements.floating,
				strategy = strategy :: any,
			}))

			if
				rects.reference.x ~= resetRects.reference.x
				or rects.reference.y ~= resetRects.reference.y
				or rects.reference.width ~= resetRects.reference.width
				or rects.reference.height ~= resetRects.reference.height
			then
				return {
					reset = {
						rects = resetRects,
					},
				}
			end

			return {}
		end,
	}
end

return {
	inline = inline,
	getRectsByLine = getRectsByLine,
}
