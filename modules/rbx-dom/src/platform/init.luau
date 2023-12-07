-- Copyright (c) 2021-present Floating UI contributors
--!strict

local Packages = script.Parent.Parent

local core = require(Packages["floating-ui-core"])

local isElement = require(script.isElement).isElement
local getDimensions = require(script.getDimensions).getDimensions
local getElementRects = require(script.getElementRects).getElementRects
local getClippingRect = require(script.getClippingRect).getClippingRect
local getDocumentElement = require(script.getDocumentElement).getDocumentElement

return {
	isElement = isElement,
	getDimensions = getDimensions,
	getElementRects = getElementRects,
	getClippingRect = getClippingRect,
	getDocumentElement = getDocumentElement,
} :: core.Platform
