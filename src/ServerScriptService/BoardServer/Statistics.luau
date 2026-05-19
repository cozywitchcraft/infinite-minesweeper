local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Attribute = require(ReplicatedStorage.Util.Attribute)
local PlayerDataStore = require(ServerScriptService.PlayerDataStore)
local RemoteServer = require(ServerScriptService.RemoteServer)

local coinsUpdated = RemoteServer.getRemoteEvent("CoinsUpdated")

local PlayerStats = {}

-- TODO: Change how coins are earned
function PlayerStats.incrementMinesFlagged(player: Player, flagCount: number)
	if not Attribute.getBoolean(workspace, "StatsEnabled") then
		return
	end

	local dataInstance = PlayerDataStore.getDataInstance(player)
	
	if dataInstance then
		dataInstance.data.coins += flagCount 
		dataInstance.data.minesFlagged += flagCount
		
		coinsUpdated:FireClient(player, dataInstance.data.coins)
		player:SetAttribute("MinesFlagged", dataInstance.data.minesFlagged)
	end
end

function PlayerStats.incrementTilesShown(player: Player, tileCount: number)
	if not Attribute.getBoolean(workspace, "StatsEnabled") then
		return
	end

	local dataInstance = PlayerDataStore.getDataInstance(player)

	if dataInstance then
		dataInstance.data.tilesShown += tileCount
		
		player:SetAttribute("TilesShown", dataInstance.data.tilesShown)
	end
end

function PlayerStats.incrementRoundsPlayed()
	if not Attribute.getBoolean(workspace, "StatsEnabled") then
		return
	end

	for _, player in Players:GetPlayers() do
		local dataInstance = PlayerDataStore.getDataInstance(player)

		if dataInstance then
			dataInstance.data.roundsPlayed += 1

			player:SetAttribute("RoundsPlayed", dataInstance.data.roundsPlayed)
		end
	end
end

function PlayerStats.incrementLivesLost(player: Player)
	if not Attribute.getBoolean(workspace, "StatsEnabled") then
		return
	end
	
	local dataInstance = PlayerDataStore.getDataInstance(player)

	if dataInstance then
		dataInstance.data.livesLost += 1
		
		player:SetAttribute("LivesLost", dataInstance.data.livesLost)
	end
end

return PlayerStats