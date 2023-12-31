-- Copyright (c) 2021-present Floating UI contributors
--!strict

local _Package = script.Parent
local _Packages = _Package.Parent

local _types = require(_Package.types)
local Promise = require(_Packages.Promise)
local Boolean = require(_Packages.Boolean)
local _utils = require(_Packages["floating-ui-utils"])

type Promise<T...> = Promise.TypedPromise<T...>

local _merge, await = _utils.merge, _utils.await
local Array = require(_Packages.Collections).Array
local computeCoordsFromPlacement = require(_Package.computeCoordsFromPlacement).computeCoordsFromPlacement

type ComputePosition = _types.ComputePosition
type ComputePositionReturn = _types.ComputePositionReturn
type Middleware = _types.Middleware
type MiddlewareData = _types.MiddlewareData
type Promisable<T> = _types.Promisable<T>

--[[
	Computes the `x` and `y` coordinates that will place the floating element
	next to a reference element when it is given a certain positioning strategy.

	This export does not have any `platform` interface logic. You will need to
	write one for the platform you are using Floating UI with.
]]
function computePosition(reference: any, floating: any, config: any): Promise<ComputePositionReturn>
	local placement, strategy, middleware, platform =
		config.placement or "bottom", config.strategy or "absolute", config.middleware or {}, config.platform

	local validMiddleware = Array.filter(middleware, Boolean.toJSBoolean) :: { Middleware }
	local rtl = if platform.isRTL then await(platform.isRTL(floating)) else nil

	local rects = await(platform.getElementRects({ reference = reference, floating = floating, strategy = strategy }))
	local _coords = computeCoordsFromPlacement(rects, placement, rtl)
	local x, y = _coords.x, _coords.y
	local statefulPlacement = placement
	local middlewareData: MiddlewareData = {}
	local resetCount = 0

	local i = 1
	while i <= #validMiddleware do
		local _middleware = validMiddleware[i]
		local name, fn = _middleware.name, _middleware.fn

		local _result = await(fn({
			x = x,
			y = y,
			initialPlacement = placement,
			placement = statefulPlacement,
			strategy = strategy,
			middlewareData = middlewareData,
			rects = rects,
			platform = platform,
			elements = { reference, floating },
		}))
		local nextX, nextY, data, reset = _result.x, _result.y, _result.data, _result.reset

		x = nextX or x
		y = nextY or y

		middlewareData = _merge(middlewareData, {
			[name] = _merge(middlewareData[name] or {}, data),
		})

		if reset and resetCount <= 50 then
			resetCount += 1

			if type(reset) == "table" and not Array.isArray(reset) then
				if reset.placement then
					statefulPlacement = reset.placement
				end

				if reset.rects then
					rects = if reset.rects == true
						then await(
							platform.getElementRects({ reference = reference, floating = floating, strategy = strategy })
						)
						else reset.rects
				end
			end

			local _coords = computeCoordsFromPlacement(rects, statefulPlacement, rtl)
			x, y = _coords.x, _coords.y

			i = 0
		end

		i += 1
	end

	return Promise.resolve({
		x = x,
		y = y,
		placement = statefulPlacement,
		strategy = strategy,
		middlewareData = middlewareData,
	} :: ComputePositionReturn)
end

return {
	computePosition = computePosition,
}
