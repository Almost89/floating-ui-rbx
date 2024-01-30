-- Copyright (c) 2021-present Floating UI contributors
-- upstream: https://github.com/floating-ui/floating-ui/blob/33ceb8ba4e8959c3c3910c300782e83cd52f7f79/packages/core/src/index.ts
--!strict

local _types = require(script.types)
local _flip = require(script.middleware.flip)
local _hide = require(script.middleware.hide)
local _size = require(script.middleware.size)
local _arrow = require(script.middleware.arrow)
local _shift = require(script.middleware.shift)
local _inline = require(script.middleware.inline)
local _offset = require(script.middleware.offset)
local _detectOverflow = require(script.detectOverflow)
local _utils = require(script.Parent["floating-ui-utils"])
local _autoPlacement = require(script.middleware.autoPlacement)

local computePosition = require(script.computePosition).computePosition
export type DetectOverflowOptions = _detectOverflow.DetectOverflowOptions
local detectOverflow = _detectOverflow.detectOverflow
export type ArrowOptions = _arrow.ArrowOptions
local arrow = _arrow.arrow
export type AutoPlacementOptions = _autoPlacement.AutoPlacementOptions
local autoPlacement = _autoPlacement.autoPlacement
export type FlipOptions = _flip.FlipOptions
local flip = _flip.flip
export type HideOptions = _hide.HideOptions
local hide = _hide.hide
export type InlineOptions = _inline.InlineOptions
local inline = _inline.inline
export type OffsetOptions = _offset.OffsetOptions
local offset = _offset.offset
export type LimitShiftOptions = _shift.LimitShiftOptions
export type ShiftOptions = _shift.ShiftOptions
local shift, limitShift = _shift.shift, _shift.limitShift
export type SizeOptions = _size.SizeOptions
local size = _size.size

export type Boundary = _types.Boundary
export type ComputePosition = _types.ComputePosition
export type ComputePositionConfig = _types.ComputePositionConfig
export type ComputePositionReturn = _types.ComputePositionReturn
export type Coords = _types.Coords
export type Derivable<T> = _types.Derivable<T>
export type Dimensions = _types.Dimensions
export type ElementContext = _types.ElementContext
export type Elements = _types.Elements
export type FloatingElement = _types.FloatingElement
export type Middleware = _types.Middleware
export type MiddlewareArguments = _types.MiddlewareArguments
export type MiddlewareData = _types.MiddlewareData
export type MiddlewareReturn = _types.MiddlewareReturn
export type MiddlewareState = _types.MiddlewareState
export type Platform = _types.Platform
export type ReferenceElement = _types.ReferenceElement
export type RootBoundary = _types.RootBoundary

export type AlignedPlacement = _utils.AlignedPlacement
export type Alignment = _utils.Alignment
export type Axis = _utils.Axis
export type ClientRectObject = _utils.ClientRectObject
export type ElementRects = _utils.ElementRects
export type Length = _utils.Length
export type Padding = _utils.Padding
export type Placement = _utils.Placement
export type Rect = _utils.Rect
export type Side = _utils.Side
export type SideObject = _utils.SideObject
export type Strategy = _utils.Strategy
export type VirtualElement = _utils.VirtualElement

local rectToClientRect = _utils.rectToClientRect

return {
	computePosition = computePosition,
	detectOverflow = detectOverflow,
	arrow = arrow,
	autoPlacement = autoPlacement,
	flip = flip,
	hide = hide,
	inline = inline,
	offset = offset,
	limitShift = limitShift,
	shift = shift,
	size = size,
	rectToClientRect = rectToClientRect,
}
