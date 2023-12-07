-- Copyright (c) 2021-present Floating UI contributors
--!strict

local Package = script.Parent.Parent
local Packages = Package.Parent

local types = require(Package.types)
local core = require(Packages["floating-ui-core"])

local rectToClientRect = core.rectToClientRect
local isElement = require(Package.platform.isElement).isElement

type Element = types.Element
type VirtualElement = core.VirtualElement

local function getBoundingClientRect(element: Element | core.VirtualElement): core.ClientRectObject
	if isElement(element) then
		-- FIXME: Luau doesn't know that `isElement()` can narrow the type down
		-- to GuiObject.
		local size = (element :: GuiObject).AbsoluteSize
		local position = (element :: GuiObject).AbsolutePosition

		return rectToClientRect({
			width = size.X,
			height = size.Y,
			x = position.X,
			y = position.Y,
		})
	else
		return rectToClientRect((element :: VirtualElement):getBoundingClientRect())
	end
end

return {
	getBoundingClientRect = getBoundingClientRect,
}
