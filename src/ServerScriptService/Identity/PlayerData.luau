--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local convertFlagId = require(ServerScriptService.Migrators.convertFlagId)
local convertInventory = require(ServerScriptService.Migrators.convertInventory)
local resetInvalidSettings = require(ServerScriptService.Migrators.resetInvalidSettings)
local updateSettings = require(ServerScriptService.Migrators.updateSettings)
local isEmpty = require(ReplicatedStorage.Util.isEmpty)

local DEFAULT_FLAG = 0

export type PlayerData = {
	coins: number,
	flag: number,
	inventory: { number },
	livesLost: number,
	minesFlagged: number,
	roundsPlayed: number,
	settings: { [string]: any },
	tilesShown: number,
	timePlayed: number,
}

local function createPlayerData(): PlayerData
	return {
		coins = 0,
		flag = 0,
		inventory = { DEFAULT_FLAG },
		livesLost = 0,
		minesFlagged = 0,
		roundsPlayed = 0,
		settings = {},
		tilesShown = 0,
		timePlayed = 0,
	}
end

local function createMetadata(): { [string]: any }
	return {
		flagsMigrated = true,
		idsFixed = true,
		settingsUpdated = true,
	}
end

local function PlayerData(data: any, keyInfo: DataStoreKeyInfo?): (PlayerData?, { any }?, { [string]: any }?)
	if keyInfo == nil then
		return createPlayerData(), nil, createMetadata()
	end

	if typeof(data) ~= "table" then
		return nil, nil, nil
	end
	
	-- Defaults weren't set
	if isEmpty(data) then
		return createPlayerData(), nil, createMetadata()
	end
	
	local metadata = keyInfo:GetMetadata()

	if not metadata.flagsMigrated then
		data.flag = convertFlagId(data.flag)
		data.inventory = convertInventory(data.inventory)
			
		metadata.flagsMigrated = true
		metadata.idsFixed = true
	end

	if not metadata.settingsUpdated then
		data.settings = updateSettings(data.settings)
		
		metadata.settingsUpdated = true
	end

	data.settings = resetInvalidSettings(data.settings)

	return data, keyInfo:GetUserIds(), metadata
end

return PlayerData