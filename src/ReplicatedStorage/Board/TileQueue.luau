--!native
local BoardTypes = require(script.Parent.BoardTypes)
local TileBuffer = require(script.Parent.TileBuffer)
local TileFlag = require(script.Parent.Enum.TileFlag)

local TileQueue = {}

function TileQueue.new(): BoardTypes.TileQueue
	return {
		queue = buffer.create(0),
		length = 0,
		cursor = 0,
	}
end

function TileQueue.add(queue: BoardTypes.TileQueue, b: buffer, offset: number?)
	offset = offset or 0

	local newLength = queue.length + buffer.len(b) - offset
	local newQueue = buffer.create(newLength)

	buffer.copy(newQueue, 0, queue.queue)
	buffer.copy(newQueue, queue.length, b, offset)

	queue.queue = newQueue
	queue.length = newLength
end

function TileQueue.nextTile(queue: BoardTypes.TileQueue): (Vector3, number, number?)
	local position, state, flagId = TileBuffer.readTile(queue.queue, queue.cursor)
	queue.cursor = TileBuffer.nextOffset(queue.cursor, flagId)

	return position, state, flagId
end

function TileQueue.clear(queue: BoardTypes.TileQueue)
	queue.queue = buffer.create(0)
	queue.length = 0
	queue.cursor = 0
end

return TileQueue
