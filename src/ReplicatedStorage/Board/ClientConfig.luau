--!strict

--[[
	Shared client config
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BoardConfig = require(script.Parent.BoardConfig)
local BoardTypes = require(script.Parent.BoardTypes)
local Signal = require(ReplicatedStorage.Util.Signal)

local ClientConfig = {
	config = BoardConfig.default(),
	changed = Signal.new(),
}

function ClientConfig.setConfig(config: BoardTypes.BoardConfig)
	ClientConfig.config.tileShape = config.tileShape
	ClientConfig.config.tileSize = config.tileSize
	ClientConfig.config.terrainIntensity = config.terrainIntensity
	ClientConfig.config.terrainDensity = config.terrainDensity
	ClientConfig.config.terrainSeed = config.terrainSeed
	ClientConfig.config.flagless = config.flagless
	ClientConfig.config.spheres = config.spheres
	ClientConfig.config.jumpless = config.jumpless
	ClientConfig.config.slippery = config.slippery
	ClientConfig.config.maxDistance = config.maxDistance

	ClientConfig.changed:fire()
end

return table.freeze(ClientConfig)
