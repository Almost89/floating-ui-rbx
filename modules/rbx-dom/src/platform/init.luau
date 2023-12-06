-- Copyright (c) 2021-present Floating UI contributors
--!strict

local Packages = script.Parent.Parent

local core = require(Packages["floating-ui-core"])

local getDimensions = require(script.getDimensions).getDimensions
local getElementRects = require(script.getElementRects).getElementRects
local getClippingRect = require(script.getClippingRect).getClippingRect

return {
	getDimensions = getDimensions,
	getElementRects = getElementRects,
	getClippingRect = getClippingRect,
} :: core.Platform
