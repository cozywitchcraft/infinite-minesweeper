	--!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BoardTypes = require(ReplicatedStorage.Board.BoardTypes)

local function writeBoardState(boardState: BoardTypes.BoardState): buffer
	local b = buffer.create(8 + #boardState.history + 8 * boardState.historyCount + 10 * boardState.flagCount)
	local offset = 0

	-- Write history
	buffer.writeu32(b, offset, #boardState.history)
	offset += 4

	for _, tiles in boardState.history do
		buffer.writeu8(b, offset, #tiles)
		offset += 1

		for _, tile in tiles do
			buffer.writei32(b, offset, tile.position.X)
			buffer.writei32(b, offset + 4, tile.position.Z)
			offset += 8
		end
	end

	-- Write flags
	buffer.writeu32(b, offset, boardState.flagCount)
	offset += 4

	for _, tile in boardState.flags do
		buffer.writei32(b, offset, tile.position.X)
		buffer.writei32(b, offset + 4, tile.position.Z)
		buffer.writeu16(b, offset + 8, tile.flagId or 0)
		offset += 10
	end
	
	return b
end

return writeBoardState