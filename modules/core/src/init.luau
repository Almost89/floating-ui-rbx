-- Copyright (c) 2021-present Floating UI contributors
--!strict

local _types = require(script.types)
local computePosition = require(script.computePosition).computePosition
local detectOverflow = require(script.detectOverflow).detectOverflow
local hide = require(script.middleware.hide).hide
local flip = require(script.middleware.flip).flip
local size = require(script.middleware.size).size
local shift = require(script.middleware.shift).shift
local arrow = require(script.middleware.arrow).arrow
local offset = require(script.middleware.offset).offset

export type Derivable<T> = _types.Derivable<T>
export type Platform = _types.Platform
export type Coords = _types.Coords
export type PartialCoords = _types.PartialCoords
export type MiddlewareData = _types.MiddlewareData
export type ComputePositionConfig = _types.ComputePositionConfig
export type ComputePositionReturn = _types.ComputePositionReturn
export type ComputePosition = _types.ComputePosition
export type MiddlewareReturn = _types.MiddlewareReturn
export type Middleware = _types.Middleware
export type Dimensions = _types.Dimensions
export type ReferenceElement = _types.ReferenceElement
export type FloatingElement = _types.FloatingElement
export type Elements = _types.Elements
export type MiddlewareState = _types.MiddlewareState
export type AlignedPlacement = _types.AlignedPlacement
export type Alignment = _types.Alignment
export type Axis = _types.Axis
export type ClientRectObject = _types.ClientRectObject
export type ElementContext = _types.ElementContext
export type ElementRects = _types.ElementRects
--export type InlineOptions = _types.InlineOptions
export type Length = _types.Length
--export type OffsetOptions =  _types.OffsetOptions
export type Padding = _types.Padding
export type Placement = _types.Placement
export type Rect = _types.Rect
export type RootBoundary = _types.RootBoundary
export type Side = _types.Side
export type SideObject = _types.SideObject
export type Strategy = _types.Strategy

return {
	computePosition = computePosition :: ComputePosition,
	detectOverflow = detectOverflow,
	hide = hide,
	flip = flip,
	size = size,
	arrow = arrow,
	shift = shift,
	offset = offset,
}
