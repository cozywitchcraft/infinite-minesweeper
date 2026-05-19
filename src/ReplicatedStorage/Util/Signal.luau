--!strict

export type Signal<T...> = {
	listeners: { [(T...) -> ()]: true },
	fire: (signal: Signal<T...>, T...) -> (),
	connect: (signal: Signal<T...>, listener: (T...) -> ()) -> () -> (),
	once: (signal: Signal<T...>, listener: (T...) -> ()) -> () -> (),
	wait: (signal: Signal<T...>) -> (T...),
}

local Signal = {}

function Signal.new<T...>(): Signal<T...>
	return {
		listeners = {},
		fire = Signal.fire,
		connect = Signal.connect,
		once = Signal.once,
		wait = Signal.wait,
	}
end

function Signal.fire<T...>(signal: Signal<T...>, ...: T...)
	for listener in signal.listeners do
		task.defer(listener, ...)
	end
end

function Signal.connect<T...>(signal: Signal<T...>, listener: (T...) -> ()): () -> ()
	signal.listeners[listener] = true

	return function()
		signal.listeners[listener] = nil
	end
end

function Signal.once<T...>(signal: Signal<T...>, listener: (T...) -> ()): () -> ()
	local disconnect: () -> ()

	disconnect = signal:connect(function(...)
		disconnect()
		listener(...)
	end)

	return disconnect
end

function Signal.wait<T...>(signal: Signal<T...>): T...
	local thread = coroutine.running()

	signal:once(function(...)
		task.spawn(thread, ...)
	end)

	return coroutine.yield()
end

return Signal