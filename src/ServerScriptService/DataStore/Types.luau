--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Util.Signal)

export type Ok<T> = { type: "ok", result: T }
export type Err<E> = { type: "error", error: E }
export type Result<T, E> = Ok<T> | Err<E>

export type Transformer<T> = (any, DataStoreKeyInfo?) -> (T?, { any }?, { [string]: any }?)

export type GetAsyncResult = {
	data: any,
	keyInfo: DataStoreKeyInfo?,
}

export type UpdateAsyncResult<T> = {
	data: T?,
	keyInfo: DataStoreKeyInfo?,
}

export type DataInstance<T> = {
	store: Store<T>,
	key: string,
	data: T,
	keyInfo: DataStoreKeyInfo,
	metadata: { [string]: any },
	userIds: { any },
	beforeSave: Signal.Signal<>,
	beforeRelease: Signal.Signal<>,
	saveAsync: (self: DataInstance<T>) -> Result<nil, string>,
	releaseAsync: (self: DataInstance<T>) -> Result<nil, string>,
	addUserId: (self: DataInstance<T>, userId: number) -> (),
	removeUserId: (self: DataInstance<T>, userId: number) -> (),
}

export type Store<T> = {
	dataStore: DataStore,
	dataInstances: { [string]: DataInstance<T> },
	dataSaving: number,
	dataSaved: Signal.Signal<>,
	identity: Transformer<T>,
	get: (self: Store<T>, key: string) -> DataInstance<T>?,
	loadAsync: (self: Store<T>, key: string) -> Result<DataInstance<T>, string>,
	saveAll: (self: Store<T>, andThen: (Result<nil, string>) -> ()) -> (),
	releaseAll: (self: Store<T>, andThen: (Result<nil, string>) -> ()) -> (),
	waitUntilSaved: (self: Store<T>) -> (),
}

return nil