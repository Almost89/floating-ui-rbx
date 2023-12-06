-- Copyright (c) 2021-present Floating UI contributors
--!strict

local Packages = script.Parent.Parent.Parent

local core = require(Packages["floating-ui-core"])

local function getDimensions(element: GuiObject): core.Dimensions
	return { width = element.AbsoluteSize.X, height = element.AbsoluteSize.Y }
end

return {
	getDimensions = getDimensions,
}
