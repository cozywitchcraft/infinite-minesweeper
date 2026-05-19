--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Character = require(ReplicatedStorage.Util.Character)

local localPlayer = assert(Players.LocalPlayer, "expected Player, got nil")
local mouse = localPlayer:GetMouse()

local tool = script.Parent

tool.Activated:Connect(function()
	if mouse.Target then
		Character.teleport(localPlayer.Character, CFrame.new(mouse.Hit.Position))
	end
end)