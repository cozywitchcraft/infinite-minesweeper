local Types = require(script.Types)

export type Ok<T> = Types.Ok<T>
export type Err<E> = Types.Err<E>
export type Result<T, E> = Types.Result<T, E>
export type Transformer<T> = Types.Transformer<T>
export type GetAsyncResult = Types.GetAsyncResult
export type UpdateAsyncResult<T> = Types.UpdateAsyncResult<T>
export type DataInstance<T> = Types.DataInstance<T>
export type Store<T> = Types.Store<T>

return {
	Store = require(script.Store),
	getAsync = require(script.getAsync),
}