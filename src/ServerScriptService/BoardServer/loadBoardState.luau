 --!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BoardState = require(ReplicatedStorage.Board.BoardState)
local BoardTypes = require(ReplicatedStorage.Board.BoardTypes)

local function loadBoardState(boardState: BoardTypes.BoardState, b: buffer)	
	local offset = 0

	local historySize = buffer.readu32(b, offset)
	offset += 4

	-- TODO: Buffer by runtime
	for _ = 1, historySize do
		local queueSize = buffer.readu8(b, offset)
		offset += 1

		local queue = {}

		for _ = 1, queueSize do
			local x = buffer.readi32(b, offset)
			local z = buffer.readi32(b, offset + 4)
			local position = Vector3.new(x, 0, z)

			table.insert(queue, boardState.tiles[position])

			offset += 8
		end

		BoardState.queueTiles(boardState, queue)
	end

	local flagSize = buffer.readu32(b, offset)
	offset += 4

	for _ = 1, flagSize do
		local x = buffer.readi32(b, offset)
		local z = buffer.readi32(b, offset + 4)
		local flagId = buffer.readu16(b, offset + 8)

		BoardState.flagTile(boardState, Vector3.new(x, 0, z), nil, flagId)

		offset += 10
	end
end

return loadBoardState