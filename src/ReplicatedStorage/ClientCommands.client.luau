--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Settings = require(ReplicatedStorage.Settings.Settings)
local announce = require(ReplicatedStorage.CoreGui.announce)

local textChatCommands = TextChatService:WaitForChild("TextChatCommands")

local placeVersionCommand = textChatCommands:WaitForChild("PlaceVersion")

local settings = Settings :: { [string]: Settings.Setting<any> }

type OnTriggeredCallback = (unfilteredText: string) -> string

local function addCommand(command: TextChatCommand, onTriggered: OnTriggeredCallback)
	command.Triggered:Connect(function(_, unfilteredText)
		local message = onTriggered(unfilteredText)

		if message ~= "" then
			announce(message)
		end
	end)
end

addCommand(placeVersionCommand, function()
	return "Place Version: " .. game.PlaceVersion
end)
