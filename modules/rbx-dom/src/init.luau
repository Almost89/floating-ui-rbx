-- Copyright (c) 2021-present Floating UI contributors
--!strict

local Packages = script.Parent

local platform = require(script.platform)
local core = require(Packages["floating-ui-core"])

export type Boundary = core.Boundary
export type ComputePosition = core.ComputePosition
export type ComputePositionConfig = core.ComputePositionConfig
export type ComputePositionReturn = core.ComputePositionReturn
export type Coords = core.Coords
export type Derivable<T> = core.Derivable<T>
export type Dimensions = core.Dimensions
export type ElementContext = core.ElementContext
export type Elements = core.Elements
export type FloatingElement = core.FloatingElement
export type Middleware = core.Middleware
export type MiddlewareArguments = core.MiddlewareArguments
export type MiddlewareData = core.MiddlewareData
export type MiddlewareReturn = core.MiddlewareReturn
export type MiddlewareState = core.MiddlewareState
export type Platform = core.Platform
export type ReferenceElement = core.ReferenceElement
export type RootBoundary = core.RootBoundary
export type AlignedPlacement = core.AlignedPlacement
export type Alignment = core.Alignment
export type Axis = core.Axis
export type ClientRectObject = core.ClientRectObject
export type ElementRects = core.ElementRects
export type Length = core.Length
export type Padding = core.Padding
export type Placement = core.Placement
export type Rect = core.Rect
export type Side = core.Side
export type SideObject = core.SideObject
export type Strategy = core.Strategy
export type VirtualElement = core.VirtualElement

local function computePosition(reference: GuiObject, floating: GuiObject, userConfig: core.ComputePositionConfig)
	local config = table.clone(userConfig)
	config.platform = platform

	return core.computePosition(reference, floating, config)
end

return {
	platform = platform,
	computePosition = computePosition,

	arrow = core.arrow,
	autoPlacement = core.autoPlacement,
	detectOverflow = core.detectOverflow,
	flip = core.flip,
	hide = core.hide,
	inline = core.inline,
	limitShift = core.limitShift,
	offset = core.offset,
	shift = core.shift,
	size = core.size,
}
