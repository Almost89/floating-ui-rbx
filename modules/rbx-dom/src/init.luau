-- Copyright (c) 2021-present Floating UI contributors
--!strict

local Packages = script.Parent

local core = require(Packages["floating-ui-core"])

local platform = require(script.platform)

-- extra utils start
local function merge(...: { [any]: any }?): { [any]: any }
	local merged = nil
	for index = 1, select("#", ...) do
		local t = select(index, ...)
		if type(t) == "table" then
			if not merged then
				merged = table.clone(t)
			else
				for key, value in t do
					merged[key] = value
				end
			end
		end
	end
	return merged or {}
end
-- extra utils end

local function computePosition(reference: GuiObject, floating: GuiObject, config: core.ComputePositionConfig)
	return core.computePosition(
		reference,
		floating,
		merge(config, {
			platform = platform,
		})
	)
end

return {
	platform = platform,
	computePosition = computePosition,
}
