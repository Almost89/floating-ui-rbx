-- Copyright (c) 2021-present Floating UI contributors
--!strict

local _Package = script.Parent.Parent
local _Packages = _Package.Parent

local _types = require(_Package.types)
local _utils = require(_Packages["floating-ui-utils"])
local _detectOverflow = require(_Package.detectOverflow)

local detectOverflow = _detectOverflow.detectOverflow
local clamp, evaluate, getOppositeAxis, getSide, getSideAxis, _merge, await =
	_utils.clamp,
	_utils.evaluate,
	_utils.getOppositeAxis,
	_utils.getSide,
	_utils.getSideAxis,
	_utils.merge,
	_utils.await

type DetectOverflowOptions = _detectOverflow.DetectOverflowOptions

type Coords = _types.Coords
type Derivable<T> = _types.Derivable<T>
type Middleware = _types.Middleware
type MiddlewareState = _types.MiddlewareState

export type ShiftOptions = DetectOverflowOptions & {
	--[[
		The axis that runs along the alignment of the floating element. Determines
    	whether overflow along this axis is checked to perform shifting.
    	@default true
	]]
	mainAxis: boolean?,
	--[[
		The axis that runs along the side of the floating element. Determines
    	whether overflow along this axis is checked to perform shifting.
    	@default false
	]]
	crossAxis: boolean?,
	--[[
		Accepts a function that limits the shifting done in order to prevent
    	detachment.
	]]
	limiter: {
		fn: (state: MiddlewareState) -> Coords,
		options: any?,
	}?,
}

--[[
	Optimizes the visibility of the floating element by shifting it in order to
	keep it in view when it will overflow the clipping boundary.
	@see https://floating-ui.com/docs/shift
]]
local shift = function(options: ShiftOptions | Derivable<ShiftOptions>): Middleware
	return {
		name = "shift",
		options = options,
		fn = function(state)
			local x, y, placement = state.x, state.y, state.placement

			local checkMainAxis, checkCrossAxis, limiter, detectOverflowOptions = nil, nil, nil, nil
			do
				local evaluated = evaluate(options, state)
				local evaluatedClone = table.clone(evaluated)

				checkMainAxis, checkCrossAxis, limiter =
					evaluated.mainAxis or true, evaluated.crossAxis or false, evaluated.limiter or {
						fn = function(_coords)
							local x, y = _coords.x, _coords.y
							return { x = x, y = y }
						end,
					}

				evaluatedClone.mainAxis, evaluatedClone.crossAxis, evaluatedClone.limiter = nil, nil, nil
				detectOverflowOptions = evaluated
			end

			local coords = { x = x, y = y }
			local overflow = await(detectOverflow(state, detectOverflowOptions))
			local crossAxis = getSideAxis(getSide(placement :: any))
			local mainAxis = getOppositeAxis(crossAxis :: any)

			local mainAxisCoord = coords[mainAxis]
			local crossAxisCoord = coords[crossAxis]

			if checkMainAxis then
				local minSide = if mainAxis == "y" then "top" else "left"
				local maxSide = if mainAxis == "y" then "bottom" else "right"
				local min = mainAxisCoord + overflow[minSide]
				local max = mainAxisCoord - overflow[maxSide]

				mainAxisCoord = clamp(min, mainAxisCoord, max)
			end

			if checkCrossAxis then
				local minSide = if crossAxis == "y" then "top" else "left"
				local maxSide = if crossAxis == "y" then "bottom" else "right"
				local min = crossAxisCoord + overflow[minSide]
				local max = crossAxisCoord - overflow[maxSide]

				crossAxisCoord = clamp(min, crossAxisCoord, max)
			end

			local limitedCoords =
				limiter.fn(_merge(state, { [mainAxis] = mainAxisCoord, [crossAxis] = crossAxisCoord }))

			return _merge(limitedCoords, {
				data = {
					x = limitedCoords.x - x,
					y = limitedCoords.y - y,
				},
			})
		end,
	}
end

return {
	shift = shift,
}
