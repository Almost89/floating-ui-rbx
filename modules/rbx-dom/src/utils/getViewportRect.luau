-- Copyright (c) 2021-present Floating UI contributors
--!strict

local Package = script.Parent.Parent
local Packages = Package.Parent

local core = require(Packages["floating-ui-core"])

type Rect = core.Rect

local function getViewportRect(): Rect
	local viewportSize = workspace.CurrentCamera.ViewportSize
	return {
		width = viewportSize.X,
		height = viewportSize.Y,
		x = 0,
		y = 0,
	}
end

return {
	getViewportRect = getViewportRect,
}
