local DataStoreService = game:GetService("DataStoreService")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore = require(ServerScriptService.DataStore)
local PlayerData = require(ServerScriptService.Identity.PlayerData)
local resetInvalidSettings = require(ServerScriptService.Migrators.resetInvalidSettings)
local updateSettings = require(ServerScriptService.Migrators.updateSettings)

local settingsDataStore = DataStoreService:GetDataStore("SettingsDataStore")

local function SettingsData(data: any): { [string]: any }?
	return if typeof(data) == "table" then data else nil
end

local function migrateSettingsData(dataInstance: DataStore.DataInstance<PlayerData.PlayerData>):
	DataStore.Result<nil, string>
	
	local result = DataStore.getAsync(settingsDataStore, dataInstance.key)

	if result.type == "error" then
		return result
	end
	
	local data = SettingsData(result.result.data)

	if data ~= nil then
		dataInstance.data.settings = resetInvalidSettings(updateSettings(data))
	end

	return { type = "ok" }
end

return migrateSettingsData