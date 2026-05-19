--!strict
--!native

--[[
	Functions for tile serdes
]]

local BoardTypes = require(script.Parent.BoardTypes)
local TileFlag = require(script.Parent.Enum.TileFlag)

local function sanitizeState(state: number): number
	if not bit32.btest(state, TileFlag.OPEN) then
		return bit32.band(state, TileFlag.FLAG)
	end

	return state
end

local function writeTile(b: buffer, offset: number, position: Vector3, state: number, flagId: number?)
	buffer.writei32(b, offset, position.X)
	buffer.writei32(b, offset + 4, position.Z)
	buffer.writeu8(b, offset + 8, state)

	if bit32.btest(state, TileFlag.FLAG) then
		buffer.writeu16(b, offset + 9, flagId or 0)
	end
end

local TileBuffer = {
	POSITION_SIZE = 8,
	FLAG_SIZE = 2,
	TILE_SIZE = 9,
	TILE_WITH_FLAG_SIZE = 11,
}

function TileBuffer.create(tileCount: number, flagCount: number, header: buffer?): buffer
	local length = TileBuffer.TILE_SIZE * tileCount + TileBuffer.FLAG_SIZE * flagCount

	if header then
		local b = buffer.create(buffer.len(header) + length)
		buffer.copy(b, 0, header)

		return b
	else
		return buffer.create(length)
	end
end

function TileBuffer.readTile(b: buffer, offset: number): (Vector3, number, number?)
	local x = buffer.readi32(b, offset)
	local z = buffer.readi32(b, offset + 4)
	local state = buffer.readu8(b, offset + 8)

	if bit32.btest(state, TileFlag.FLAG) then
		local flagId = buffer.readu16(b, offset + 9)
		return Vector3.new(x, 0, z), state, flagId
	end

	return Vector3.new(x, 0, z), state, nil
end

function TileBuffer.nextOffset(offset: number, flagId: number?)
	if flagId ~= nil then
		return offset + TileBuffer.TILE_WITH_FLAG_SIZE
	else
		return offset + TileBuffer.TILE_SIZE
	end
end

function TileBuffer.writeTile(b: buffer, offset: number, tile: BoardTypes.Tile)
	writeTile(b, offset, tile.position, tile.state, tile.flagId)
end

function TileBuffer.writeTileSanitized(b: buffer, offset: number, tile: BoardTypes.Tile)
	writeTile(b, offset, tile.position, sanitizeState(tile.state), tile.flagId)
end

function TileBuffer.writeTiles(b: buffer, offset: number, tiles: BoardTypes.TileGrid)
	for _, tile in tiles do
		TileBuffer.writeTile(b, offset, tile)
		offset = TileBuffer.nextOffset(offset, tile.flagId)
	end
end

function TileBuffer.writeTilesSanitized(b: buffer, offset: number, tiles: BoardTypes.TileGrid)
	for _, tile in tiles do
		TileBuffer.writeTileSanitized(b, offset, tile)
		offset = TileBuffer.nextOffset(offset, tile.flagId)
	end
end

return TileBuffer
