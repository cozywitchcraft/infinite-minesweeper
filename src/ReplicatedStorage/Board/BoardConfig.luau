--!strict

--[[
	Functions for config serdes
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BoardTypes = require(script.Parent.BoardTypes)
local Sera = require(ReplicatedStorage.Sera)
local TileShape = require(script.Parent.Enum.TileShape)

local configSchema = Sera.Schema({
	tileShape = Sera.Uint8,
	tileSize = Sera.Float64,
	terrainDensity = Sera.Float64,
	terrainIntensity = Sera.Float64,
	terrainSeed = Sera.Float64,
	flagless = Sera.Boolean,
	jumpless = Sera.Boolean,
	slippery = Sera.Boolean,
	spheres = Sera.Boolean,
	maxDistance = Sera.Float64,
})

local BoardConfig = {}

function BoardConfig.default(): BoardTypes.BoardConfig
	return {
		tileShape = TileShape.SQUARE,
		tileSize = 5,
		terrainDensity = 1,
		terrainIntensity = 0,
		terrainSeed = 0,
		flagless = false,
		jumpless = false,
		slippery = false,
		spheres = false,
		maxDistance = 32,
	}
end

function BoardConfig.serialize(config: BoardTypes.BoardConfig): (buffer?, string?)
	return Sera.Serialize(configSchema, config)
end

function BoardConfig.deserialize(b: buffer, offset: number?): (BoardTypes.BoardConfig, number)
	local config, size = Sera.Deserialize(configSchema, b, offset)
	return config :: BoardTypes.BoardConfig, size
end

return BoardConfig
