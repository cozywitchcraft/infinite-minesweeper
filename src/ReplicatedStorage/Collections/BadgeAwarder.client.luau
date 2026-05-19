local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local RemoteClient = require(ReplicatedStorage.Remote.RemoteClient)

local badgeAwarded = RemoteClient.getRemoteEvent("BadgeAwarded")

local localPlayer = assert(Players.LocalPlayer, "LocalPlayer is nil")

CollectionService:GetInstanceAddedSignal("BadgeAwarder"):Connect(function(part)	
	part.Touched:Connect(function(hit)
		if hit.Parent == localPlayer.Character then
			badgeAwarded:FireServer()
		end
	end)
end)