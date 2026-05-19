local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Explosions = require(ReplicatedStorage.Explosions)

local localPlayer = assert(Players.LocalPlayer, "expected Player, got nil")

local mouse = localPlayer:GetMouse()

script.Parent.Activated:Connect(function()
	Explosions.add(mouse.Hit.Position)
end)