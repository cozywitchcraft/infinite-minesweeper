--!strict
local DataStoreService = game:GetService("DataStoreService")

local Constants = require(script.Parent.Parent.Constants)
local Types = require(script.Parent.Parent.Types)

type Result<T, E> = Types.Result<T, E>
type Transformer<T> = Types.Transformer<T>
type UpdateAsyncResult<T> = Types.UpdateAsyncResult<T>

local function tryUpdate<T>(dataStore: DataStore, key: string, transformer: Transformer<T>):
	Result<UpdateAsyncResult<T>, string>
	
	local budget = DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync)
	
	if budget < Constants.MIN_BUDGET then
		task.wait(Constants.FLOOD_DELAY)
	end
	
	local success, data, keyInfo = pcall(function()
		return dataStore:UpdateAsync(key, transformer)
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
		},
	}
end

local function updateAsync<T>(dataStore: DataStore, key: string, transformer: Transformer<T>):
	Result<UpdateAsyncResult<T>, string>
	
	local result: Result<UpdateAsyncResult<T>, string>
	
	for _ = 1, Constants.MAX_TRIES do
		result = tryUpdate(dataStore, key, transformer)
		
		if result.type == "ok" then
			break
		end
		
		task.wait(Constants.RETRY_DELAY)
	end
	
	return result
end

return updateAsync