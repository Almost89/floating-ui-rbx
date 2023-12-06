-- Copyright (c) 2021-present Floating UI contributors
--!strict

local getOppositeAxisPlacements = nil
do
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local Packages = ReplicatedStorage.Packages

	local utils = require(Packages["floating-ui-utils"])

	getOppositeAxisPlacements = utils.getOppositeAxisPlacements
end

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

return function(x)
	local describe: (string, () -> ()) -> (), test: (string, () -> ()) -> () = x.nested, x.test

	describe("side", function()
		test("top", function()
			assert(arraysAreEqual(getOppositeAxisPlacements("top", true, "start"), { "left", "right" }))
			assert(arraysAreEqual(getOppositeAxisPlacements("top", true, "end"), { "right", "left" }))
		end)

		test("bottom", function()
			assert(arraysAreEqual(getOppositeAxisPlacements("bottom", true, "start"), { "left", "right" }))
			assert(arraysAreEqual(getOppositeAxisPlacements("bottom", true, "end"), { "right", "left" }))
		end)

		test("left", function()
			assert(arraysAreEqual(getOppositeAxisPlacements("left", true, "start"), { "top", "bottom" }))
			assert(arraysAreEqual(getOppositeAxisPlacements("left", true, "end"), { "bottom", "top" }))
		end)

		test("right", function()
			assert(arraysAreEqual(getOppositeAxisPlacements("right", true, "start"), { "top", "bottom" }))
			assert(arraysAreEqual(getOppositeAxisPlacements("right", true, "end"), { "bottom", "top" }))
		end)
	end)

	describe("start alignment", function()
		test("top-start", function()
			assert(
				arraysAreEqual(getOppositeAxisPlacements("top-start", false, "start"), { "left-start", "right-start" })
			)
			assert(
				arraysAreEqual(getOppositeAxisPlacements("top-start", false, "end"), { "right-start", "left-start" })
			)
			assert(
				arraysAreEqual(
					getOppositeAxisPlacements("top-start", true, "start"),
					{ "left-start", "right-start", "left-end", "right-end" }
				)
			)
			assert(
				arraysAreEqual(
					getOppositeAxisPlacements("top-start", true, "end"),
					{ "right-start", "left-start", "right-end", "left-end" }
				)
			)
		end)

		test("bottom-start", function()
			assert(
				arraysAreEqual(
					getOppositeAxisPlacements("bottom-start", false, "start"),
					{ "left-start", "right-start" }
				)
			)
			assert(
				arraysAreEqual(getOppositeAxisPlacements("bottom-start", false, "end"), { "right-start", "left-start" })
			)
			assert(
				arraysAreEqual(
					getOppositeAxisPlacements("bottom-start", true, "start"),
					{ "left-start", "right-start", "left-end", "right-end" }
				)
			)
			assert(
				arraysAreEqual(
					getOppositeAxisPlacements("bottom-start", true, "end"),
					{ "right-start", "left-start", "right-end", "left-end" }
				)
			)
		end)

		test("left-start", function()
			assert(
				arraysAreEqual(getOppositeAxisPlacements("left-start", false, "start"), { "top-start", "bottom-start" })
			)
			assert(
				arraysAreEqual(getOppositeAxisPlacements("left-start", false, "end"), { "bottom-start", "top-start" })
			)
			assert(
				arraysAreEqual(
					getOppositeAxisPlacements("left-start", true, "start"),
					{ "top-start", "bottom-start", "top-end", "bottom-end" }
				)
			)
			assert(
				arraysAreEqual(
					getOppositeAxisPlacements("left-start", true, "end"),
					{ "bottom-start", "top-start", "bottom-end", "top-end" }
				)
			)
		end)

		test("right-start", function()
			assert(
				arraysAreEqual(
					getOppositeAxisPlacements("right-start", false, "start"),
					{ "top-start", "bottom-start" }
				)
			)
			assert(
				arraysAreEqual(getOppositeAxisPlacements("right-start", false, "end"), { "bottom-start", "top-start" })
			)
			assert(
				arraysAreEqual(
					getOppositeAxisPlacements("left-start", true, "start"),
					{ "top-start", "bottom-start", "top-end", "bottom-end" }
				)
			)
			assert(
				arraysAreEqual(
					getOppositeAxisPlacements("left-start", true, "end"),
					{ "bottom-start", "top-start", "bottom-end", "top-end" }
				)
			)
		end)
	end)

	describe("end alignment", function()
		test("top-end", function()
			assert(arraysAreEqual(getOppositeAxisPlacements("top-end", false, "start"), { "left-end", "right-end" }))
			assert(arraysAreEqual(getOppositeAxisPlacements("top-end", false, "end"), { "right-end", "left-end" }))
			assert(
				arraysAreEqual(
					getOppositeAxisPlacements("top-end", true, "start"),
					{ "left-end", "right-end", "left-start", "right-start" }
				)
			)
			assert(
				arraysAreEqual(
					getOppositeAxisPlacements("top-end", true, "end"),
					{ "right-end", "left-end", "right-start", "left-start" }
				)
			)
		end)

		test("bottom-end", function()
			assert(arraysAreEqual(getOppositeAxisPlacements("bottom-end", false, "start"), { "left-end", "right-end" }))
			assert(arraysAreEqual(getOppositeAxisPlacements("bottom-end", false, "end"), { "right-end", "left-end" }))
			assert(
				arraysAreEqual(
					getOppositeAxisPlacements("bottom-end", true, "start"),
					{ "left-end", "right-end", "left-start", "right-start" }
				)
			)
			assert(
				arraysAreEqual(
					getOppositeAxisPlacements("bottom-end", true, "end"),
					{ "right-end", "left-end", "right-start", "left-start" }
				)
			)
		end)

		test("left-end", function()
			assert(arraysAreEqual(getOppositeAxisPlacements("left-end", false, "start"), { "top-end", "bottom-end" }))
			assert(arraysAreEqual(getOppositeAxisPlacements("left-end", false, "end"), { "bottom-end", "top-end" }))
			assert(
				arraysAreEqual(
					getOppositeAxisPlacements("left-end", true, "start"),
					{ "top-end", "bottom-end", "top-start", "bottom-start" }
				)
			)
			assert(
				arraysAreEqual(
					getOppositeAxisPlacements("left-end", true, "end"),
					{ "bottom-end", "top-end", "bottom-start", "top-start" }
				)
			)
		end)

		test("right-end", function()
			assert(arraysAreEqual(getOppositeAxisPlacements("right-end", false, "start"), { "top-end", "bottom-end" }))
			assert(arraysAreEqual(getOppositeAxisPlacements("right-end", false, "end"), { "bottom-end", "top-end" }))
			assert(
				arraysAreEqual(
					getOppositeAxisPlacements("right-end", true, "start"),
					{ "top-end", "bottom-end", "top-start", "bottom-start" }
				)
			)
			assert(
				arraysAreEqual(
					getOppositeAxisPlacements("right-end", true, "end"),
					{ "bottom-end", "top-end", "bottom-start", "top-start" }
				)
			)
		end)
	end)

	describe("rtl", function()
		test("top", function()
			assert(arraysAreEqual(getOppositeAxisPlacements("top", true, "start", true), { "right", "left" }))
			assert(arraysAreEqual(getOppositeAxisPlacements("top", true, "end", true), { "left", "right" }))
		end)

		test("bottom", function()
			assert(arraysAreEqual(getOppositeAxisPlacements("bottom", true, "start", true), { "right", "left" }))
			assert(arraysAreEqual(getOppositeAxisPlacements("bottom", true, "end", true), { "left", "right" }))
		end)

		test("left", function()
			assert(arraysAreEqual(getOppositeAxisPlacements("left", true, "start", true), { "top", "bottom" }))
			assert(arraysAreEqual(getOppositeAxisPlacements("left", true, "end", true), { "bottom", "top" }))
		end)

		test("right", function()
			assert(arraysAreEqual(getOppositeAxisPlacements("right", true, "start", true), { "top", "bottom" }))
			assert(arraysAreEqual(getOppositeAxisPlacements("right", true, "end", true), { "bottom", "top" }))
		end)
	end)
end
