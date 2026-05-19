--!strict
--!native

--[[
	Functions for converting between grid and world position
]]

local TileShape = require(script.Parent.Enum.TileShape)

local HEX_TO_WORLD = CFrame.fromMatrix(
	Vector3.zero,
	Vector3.xAxis,
	Vector3.zero,
	Vector3.new(0.5, 0, math.sqrt(3) / 2)
)

local WORLD_TO_HEX = CFrame.fromMatrix(
	Vector3.zero,
	Vector3.xAxis,
	Vector3.zero,
	Vector3.new(-1 / math.sqrt(3), 0, 2 / math.sqrt(3))
)

local function axialRound(position: Vector3): Vector3
	local x, z = math.round(position.X), math.round(position.Z)
	local rx, rz = position.X - x, position.Z - z

	if math.abs(rx) >= math.abs(rz) then
		return Vector3.new(x + math.round(rx + 0.5 * rz), 0, z)
	else
		return Vector3.new(x, 0, z  + math.round(rz + 0.5 * rx))
	end
end

local TilePosition = {}

function TilePosition.toWorld(
	position: Vector3,
	tileSize: number,
	tileShape: number,
	terrainDensity: number,
	terrainIntensity: number,
	terrainSeed: number
): Vector3
	local height = Vector3.zero

	if terrainIntensity > 0 then
		local scaled = position / terrainDensity
		local noise = math.noise(scaled.X, scaled.Z, terrainSeed)

		height = terrainIntensity * tileSize * noise * Vector3.yAxis
	end

	if tileShape == TileShape.HEXAGON then
		return height + HEX_TO_WORLD * position * tileSize
	else
		return height + position * tileSize
	end
end

function TilePosition.toGrid(position: Vector3, tileSize: number, tileShape: number): Vector3
	if tileShape == TileShape.HEXAGON then
		return axialRound(WORLD_TO_HEX * position / tileSize)
	else
		local frac = position / tileSize
		
		return Vector3.new(math.round(frac.X), 0, math.round(frac.Z))
	end
end

return TilePosition
