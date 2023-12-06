-- Copyright (c) 2021-present Floating UI contributors
--!strict

local computeCoordsFromPlacement = nil
do
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Packages = ReplicatedStorage.Packages

	--FIXME: how we require this is unsafe. find another way to require modules that are not directly exposed.
	computeCoordsFromPlacement =
		require(Packages["floating-ui-core"].computeCoordsFromPlacement).computeCoordsFromPlacement
end

local reference = { x = 0, y = 0, width = 100, height = 100 }
local floating = { x = 0, y = 0, width = 50, height = 50 }

return function(_x)
	local describe: (string, () -> ()) -> (), test: (string, () -> ()) -> () = _x.nested, _x.test

	test("bottom", function()
		local _computedCoords = computeCoordsFromPlacement({ reference = reference, floating = floating }, "bottom")

		_x.assertEqual(_computedCoords.x, 25)
		_x.assertEqual(_computedCoords.y, 100)
	end)

	test("bottom-start", function()
		local _computedCoords =
			computeCoordsFromPlacement({ reference = reference, floating = floating }, "bottom-start")

		_x.assertEqual(_computedCoords.x, 0)
		_x.assertEqual(_computedCoords.y, 100)
	end)

	test("bottom-end", function()
		local _computedCoords = computeCoordsFromPlacement({ reference = reference, floating = floating }, "bottom-end")

		_x.assertEqual(_computedCoords.x, 50)
		_x.assertEqual(_computedCoords.y, 100)
	end)

	test("top", function()
		local _computedCoords = computeCoordsFromPlacement({ reference = reference, floating = floating }, "top")

		_x.assertEqual(_computedCoords.x, 25)
		_x.assertEqual(_computedCoords.y, -50)
	end)

	test("top-start", function()
		local _computedCoords = computeCoordsFromPlacement({ reference = reference, floating = floating }, "top-start")

		_x.assertEqual(_computedCoords.x, 0)
		_x.assertEqual(_computedCoords.y, -50)
	end)

	test("top-end", function()
		local _computedCoords = computeCoordsFromPlacement({ reference = reference, floating = floating }, "top-end")

		_x.assertEqual(_computedCoords.x, 50)
		_x.assertEqual(_computedCoords.y, -50)
	end)

	test("right", function()
		local _computedCoords = computeCoordsFromPlacement({ reference = reference, floating = floating }, "right")

		_x.assertEqual(_computedCoords.x, 100)
		_x.assertEqual(_computedCoords.y, 25)
	end)

	test("right-start", function()
		local _computedCoords =
			computeCoordsFromPlacement({ reference = reference, floating = floating }, "right-start")

		_x.assertEqual(_computedCoords.x, 100)
		_x.assertEqual(_computedCoords.y, 0)
	end)

	test("right-end", function()
		local _computedCoords = computeCoordsFromPlacement({ reference = reference, floating = floating }, "right-end")

		_x.assertEqual(_computedCoords.x, 100)
		_x.assertEqual(_computedCoords.y, 50)
	end)

	test("left", function()
		local _computedCoords = computeCoordsFromPlacement({ reference = reference, floating = floating }, "left")

		_x.assertEqual(_computedCoords.x, -50)
		_x.assertEqual(_computedCoords.y, 25)
	end)

	test("left-start", function()
		local _computedCoords = computeCoordsFromPlacement({ reference = reference, floating = floating }, "left-start")

		_x.assertEqual(_computedCoords.x, -50)
		_x.assertEqual(_computedCoords.y, 0)
	end)

	test("left-end", function()
		local _computedCoords = computeCoordsFromPlacement({ reference = reference, floating = floating }, "left-end")

		_x.assertEqual(_computedCoords.x, -50)
		_x.assertEqual(_computedCoords.y, 50)
	end)
end
