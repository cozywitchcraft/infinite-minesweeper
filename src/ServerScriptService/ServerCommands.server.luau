--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local TextService = game:GetService("TextService")

local Character = require(ReplicatedStorage.Util.Character)
local Player = require(ReplicatedStorage.Util.Player)
local RemoteServer = require(script.Parent.RemoteServer)
local Time = require(ReplicatedStorage.Util.Time)

type OnTriggeredCallback = (player: Player, unfilteredText: string) -> string

local announced = RemoteServer.getRemoteEvent("Announced")

local textChatCommands = TextChatService.TextChatCommands

local bannedIds = {}

local function addCommand(command: TextChatCommand, onTriggered: OnTriggeredCallback)
	command.Triggered:Connect(function(originTextSource, unfilteredText)
		local player = Players:GetPlayerByUserId(originTextSource.UserId)

		if not player then
			return
		end

		local message = onTriggered(player, unfilteredText)

		if message ~= "" then
			announced:FireClient(player, message)
		end
	end)
end

addCommand(textChatCommands.Rejoin, function(player)
	local teleportOptions = Instance.new('TeleportOptions')

	if #Players:GetPlayers() > 1 then
		teleportOptions.ServerInstanceId = game.JobId
	end

	TeleportService:TeleportAsync(game.PlaceId, { player }, teleportOptions)

	return ""
end)

addCommand(textChatCommands.Respawn, function(player)
	player:LoadCharacter()
	return ""
end)

addCommand(textChatCommands.Uptime, function()
	return "Server Uptime: " .. Time.formatTimeHours(time())
end)

addCommand(textChatCommands.Announce, function(player, unfilteredText)
	if not player:GetAttribute("Admin") then
		return "Insufficient permissions"
	end

	local unfilteredMessage = string.match(unfilteredText, "^/announce%s+(.+)$")

	if not unfilteredMessage then
		return "Invalid arg #1: expected string"
	end

	local success, result = pcall(function()
		return TextService:FilterStringAsync(unfilteredMessage, player.UserId, Enum.TextFilterContext.PublicChat)
	end)

	if not success then
		return "Error while filtering text"
	end

	local success2, message = pcall(function()
		return result:GetNonChatStringForBroadcastAsync()
	end)

	if not success2 then
		return "Error while filtering text"
	end

	announced:FireAllClients(message, "FFFF00")
	return ""
end)

addCommand(textChatCommands.Kill, function(player, unfilteredText)
	if not player:GetAttribute("Admin") then
		return "Insufficient permissions"
	end

	local name = string.match(unfilteredText, "^/kill%s+(.+)$")

	if not name then
		return "Invalid arg #1: expected string"
	end

	local player = Player.getPlayerByName(name)

	if not player then
		return `Cannot find player '{name}'`
	end

	local humanoid = Character.getHumanoid(player.Character)

	if not humanoid then
		return "Cannot kill " .. player.Name
	end

	humanoid.Health = 0

	return "Successfully killed " .. player.Name
end)

addCommand(textChatCommands.Kick, function(player, unfilteredText)
	if not player:GetAttribute("Admin") then
		return "Insufficient permissions"
	end

	local name = string.match(unfilteredText, "^/kick%s+(.+)$")

	if not name then
		return "Invalid arg #1: expected string"
	end

	local player = Player.getPlayerByName(name)

	if not player then
		return `Cannot find player '{name}'`
	end

	if player:GetAttribute("Admin") then
		return "Cannot kick another admin"
	end

	player:Kick("You have been kicked by a moderator.")

	return "Successfully kicked " .. player.Name
end)

addCommand(textChatCommands.Ban, function(player, unfilteredText)
	if not player:GetAttribute("Admin") then
		return "Insufficient permissions"
	end

	local name = string.match(unfilteredText, "^/ban%s+(.+)$")

	if not name then
		return "Invalid arg #1: expected string"
	end

	local player = Player.getPlayerByName(name)

	if not player then
		return `Cannot find player '{name}'`
	end

	if player:GetAttribute("Admin") then
		return "Cannot ban another admin"
	end

	bannedIds[player.UserId] = true

	player:Kick("You have been banned by a moderator.")

	return "Successfully banned " .. player.Name
end)

Players.PlayerAdded:Connect(function(player)
	if bannedIds[player.UserId] then
		player:Kick("You have been banned by a moderator.")
	end
end)
