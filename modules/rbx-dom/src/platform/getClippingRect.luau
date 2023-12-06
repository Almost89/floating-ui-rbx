-- Copyright (c) 2021-present Floating UI contributors
--!strict

local Packages = script.Parent.Parent.Parent

local core = require(Packages["floating-ui-core"])

-- FIXME: I actually have no idea what this function is supposed to do.
local function getClippingRect(args: {
	element: any,
	strategy: core.Strategy,
	boundary: any,
	rootBoundary: core.RootBoundary,
}): core.Rect
	if args.rootBoundary == "viewport" then
		local viewport = workspace.CurrentCamera.ViewportSize
		return {
			width = viewport.X,
			height = viewport.Y,
			x = 0,
			y = 0,
		}
	elseif args.rootBoundary == "document" then
		error("todo")
	else
		error("todo")
		--return args.rootBoundary
	end
end

return {
	getClippingRect = getClippingRect,
}
