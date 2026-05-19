local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DefaultSettings = require(ReplicatedStorage.Settings.DefaultSettings)
local PlayerDataStore = require(script.Parent.PlayerDataStore)
local RemoteServer = require(ServerScriptService.RemoteServer)
local Serdes = require(ReplicatedStorage.Settings.Serdes)
local migrateSettingsData = require(script.migrateSettingsData)

local announced = RemoteServer.getRemoteEvent("Announced")
local settingsReset = RemoteServer.getRemoteEvent("SettingsReset")
local settingsLoaded = RemoteServer.getRemoteEvent("SettingsLoaded")
local settingUpdated = RemoteServer.getRemoteEvent("SettingUpdated")

local defaultSettings = DefaultSettings :: { [string]: any }

settingUpdated.OnServerEvent:Connect(function(player, settingName: unknown, value: unknown)
	assert(typeof(settingName) == "string", "settingName must be string")
	
	if value ~= value or (typeof(value) == "number" and math.abs(value) == math.huge) then
		return
	end

	local defaultValue = defaultSettings[settingName]

	if typeof(defaultValue) ~= typeof(value) then
		return
	end

	local dataInstance = PlayerDataStore.getDataInstance(player)

	if dataInstance then
		dataInstance.data.settings[settingName] = Serdes.serialize(value)
	end
end)

settingsReset.OnServerEvent:Connect(function(player)
	local dataInstance = PlayerDataStore.getDataInstance(player)

	if dataInstance then
		table.clear(dataInstance.data.settings)
	end
end)

PlayerDataStore.dataLoaded:connect(function(dataInstance)
	local userId = tonumber(dataInstance.key)
	local player = userId and Players:GetPlayerByUserId(userId)
	
	if not player then
		return
	end
	
	if not dataInstance.metadata.settingsMigrated then
		local result = migrateSettingsData(dataInstance)
		
		if player.Parent == nil then
			warn(`Player left while migrating settings data (key={dataInstance.key})`)
			return
		end
		
		if result.type == "error" then
			announced:FireClient(player, "Failed to migrate settings data! Please rejoin.", "FF0000")
			warn(`Error while migrating settings data: {result.error} Key = {dataInstance.key}`)
			
			return
		end
		
		dataInstance.metadata.settingsMigrated = true
	end
	
	settingsLoaded:FireClient(player, dataInstance.data.settings)
end)