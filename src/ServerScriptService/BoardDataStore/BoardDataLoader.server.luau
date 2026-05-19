local Players = game:GetService("Players")

local BoardDataStore = require(script.Parent)

local AUTOSAVE_DELAY = 300

if game.PrivateServerOwnerId ~= 0 then
	Players.PlayerAdded:Once(BoardDataStore.open)

	game:BindToClose(BoardDataStore.close)

	while task.wait(AUTOSAVE_DELAY) do
		BoardDataStore.autosave()
	end
end