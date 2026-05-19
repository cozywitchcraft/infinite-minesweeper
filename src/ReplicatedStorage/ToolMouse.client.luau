--!strict
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

local MOUSE_DISABLED = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
local MOUSE_ENABLED = "rbxasset://textures/Cursors/KeyboardMouse/ArrowCursor.png"

local localPlayer = assert(Players.LocalPlayer, "LocalPlayer is nil")
local mouse = localPlayer:GetMouse()

local connection: RBXScriptConnection

local function onLocalToolEquipped()
	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")

	if not tool then
		return
	end

	connection = tool:GetPropertyChangedSignal("Enabled"):Connect(function()
		mouse.Icon = if tool.Enabled then MOUSE_ENABLED else MOUSE_DISABLED
	end)
end

local function onLocalToolUnequipped()
	mouse.Icon = ""

	if connection and connection.Connected then
		connection:Disconnect()
	end
end

ContextActionService.LocalToolEquipped:Connect(onLocalToolEquipped)
ContextActionService.LocalToolUnequipped:Connect(onLocalToolUnequipped)
