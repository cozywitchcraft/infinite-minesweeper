local DataStoreService = game:GetService("DataStoreService")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore = require(ServerScriptService.DataStore)
local PlayerData = require(ServerScriptService.Identity.PlayerData)
local convertFlagId = require(ServerScriptService.Migrators.convertFlagId)
local convertInventory = require(ServerScriptService.Migrators.convertInventory)

export type ShopData = {
	coins: number,
	flag: string,
	inventory: { string },
}

local shopDataStore = DataStoreService:GetDataStore("ShopDataStore")

local function ShopData(data: any): ShopData?
	return if typeof(data) == "table" then data else nil
end

local function migrateShopData(dataInstance: DataStore.DataInstance<PlayerData.PlayerData>):
	DataStore.Result<nil, string>
	
	local result = DataStore.getAsync(shopDataStore, dataInstance.key)

	if result.type == "error" then
		return result
	end

	local data = ShopData(result.result.data)

	if data ~= nil then
		dataInstance.data.coins = data.coins
		dataInstance.data.flag = convertFlagId(data.flag)
		dataInstance.data.inventory = convertInventory(data.inventory)
	end

	return { type = "ok" }
end

return migrateShopData