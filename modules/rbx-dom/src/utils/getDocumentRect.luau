-- Copyright (c) 2021-present Floating UI contributors
--!strict

local Package = script.Parent.Parent
local Packages = Package.Parent

local core = require(Packages["floating-ui-core"])

type Rect = core.Rect

local function getDocumentRect(document: (ScreenGui | BillboardGui | SurfaceGui)?): Rect
	if not document then
		return {
			width = 0,
			height = 0,
			x = 0,
			y = 0,
		}
	end
	local size = document.AbsoluteSize
	local position = document.AbsolutePosition

	return {
		width = size.X,
		height = size.Y,
		x = position.X,
		y = position.Y,
	}
end

return {
	getDocumentRect = getDocumentRect,
}
