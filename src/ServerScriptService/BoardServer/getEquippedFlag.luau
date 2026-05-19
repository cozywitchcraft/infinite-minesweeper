--!strict

local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataStore = require(ServerScriptService.PlayerDataStore)

local function getEquippedFlag(player: Player): number?
	local dataInstance = PlayerDataStore.getDataInstance(player)
	
	return if dataInstance then dataInstance.data.flag else nil
end

return getEquippedFlag