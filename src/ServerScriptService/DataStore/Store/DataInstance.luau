--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Util.Signal)
local Types = require(script.Parent.Parent.Types)
local updateAsync = require(script.Parent.updateAsync)

type Result<T, E> = Types.Result<T, E>
type DataInstance<T> = Types.DataInstance<T>
type Transformer<T> = Types.Transformer<T>
type UpdateAsyncResult<T> = Types.UpdateAsyncResult<T>
type Store<T> = Types.Store<T>

local function checkVersion<T>(self: DataInstance<T>, keyInfo: DataStoreKeyInfo?): (T?, { any }?, { [string]: any }?)
	if keyInfo ~= nil and keyInfo.Version == self.keyInfo.Version then
		return self.data, self.userIds, self.metadata
	end

	return nil, nil, nil
end

local DataInstance = {}

function DataInstance.new<T>(store: Store<T>, key: string, result: UpdateAsyncResult<T>): DataInstance<T>
	assert(result.keyInfo ~= nil, "keyInfo is nil")
	
	return {
		store = store,
		key = key,
		data = result.data,
		keyInfo = result.keyInfo,
		metadata = result.keyInfo:GetMetadata(),
		userIds = result.keyInfo:GetUserIds(),
		beforeSave = Signal.new(),
		beforeRelease = Signal.new(),
		saveAsync = DataInstance.saveAsync,
		releaseAsync = DataInstance.releaseAsync,
		addUserId = DataInstance.addUserId,
		removeUserId = DataInstance.removeUserId,
	}
end

function DataInstance.saveAsync<T>(self: DataInstance<T>): Result<nil, string>
	self.store.dataSaving += 1
	self.beforeSave:fire()

	local result = updateAsync(self.store.dataStore, self.key, function(_, keyInfo)
		return checkVersion(self, keyInfo)
	end)
	
	self.store.dataSaving -= 1
	self.store.dataSaved:fire()
	
	if result.type == "error" then
		return result
	end
	
	if result.result.keyInfo == nil then
		return {
			type = "error",
			error = "Version check failed. Key = " .. self.key,
		}
	end
	
	self.keyInfo = result.result.keyInfo
	
	return { type = "ok" }
end

function DataInstance.releaseAsync<T>(self: DataInstance<T>): Result<nil, string>
	if self.store.dataInstances[self.key] == nil then
		return {
			type = "error",
			error = "Can't release data more than once. Key = " .. self.key,
		}
	end
	
	self.store.dataInstances[self.key] = nil
	self.beforeRelease:fire()
	
	return self:saveAsync()
end

function DataInstance.addUserId<T>(self: DataInstance<T>, userId: number)
	if not table.find(self.userIds, userId) then
		table.insert(self.userIds, userId)
	end
end

function DataInstance.removeUserId<T>(self: DataInstance<T>, userId: number)
	local index = table.find(self.userIds, userId)
	
	if index then
		table.remove(self.userIds, index)
	end
end

return table.freeze(DataInstance)