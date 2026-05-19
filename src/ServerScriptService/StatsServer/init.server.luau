local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataStore = require(script.Parent.PlayerDataStore)
local RemoteServer = require(ServerScriptService.RemoteServer)
local migrateStatsData = require(script.migrateStatsData)

local announced = RemoteServer.getRemoteEvent("Announced")

PlayerDataStore.dataLoaded:connect(function(dataInstance)
	local userId = tonumber(dataInstance.key)
	local player = userId and Players:GetPlayerByUserId(userId)

	if not player then
		return
	end

	if not dataInstance.metadata.statsMigrated then
		local result = migrateStatsData(dataInstance)

		if player.Parent == nil then
			warn(`Player left while migrating stats data (key={dataInstance.key})`)
			return
		end

		if result.type == "error" then
			announced:FireClient(player, "Failed to migrate stats data! Please rejoin.", "FF0000")
			warn(`Error while migrating shop data: {result.error} Key = {dataInstance.key}`)

			return
		end
		
		dataInstance.metadata.statsMigrated = true
	end
	
	player:SetAttribute("TimePlayed", dataInstance.data.timePlayed)
	player:SetAttribute("RoundsPlayed", dataInstance.data.roundsPlayed)
	player:SetAttribute("TilesShown", dataInstance.data.tilesShown)
	player:SetAttribute("MinesFlagged", dataInstance.data.minesFlagged)
	player:SetAttribute("LivesLost", dataInstance.data.livesLost)
	player:SetAttribute("JoinTime", workspace:GetServerTimeNow())
	
	dataInstance.beforeSave:connect(function()
		dataInstance.data.timePlayed += os.time() - dataInstance.keyInfo.UpdatedTime // 1000
	end)
end)