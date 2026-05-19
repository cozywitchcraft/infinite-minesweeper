local DataStoreService = game:GetService("DataStoreService")

local Constants = require(script.Parent.Constants)
local Types = require(script.Parent.Types)

local function getAsync(dataStore: DataStore, key: string): Types.Result<Types.GetAsyncResult, string>
	local budget = DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)
	
	if budget < Constants.MIN_BUDGET then
		task.wait(Constants.FLOOD_DELAY)
	end
	
	local success, data, keyInfo = pcall(function()
		return dataStore:GetAsync(key)
	end)
	
	if not success then
		return {
			type = "error",
			error = data,
		}
	end
	
	return {
		type = "ok",
		result = {
			data = data,
			keyInfo = keyInfo,
		}
	}
end

return getAsync