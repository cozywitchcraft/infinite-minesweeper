--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Attribute = require(ReplicatedStorage.Util.Attribute)
local DeathMessages = require(ReplicatedStorage.DeathMessages)
local Player = require(ReplicatedStorage.Util.Player)
local RemoteClient = require(ReplicatedStorage.Remote.RemoteClient)
local announce = require(script.Parent.announce)

local announced = RemoteClient.getRemoteEvent("Announced")
local lifeLost = RemoteClient.getRemoteEvent("LifeLost")
local restarting = RemoteClient.getRemoteEvent("Restarting")

announced.OnClientEvent:Connect(function(message: unknown, color: unknown)
	assert(typeof(message) == "string", "message must be a string")
	assert(color == nil or typeof(color) == "string", "color must be a string or nil")

	announce(message, color)
end)

lifeLost.OnClientEvent:Connect(function(player: unknown, index: unknown)
	assert(typeof(player) == "Instance" and player:IsA("Player"), "player must be a Player instance")
	assert(typeof(index) == "number", "index must be a number")

	local template = DeathMessages[index]
	assert(template ~= nil, `Template of index {index} could not be found`)

	local message = string.gsub(template, "%%s", Player.getDisplayName(player))

	local lives = Attribute.getNumber(workspace, "Lives")

	if lives > 1 and lives <= 3 then
		message ..= " " .. lives .. " lives left!"
	elseif lives == 1 then
		message ..= " 1 life left!"
	elseif lives == 0 then
		message ..= " Game over!"
	end

	announce(message, "ff0000")
end)

restarting.OnClientEvent:Connect(function(restartDelay: unknown)
	assert(typeof(restartDelay) == "number", "restartDelay must be a number")

	if restartDelay > 0 then
		announce("New round starts in " .. restartDelay .. " seconds.", "ffff00")
	end
end)
