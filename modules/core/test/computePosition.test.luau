-- Copyright (c) 2021-present Floating UI contributors
--!strict

local _ReplicatedStorage = game:GetService("ReplicatedStorage")
local _Packages = _ReplicatedStorage.Packages

local Promise = require(_Packages.Promise)
local _core = require(_Packages["floating-ui-core"])
local _utils = require(_Packages["floating-ui-utils"])

type Platform = _core.Platform

type Promisable<T> = any
type Promise<T> = any

local _merge, await = _utils.merge, _utils.await

local computePosition = _core.computePosition

local reference = {}
local floating = {}
local referenceRect = { x = 0, y = 0, width = 100, height = 100 }
local floatingRect = { x = 0, y = 0, width = 50, height = 50 }
local platform: Platform = {
	getElementRects = function()
		return Promise.resolve({
			reference = referenceRect,
			floating = floatingRect,
		})
	end,
	getDimensions = function()
		return Promise.resolve({ width = 10, height = 10 })
	end,
} :: any

return function(_x: any)
	local describe: (string, () -> ()) -> (), test: (string, () -> ()) -> () = _x.nested, _x.test

	test("returned data", function()
		local _position = await(computePosition(reference, floating, {
			placement = "top",
			middleware = {
				{
					name = "custom",
					fn = function()
						return { data = { property = true } }
					end,
				} :: _core.Middleware,
			},
			platform = platform,
		}))
		local x, y, placement, strategy, middlewareData =
			_position.x, _position.y, _position.placement, _position.strategy, _position.middlewareData

		_x.assertEqual(placement, "top")
		_x.assertEqual(strategy, "absolute")
		_x.assertEqual(x, 25)
		_x.assertEqual(y, -50)
		_x.assertEqual(middlewareData.custom ~= nil, true)
		_x.assertEqual(middlewareData.custom.property, true)
	end)

	test("middleware", function()
		local _position: any = await(computePosition(reference, floating, {
			platform = platform,
		}))
		local x, y = _position.x, _position.y

		local _position2 = await(computePosition(reference, floating, {
			platform = platform,
			middleware = {
				{
					name = "test",
					fn = function(_position: any)
						local x, y = _position.x, _position.y
						return { x = x + 1, y = y + 1 }
					end,
				} :: _core.Middleware,
			},
		}))
		local x2, y2 = _position2.x, _position2.y

		_x.assertEqual(x2, x + 1)
		_x.assertEqual(y2, y + 1)
	end)

	test("middlewareData", function()
		local _position = await(computePosition(reference, floating, {
			platform = platform,
			middleware = {
				{
					name = "test",
					fn = function()
						return {
							data = {
								hello = true,
							},
						}
					end,
				} :: _core.Middleware,
			},
		}))
		local middlewareData = _position.middlewareData

		_x.assertEqual(middlewareData.test ~= nil, true)
		_x.assertEqual(middlewareData.test.hello, true)
	end)
end
