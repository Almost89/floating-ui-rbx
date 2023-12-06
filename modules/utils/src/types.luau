-- Copyright (c) 2021-present Floating UI contributors
--!strict

export type Alignment = "start" | "end"
export type Side = "top" | "right" | "bottom" | "left"
export type AlignedPlacement =
	"top-start"
	| "right-start"
	| "bottom-start"
	| "left-start"
	| "top-end"
	| "right-end"
	| "bottom-end"
	| "left-end"
export type Placement = Side | AlignedPlacement
export type Strategy = "absolute" | "fixed"
export type Axis = "x" | "y"
export type Length = "width" | "height"
export type SideObject = { top: number, right: number, bottom: number, left: number }
export type PartialSideObject = { top: number?, right: number?, bottom: number?, left: number? }
export type Rect = { x: number, y: number, width: number, height: number }
export type Padding = number | PartialSideObject
export type ClientRectObject = Rect & SideObject

export type ElementRects = {
	reference: Rect,
	floating: Rect,
}

--[[
	Custom positioning reference element.
	@see https://floating-ui.com/docs/virtual-elements
]]
export type VirtualElement = {
	getBoundingClientRect: (VirtualElement) -> ClientRectObject,
	contextElement: any?,
}

return nil
