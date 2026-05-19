--!strict

export type Pool<T, U...> = {
	create: () -> T,
	onUse: (object: T, U...) -> (),
	allocate: (pool: Pool<T, U...>, count: number) -> (),
	use: (pool: Pool<T, U...>, U...) -> (),
	objects: { T },
	index: number,
}

local Pool = {}

function Pool.new<T, U...>(create: () -> T, onUse: (object: T, U...) -> ()): Pool<T, U...>
	return {
		create = create,
		onUse = onUse,
		allocate = Pool.allocate,
		use = Pool.use,
		objects = {},
		index = 1,
	}
end

function Pool.allocate<T, U...>(pool: Pool<T, U...>, count: number)
	for _ = 1, count do
		table.insert(pool.objects, pool.create())
	end
end

function Pool.use<T, U...>(pool: Pool<T, U...>, ...: U...)
	local object = pool.objects[pool.index]
	pool.onUse(object, ...)

	pool.index += 1

	if pool.index > #pool.objects then
		pool.index = 1
	end
end

return Pool
