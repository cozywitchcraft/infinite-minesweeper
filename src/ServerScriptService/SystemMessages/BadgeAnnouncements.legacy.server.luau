--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Badges = require(ServerScriptService.Badges)
local Player = require(ReplicatedStorage.Util.Player)
local RemoteServer = require(ServerScriptService.RemoteServer)

local announced = RemoteServer.getRemoteEvent("Announced")

Badges.badgeAwarded:connect(function(player, badgeId)
	local badgeInfo = Badges.getBadgeInfo(badgeId)
	local displayName = Player.getDisplayName(player)

	if badgeInfo then
		announced:FireAllClients(`{displayName} earned badge '{badgeInfo.Name}!'`, "FFFF00")
	end
end)