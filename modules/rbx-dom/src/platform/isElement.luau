-- Copyright (c) 2021-present Floating UI contributors
--!strict

local function isElement(element: any): boolean
	return typeof(element) == "Instance" and element:IsA("GuiObject") == true
end

return {
	isElement = isElement,
}
