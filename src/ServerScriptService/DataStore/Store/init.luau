--!strict
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataInstance = require(script.DataInstance)
local Signal = require(ReplicatedStorage.Util.Signal)
local Types = require(script.Parent.Types)
local updateAsync = require(script.updateAsync)

export type Result<T, E> = Types.Result<T, E>
export type Transformer<T> = Types.Transformer<T>
export type DataInstance<T> = Types.DataInstance<T>
export type Store<T> = Types.Store<T>

local Store = {}

function Store.new<T>(name: string, identity: Transformer<T>): Store<T>
	return {
		dataStore = DataStoreService:GetDataStore(name),
		dataInstances = {},
		dataSaving = 0,
		dataSaved = Signal.new(),
		identity = identity,
		get = Store.get,
		loadAsync = Store.loadAsync,
		saveAll = Store.saveAll,
		releaseAll = Store.releaseAll,
		waitUntilSaved = Store.waitUntilSaved,
	}
end

function Store.get<T>(self: Store<T>, key: string): DataInstance<T>?
	return self.dataInstances[key]
end

function Store.loadAsync<T>(self: Store<T>, key: string): Result<DataInstance<T>, string>
	local result = updateAsync(self.dataStore, key, self.identity)
	
	if result.type == "error" then
		return result
	end
	
	-- TODO: Revert corrupted data
	if result.result.data == nil then
		return {
			type = "error",
			error = "Data is corrupted. Key = " .. key,
		}
	end
	
	local dataInstance = DataInstance.new(self, key, result.result)
	self.dataInstances[key] = dataInstance
	
	return {
		type = "ok",
		result = dataInstance,
	}
end

function Store.saveAll<T>(self: Store<T>, andThen: (Result<nil, string>) -> ())
	for _, dataInstance in self.dataInstances do
		task.spawn(function()
			andThen(dataInstance:saveAsync())
		end)
	end
end

function Store.releaseAll<T>(self: Store<T>, andThen: (Result<nil, string>) -> ())
	for _, dataInstance in self.dataInstances do
		task.spawn(function()
			andThen(dataInstance:releaseAsync())
		end)
	end
end

function Store.waitUntilSaved<T>(self: Store<T>)
	while self.dataSaving > 0 do
		self.dataSaved:wait()
	end
end

return table.freeze(Store)