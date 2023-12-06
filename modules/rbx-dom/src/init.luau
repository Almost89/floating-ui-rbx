-- Copyright (c) 2021-present Floating UI contributors
--!strict

local Packages = script.Parent

local platform = require(script.platform)
local core = require(Packages["floating-ui-core"])

local function computePosition(reference: GuiObject, floating: GuiObject, userConfig: core.ComputePositionConfig)
	local config = table.clone(userConfig)
	config.platform = platform

	return core.computePosition(reference, floating, config)
end

return {
	platform = platform,
	computePosition = computePosition,
}
