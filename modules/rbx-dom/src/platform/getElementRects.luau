-- Copyright (c) 2021-present Floating UI contributors
--!strict

local Packages = script.Parent.Parent.Parent

local core = require(Packages["floating-ui-core"])

local function getElementRects(
	args: { reference: GuiObject, floating: GuiObject, strategy: core.Strategy }
): core.ElementRects
	return {
		reference = {
			width = args.reference.AbsoluteSize.X,
			height = args.reference.AbsoluteSize.Y,
			x = args.reference.AbsolutePosition.X,
			y = args.reference.AbsolutePosition.Y,
		},
		floating = {
			width = args.floating.AbsoluteSize.X,
			height = args.floating.AbsoluteSize.Y,
			x = args.floating.AbsolutePosition.X,
			y = args.floating.AbsolutePosition.Y,
		},
	}
end

return {
	getElementRects = getElementRects,
}
