local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Settings = require(ReplicatedStorage.Settings.Settings)

local announcementsEnabled = Settings.announcementsEnabled

local textChannels = TextChatService:WaitForChild("TextChannels")
local rbxGeneral = textChannels:WaitForChild("RBXGeneral")

assert(rbxGeneral:IsA("TextChannel"), "expected TextChannel, got " .. rbxGeneral.ClassName)

local function announce(message: string, color: string?)
	color = color or "ffffff"

	if announcementsEnabled.value then
		rbxGeneral:DisplaySystemMessage("<font color=\"#" .. color .. "\">" .. message .. "</font>")
	end
end

return announce
