--!strict

--[[
	Limits requests within a fixed timeframe
]]

export type RequestCounter = {
	requestCount: number,
	timestamp: number,
}

export type RateLimit = {
	maxRequests: number,
	interval: number,
	requestCounters: { [Player]: RequestCounter },
}

local function newRequestCounter(): RequestCounter
	return {
		requestCount = 0,
		timestamp = 0,
	}
end

local RateLimit = {}

function RateLimit.new(maxRequests: number, interval: number): RateLimit
	return {
		maxRequests = maxRequests,
		interval = interval,
		requestCounters = {},
	}
end

function RateLimit.addPlayer(rateLimit: RateLimit, player: Player)
	if rateLimit.requestCounters[player] then
		return
	end

	rateLimit.requestCounters[player] = newRequestCounter()
end

function RateLimit.removePlayer(rateLimit: RateLimit, player: Player)
	rateLimit.requestCounters[player] = nil
end

function RateLimit.checkRequest(rateLimit: RateLimit, player: Player): boolean
	local requestCounter = rateLimit.requestCounters[player]

	if not requestCounter then
		return false
	end

	local now = tick()

	if now - requestCounter.timestamp >= rateLimit.interval then
		requestCounter.requestCount = 0
		requestCounter.timestamp = now
	end

	if requestCounter.requestCount < rateLimit.maxRequests then
		requestCounter.requestCount += 1
		return true
	else
		return false
	end
end

return RateLimit
