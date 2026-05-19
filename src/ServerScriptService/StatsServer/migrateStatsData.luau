local DataStoreService = game:GetService("DataStoreService")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore = require(ServerScriptService.DataStore)
local PlayerData = require(ServerScriptService.Identity.PlayerData)

export type StatsData = {
	livesLost: number,
	minesFlagged: number,
	roundsPlayed: number,
	tilesShown: number,
	timePlayed: number,
}

local statsDataStore = DataStoreService:GetDataStore("StatsDataStore")

local function StatsData(data: any): StatsData?
	return if typeof(data) == "table" then data else nil
end

local function migrateStatsData(dataInstance: DataStore.DataInstance<PlayerData.PlayerData>):
	DataStore.Result<nil, string>
	
	local result = DataStore.getAsync(statsDataStore, dataInstance.key)

	if result.type == "error" then
		return result
	end

	local data = StatsData(result.result.data)

	if data ~= nil then
		dataInstance.data.livesLost = data.livesLost
		dataInstance.data.minesFlagged = data.minesFlagged
		dataInstance.data.roundsPlayed = data.roundsPlayed
		dataInstance.data.tilesShown = data.tilesShown
		dataInstance.data.timePlayed = data.timePlayed
	end

	return { type = "ok" }
end

return migrateStatsData