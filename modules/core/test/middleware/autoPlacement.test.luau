-- Copyright (c) 2021-present Floating UI contributors
--!strict

local _ReplicatedStorage = game:GetService("ReplicatedStorage")

local _Packages = _ReplicatedStorage.Packages

-- FIXME: unsafe import
local getPlacementList = require(_Packages["floating-ui-core"].middleware.autoPlacement).getPlacementList

local function arraysAreEqual(a: { any }, b: { any }): (boolean, string?)
	if #a ~= #b then
		return false,
			`arrays are not equal: length difference #a={#a} #b={#b}\n\na={game:GetService("HttpService"):JSONEncode(a)}\n\nb={game:GetService("HttpService")
				:JSONEncode(b)}`
	end
	for index, aValue in a do
		local bValue = b[index]
		if aValue ~= bValue then
			return false, `arrays are not equal: value difference a[{index}]={aValue} b[{index}]={bValue}`
		end
	end
	return true
end

return function(_x)
	local test: (string, () -> ()) -> () = _x.test

	test("base placement", function()
		assert(arraysAreEqual(
			getPlacementList(nil, false, {
				"top",
				"bottom",
				"left",
				"right",
				"top-start",
				"right-end",
			}),
			{ "top", "bottom", "left", "right" }
		))
	end)

	test("start alignment without auto alignment", function()
		assert(arraysAreEqual(
			getPlacementList("start", false, {
				"top",
				"bottom",
				"left",
				"right",
				"top-start",
				"right-end",
				"left-start",
			}),
			{ "top-start", "left-start" }
		))
	end)

	test("start alignment with auto alignment", function()
		assert(arraysAreEqual(
			getPlacementList("start", true, {
				"top",
				"bottom",
				"left",
				"right",
				"top-start",
				"right-end",
				"left-start",
			}),
			{ "top-start", "left-start", "right-end" }
		))
	end)

	test("end alignment without auto alignment", function()
		assert(arraysAreEqual(
			getPlacementList("end", false, {
				"top",
				"bottom",
				"left",
				"right",
				"top-start",
				"right-end",
				"left-start",
			}),
			{ "right-end" }
		))
	end)

	test("end alignment with auto alignment", function()
		assert(arraysAreEqual(
			getPlacementList("end", true, {
				"top",
				"bottom",
				"left",
				"right",
				"top-start",
				"right-end",
				"left-start",
			}),
			{ "right-end", "top-start", "left-start" }
		))
	end)
end
