-- Copyright (c) 2021-present Floating UI contributors
--!strict

local Package = script.Parent.Parent

local types = require(Package.types)

type Element = types.Element

local function getDocumentElement(element: Element): (ScreenGui | BillboardGui | SurfaceGui)?
	return element:FindFirstAncestorOfClass("ScreenGui")
		or element:FindFirstAncestorOfClass("BillboardGui")
		or element:FindFirstAncestorOfClass("SurfaceGui")
end

return {
	getDocumentElement = getDocumentElement,
}
