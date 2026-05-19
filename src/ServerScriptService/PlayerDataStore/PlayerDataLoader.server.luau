--!strict
local Players = game:GetService("Players")

local PlayerDataStore = require(script.Parent)

local AUTOSAVE_DELAY = 300

Players.PlayerAdded:Connect(PlayerDataStore.addPlayer)
Players.PlayerRemoving:Connect(PlayerDataStore.removePlayer)

game:BindToClose(PlayerDataStore.close)

while task.wait(AUTOSAVE_DELAY) do
	PlayerDataStore.autosave()
end