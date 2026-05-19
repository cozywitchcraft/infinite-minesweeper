local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ItemData = require(ReplicatedStorage.ItemData)
local PlayerDataStore = require(script.Parent.PlayerDataStore)
local RemoteServer = require(ServerScriptService.RemoteServer)
local migrateShopData = require(script.migrateShopData)

local announced = RemoteServer.getRemoteEvent("Announced")
local coinsUpdated = RemoteServer.getRemoteEvent("CoinsUpdated")
local flagUpdated = RemoteServer.getRemoteEvent("FlagUpdated")
local inventoryLoaded = RemoteServer.getRemoteEvent("InventoryLoaded")
local requestItem = RemoteServer.getRemoteFunction("RequestItem")

function requestItem.OnServerInvoke(player, itemId: unknown): (boolean, string|number)
	assert(typeof(itemId) == "number", "itemId must be a number")
	
	local dataInstance = PlayerDataStore.getDataInstance(player)

	if not dataInstance then
		return false, "Unable to get data"
	end

	local item = ItemData[itemId + 1]

	if not item then
		return false, `Unable to get item {itemId}`
	end
	
	local data = dataInstance.data

	if table.find(data.inventory, itemId) then
		data.flag = itemId
	elseif item.offsale then
		return false, "Item is currently offsale"
	elseif data.coins >= item.price then
		table.insert(data.inventory, itemId)

		data.coins -= item.price
		data.flag = itemId
		
		coinsUpdated:FireClient(player, data.coins)
	else
		return false, "Not enough currency!"
	end
	
	flagUpdated:FireClient(player, data.flag)

	return true, itemId
end

PlayerDataStore.dataLoaded:connect(function(dataInstance)
	local userId = tonumber(dataInstance.key)
	local player = userId and Players:GetPlayerByUserId(userId)

	if not player then
		return
	end

	if not dataInstance.metadata.shopMigrated then
		local result = migrateShopData(dataInstance)
		
		if player.Parent == nil then
			warn(`Player left while migrating shop data (key={dataInstance.key})`)
			return
		end

		if result.type == "error" then
			announced:FireClient(player, "Failed to migrate shop data! Please rejoin.", "FF0000")
			warn(`Error while migrating shop data: {result.error} Key = {dataInstance.key}`)

			return
		end

		dataInstance.metadata.shopMigrated = true
	end

	coinsUpdated:FireClient(player, dataInstance.data.coins)
	flagUpdated:FireClient(player, dataInstance.data.flag)
	inventoryLoaded:FireClient(player, dataInstance.data.inventory)
end)