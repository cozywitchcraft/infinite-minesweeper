--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local StarterPack = game:GetService("StarterPack")

local Attribute = require(ReplicatedStorage.Util.Attribute)
local removeTool = require(script.Parent.removeTool)

local configFolder = ReplicatedStorage.Config

local teleportTool = ServerStorage.Tools.Teleport

local function giveTeleport()
	if StarterPack:FindFirstChild("Teleport") then
		return
	end
	
	teleportTool:Clone().Parent = StarterPack
	
	for _, player in Players:GetPlayers() do
		teleportTool:Clone().Parent = player.Backpack
	end
end

local function removeTeleport()
	local tool = StarterPack:FindFirstChild("Teleport")
	
	if tool then
		tool:Destroy()
	end
	
	for _, player in Players:GetPlayers() do
		removeTool(player, "Teleport")
	end
end

configFolder:GetAttributeChangedSignal("TeleportEnabled"):Connect(function()
	if Attribute.getBoolean(configFolder, "TeleportEnabled") then
		giveTeleport()
	else
		removeTeleport()
	end
end)