--!strict
--[[

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DevPackages = ReplicatedStorage.DevPackages

local Midori = require(DevPackages.Midori)

Midori.runTests(script)
