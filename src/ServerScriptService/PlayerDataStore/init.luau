--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore = require(script.Parent.DataStore)
local PlayerData = require(script.Parent.Identity.PlayerData)
local RemoteServer = require(ServerScriptService.RemoteServer)
local Signal = require(ReplicatedStorage.Util.Signal)

local announced = RemoteServer.getRemoteEvent("Announced")

local playerDataStore = DataStore.Store.new("PlayerDataStore", PlayerData)
local dataLoaded: Signal.Signal<DataStore.DataInstance<PlayerData.PlayerData>> = Signal.new()

local PlayerDataStore = {
	store = playerDataStore,
	dataLoaded = dataLoaded,
}

function PlayerDataStore.addPlayer(player: Player)
	local result = playerDataStore:loadAsync(tostring(player.UserId))
	
	if result.type == "error" then
		announced:FireClient(player, "Failed to load player data! Please rejoin.")
		
		warn("Error while loading player data:", result.error)
		
		return
	end
	
	result.result:addUserId(player.UserId)
	
	if player.Parent == nil then
		local _result = result.result:releaseAsync()
		
		if _result.type == "error" then
			warn("Error while releasing player data:", _result.error)
		end
		
		return
	end
	
	dataLoaded:fire(result.result)
end

function PlayerDataStore.removePlayer(player: Player)
	local dataInstance = PlayerDataStore.getDataInstance(player)
	
	if dataInstance == nil then
		return
	end
	
	local result = dataInstance:releaseAsync()
	
	if result.type == "error" then
		warn("Error while releasing player data:", result.error)
	end
end

function PlayerDataStore.getDataInstance(player: Player): DataStore.DataInstance<PlayerData.PlayerData>?
	return playerDataStore:get(tostring(player.UserId))
end

function PlayerDataStore.autosave()
	playerDataStore:saveAll(function(result)
		if result.type == "error" then
			warn("Error while releasing player data:", result.error)
		end
	end)
end

function PlayerDataStore.close()
	if RunService:IsStudio() then
		return
	end
	
	playerDataStore:releaseAll(function(result)
		if result.type == "error" then
			warn("Error while releasing data: ", result.error)
		end
	end)
	
	playerDataStore:waitUntilSaved()
end

return table.freeze(PlayerDataStore)