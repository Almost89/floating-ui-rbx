-- Copyright (c) 2021-present Floating UI contributors
--!strict

local _Package = script.Parent
local _Packages = _Package.Parent

local Promise = require(_Packages.Promise)
local _utils = require(_Packages["floating-ui-utils"])

type Promise<T...> = Promise.TypedPromise<T...>

export type Axis = _utils.Axis
export type ClientRectObject = _utils.ClientRectObject
export type ElementRects = _utils.ElementRects
export type Length = _utils.Length
export type Placement = _utils.Placement
export type Rect = _utils.Rect
export type SideObject = _utils.SideObject
export type Strategy = _utils.Strategy
export type AlignedPlacement = _utils.AlignedPlacement
export type Alignment = _utils.Alignment
export type Padding = _utils.Padding
export type Side = _utils.Side
export type VirtualElement = _utils.VirtualElement

export type Promisable<T> = T | Promise<T>

--[[
	Function option to derive middleware options from state.
]]
export type Derivable<T> = (state: MiddlewareState) -> T

--[[
	Platform interface methods to work with the current platform.
	@see https://floating-ui.com/docs/platform
]]
export type Platform = {
	-- Required
	getElementRects: (
		args: {
			reference: ReferenceElement,
			floating: FloatingElement,
			strategy: Strategy,
		}
	) -> Promisable<ElementRects>,
	getClippingRect: (
		args: {
			element: any,
			boundary: Boundary,
			rootBoundary: RootBoundary,
			strategy: Strategy,
		}
	) -> Promisable<Rect>,
	getDimensions: (element: any) -> Promisable<Dimensions>,

	-- Optional
	convertOffsetParentRelativeRectToViewportRelativeRect: ((
		args: {
			rect: Rect,
			offsetParent: any,
			strategy: Strategy,
		}
	) -> Promisable<Rect>)?,
	getOffsetParent: ((element: any) -> Promisable<any>)?,
	isElement: ((value: any) -> Promisable<boolean>)?,
	getDocumentElement: ((element: any) -> Promisable<any>)?,
	getClientRects: ((element: any) -> Promisable<{ ClientRectObject }>)?,
	isRTL: ((element: any) -> Promisable<boolean>)?,
	getScale: ((element: any) -> Promisable<{ x: number, y: number }>)?,
}

export type Coords = { x: number, y: number }
export type PartialCoords = { x: number?, y: number? }

export type MiddlewareData = {
	[string]: any,
	arrow: (PartialCoords & {
		centerOffset: number,
		alignmentOffset: number?,
	})?,
	autoPlacement: {
		index: number?,
		overflows: {
			{
				placement: Placement,
				overflows: { number },
			}
		},
	}?,
	flip: {
		index: number?,
		overflows: {
			{
				placement: Placement,
				overflows: { number },
			}
		},
	}?,
	hide: {
		referenceHidden: boolean?,
		escaped: boolean?,
		referenceHiddenOffsets: SideObject?,
		escapedOffsets: SideObject?,
	}?,
	offset: (Coords & { placement: Placement })?,
	shift: Coords?,
}

export type ComputePositionConfig = {
	--[[
		Object to interface with the current platform.
	]]
	platform: Platform,
	--[[
		Where to place the floating element relative to the reference element.
	]]
	placement: Placement?,
	--[[
		The strategy to use when positioning the floating element.
	]]
	strategy: Strategy?,
	--[[
		Array of middleware objects to modify the positioning or provide data for
  		rendering.
	]]
	middleware: { false | Middleware? }?,
}

export type ComputePositionReturn = Coords & {
	--[[
		The final chosen placement of the floating element.
	]]
	placement: Placement,
	--[[
		The strategy used to position the floating element.
	]]
	strategy: Strategy,
	--[[
		Object containing data returned from all middleware, keyed by their name.
	]]
	middlewareData: MiddlewareData,
}

export type ComputePosition = (
	reference: unknown,
	floating: unknown,
	config: ComputePositionConfig
) -> Promise<ComputePositionReturn>

export type MiddlewareReturn = PartialCoords & {
	data: { [string]: any }?,
	reset: (boolean | { placement: Placement?, rects: (boolean | ElementRects)? })?,
}

export type Middleware = {
	name: string,
	options: any?,
	fn: (state: MiddlewareState) -> Promisable<MiddlewareReturn>,
}

export type Dimensions = { height: number, width: number }

export type ReferenceElement = any
export type FloatingElement = any

export type Elements = {
	reference: ReferenceElement,
	floating: FloatingElement,
}

export type MiddlewareState = Coords & {
	initialPlacement: Placement,
	placement: Placement,
	strategy: Strategy,
	middlewareData: MiddlewareData,
	elements: Elements,
	rects: ElementRects,
	platform: Platform,
}

--[[
	@deprecated use `MiddlewareState` instead.
]]
export type MiddlewareArguments = MiddlewareState

export type Boundary = any
export type RootBoundary = "viewport" | "document" | Rect
export type ElementContext = "reference" | "floating"

return {}
