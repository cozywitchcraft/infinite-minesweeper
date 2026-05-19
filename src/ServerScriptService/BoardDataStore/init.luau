local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local Attribute = require(ReplicatedStorage.Util.Attribute)
local BoardData = require(script.Parent.Identity.BoardData)
local DataStore = require(script.Parent.DataStore)
local RemoteServer = require(ServerScriptService.RemoteServer)
local Signal = require(ReplicatedStorage.Util.Signal)

local announced = RemoteServer.getRemoteEvent("Announced")

local boardDataStore = DataStore.Store.new("BoardDataStore", BoardData)

local BoardDataStore = {
	loaded = Signal.new(),
}

function BoardDataStore.open()
	local result = boardDataStore:loadAsync(tostring(game.PrivateServerOwnerId))
	
	if result.type == "error" then
		announced:FireAllClients("Error while loading board data! Please restart the server.", "FF0000")
		
		warn("Error while loading board data:", result.error)
		
		return
	end
	
	result.result:addUserId(game.PrivateServerOwnerId)
	
	BoardDataStore.loaded:fire()
end

function BoardDataStore.getDataInstance(): DataStore.DataInstance<BoardData.BoardData>?
	return boardDataStore:get(tostring(game.PrivateServerOwnerId))
end

function BoardDataStore.autosave()
	local dataInstance = BoardDataStore.getDataInstance()
	
	if dataInstance then
		local result = dataInstance:saveAsync()
		
		if result.type == "error" then
			warn("Error while saving board data:", result.error)
		end
	end
end

function BoardDataStore.close()
	if RunService:IsStudio() then
		return
	end
	
	local dataInstance = BoardDataStore.getDataInstance()

	if dataInstance then
		local result = dataInstance:releaseAsync()

		if result.type == "error" then
			warn("Error while releasing board data:", result.error)
		end
	end
end

return table.freeze(BoardDataStore)