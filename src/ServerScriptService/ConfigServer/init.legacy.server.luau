local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AdminIds = require(script.AdminIds)
local RemoteServer = require(script.Parent.RemoteServer)

local configChanged = RemoteServer.getRemoteEvent("ConfigChanged")
local configReset = RemoteServer.getRemoteEvent("ConfigReset")

local configFolder = ReplicatedStorage.Config

local defaultConfig = configFolder:GetAttributes()

configChanged.OnServerEvent:Connect(function(player, attribute, value)
	if not player:GetAttribute("Admin") then
		return
	end
	
	local previousValue = configFolder:GetAttribute(attribute)
	
	if typeof(previousValue) == typeof(value) then
		configFolder:SetAttribute(attribute, value)
	end
end)

configReset.OnServerEvent:Connect(function(player)
	if not player:GetAttribute("Admin") then
		return
	end
	
	for attribute, value in defaultConfig do
		configFolder:SetAttribute(attribute, value)
	end
end)

Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("Admin", AdminIds[player.UserId])
end)