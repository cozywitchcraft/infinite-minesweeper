--!strict
--!native

--[[
	Board state
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BoardTypes = require(script.Parent.BoardTypes)
local TileFlag = require(script.Parent.Enum.TileFlag)
local TileShape = require(script.Parent.Enum.TileShape)
local StructureData = require(script.Parent.StructureData)
local binarySearch = require(ReplicatedStorage.Util.binarySearch)

local MAX_ITERATIONS = 10000
local MAX_SEED = 2 ^ 31 - 1

local FLAG_DEBOUNCE = 1

local NEIGHBOR_OFFSETS: {{ Vector3 }} = {
	[TileShape.SQUARE] = {
		Vector3.new(1, 0, 0),
		Vector3.new(1, 0, -1),
		Vector3.new(0, 0, -1),
		Vector3.new(-1, 0, -1),
		Vector3.new(-1, 0, 0),
		Vector3.new(-1, 0, 1),
		Vector3.new(0, 0, 1),
		Vector3.new(1, 0, 1),
	},
	[TileShape.HEXAGON] = {
		Vector3.new(1, 0, 0),
		Vector3.new(1, 0, -1),
		Vector3.new(0, 0, -1),
		Vector3.new(-1, 0, 0),
		Vector3.new(-1, 0, 1),
		Vector3.new(0, 0, 1),
	},
}

local function newTile(position: Vector3): BoardTypes.Tile
	return {
		position = position,
		state = 0,
	}
end

local BoardState = {}

-- TODO: Disable history in public servers
function BoardState.new(): BoardTypes.BoardState
	return {
		tiles = {},
		mines = {},
		flags = {},
		tileCount = 0,
		mineCount = 0,
		flagCount = 0,
		mineChance = 0.16,
		tileShape = TileShape.SQUARE,
		random = Random.new(0),
		seed = 0,
		lives = 3,
		structureChance = 0,
		structureCount = 0,
		structureWeights = {},
		totalWeight = 0,
		history = {},
		historyCount = 0,
		historyEnabled = true,
		openTileCount = 0,
	}
end

function BoardState.setSeed(state: BoardTypes.BoardState, seed: number?)
	state.seed = seed or math.random(MAX_SEED)
	state.random = Random.new(state.seed)
end

function BoardState.setStructureWeights(state: BoardTypes.BoardState, weights: { number })
	state.structureWeights = table.clone(weights)
	state.totalWeight = weights[#weights]
end

function BoardState.addTile(state: BoardTypes.BoardState, position: Vector3): BoardTypes.Tile
	local tile = newTile(position)

	state.tiles[position] = tile
	state.tileCount += 1

	return tile
end

local function addSquareRange(state: BoardTypes.BoardState, position: Vector3, range: number)
	for x = -range, range do
		for y = -range, range do
			BoardState.addTile(state, position + Vector3.new(x, 0, y))
		end
	end
end

local function addHexRange(state: BoardTypes.BoardState, position: Vector3, range: number)
	for q = -range, range do
		for r = math.max(-range, -q - range), math.min(range, range - q) do
			BoardState.addTile(state, position + Vector3.new(q, 0, r))
		end
	end
end

function BoardState.addRange(state: BoardTypes.BoardState, position: Vector3, range: number)
	if state.tileShape == TileShape.HEXAGON then
		addHexRange(state, position, range)
	else
		addSquareRange(state, position, range)
	end
end

local function removeFlag(state: BoardTypes.BoardState, tile: BoardTypes.Tile)
	tile.flagCreator = nil
	tile.flagId = nil

	state.flags[tile.position] = nil
	state.flagCount -= 1
end

function BoardState.flagTile(
	state: BoardTypes.BoardState,
	position: Vector3,
	flagCreator: Player?,
	flagId: number?
): BoardTypes.Tile?
	local tile = state.tiles[position]

	if not tile then
		return nil
	end

	if bit32.btest(tile.state, TileFlag.OPEN) then
		return nil
	end

	local lastFlag = tile.lastFlag or 0

	if
		tile.flagCreator and
		tile.flagCreator ~= flagCreator and
		tick() - lastFlag <= FLAG_DEBOUNCE
	then
		return nil
	end

	tile.state = bit32.bxor(tile.state, TileFlag.FLAG)

	if bit32.btest(tile.state, TileFlag.FLAG) then
		tile.flagCreator = flagCreator
		tile.flagId = flagId or 0
		tile.lastFlag = tick()
		
		state.flags[position] = tile	
		state.flagCount += 1
	else
		removeFlag(state, tile)
	end

	return tile
end

local function canPlaceStructure(tile: BoardTypes.Tile): boolean
	return tile.state == TileFlag.OPEN and tile.structureId == nil and
		(math.abs(tile.position.X) > 2 or math.abs(tile.position.Z) > 2)
end

local function placeStructure(state: BoardTypes.BoardState, tile: BoardTypes.Tile)
	-- Choose structure
	if state.totalWeight == 0 then
		return
	end
	
	local targetWeight = state.random:NextInteger(0, state.totalWeight)
	local structureIndex = binarySearch(state.structureWeights, targetWeight)
	local structure = StructureData.structures[structureIndex]

	-- Check area
	for u = 0, structure.size - 1 do
		for v = 0, structure.size - 1 do
			local position = tile.position + Vector3.new(u, 0, v)
			local other = state.tiles[position]

			if not other or not canPlaceStructure(other) then
				return
			end
		end
	end

	-- Place structure
	state.structureCount += 1
	
	tile.state = bit32.bxor(tile.state, TileFlag.FLAG)
	tile.flagId = structure.id

	for u = 0, structure.size do
		for v = 0, structure.size do
			local position = tile.position + Vector3.new(u, 0, v)
			state.tiles[position].structureId = structure.id
		end
	end
end

function BoardState.queueTiles(state: BoardTypes.BoardState, queue: { BoardTypes.Tile }): (number, BoardTypes.TileGrid)
	local neighborOffsets = NEIGHBOR_OFFSETS[state.tileShape]

	if state.historyEnabled then
		table.insert(state.history, table.clone(queue))
		state.historyCount += #queue
	end

	local tileCount = 0
	local tiles: BoardTypes.TileGrid = {}
	
	local structureTiles: { BoardTypes.Tile } = {}
	
	local iterations = 0
	
	while #queue > 0 and iterations <= MAX_ITERATIONS do
		local tile = table.remove(queue, 1) :: BoardTypes.Tile -- Cannot possibly be nil

		if bit32.btest(tile.state, TileFlag.OPEN) then
			continue
		end
		
		iterations += 1

		-- Unflag tiles when opening them
		if bit32.btest(tile.state, TileFlag.FLAG) then
			removeFlag(state, tile)
		end

		tile.state = TileFlag.OPEN + bit32.band(tile.state, TileFlag.MINE) -- Preserve mine state
		state.openTileCount += 1

		if not tiles[tile.position] then
			tileCount += 1
			tiles[tile.position] = tile
		end

		local nearbyMines = 0
		local neighbors: { BoardTypes.Tile } = {}

		for _, offset in neighborOffsets do
			local position = tile.position + offset
			local neighbor = state.tiles[position]

			-- Add neighbors if they don't exist
			if not neighbor then
				neighbor = BoardState.addTile(state, position)

				if state.random:NextNumber() < state.mineChance then
					neighbor.state = TileFlag.MINE

					state.mines[position] = neighbor
					state.mineCount += 1
				end

				tileCount += 1
				tiles[position] = neighbor
			end

			if bit32.btest(neighbor.state, TileFlag.MINE) then
				nearbyMines += 1
			end

			-- Exclude open tiles from queue
			if not bit32.btest(neighbor.state, TileFlag.OPEN) then
				table.insert(neighbors, neighbor)
			end
		end

		tile.state += bit32.lshift(nearbyMines, 3)

		if nearbyMines == 0 or bit32.btest(tile.state, TileFlag.MINE) then
			table.move(neighbors, 1, #neighbors, #queue + 1, queue)
		end

		if
			state.structureChance > 0 and
			canPlaceStructure(tile) and
			state.random:NextNumber() < state.structureChance
		then
			table.insert(structureTiles, tile)
		end
	end

	for _, tile in structureTiles do
		placeStructure(state, tile)
	end

	return tileCount, tiles
end

function BoardState.openTile(state: BoardTypes.BoardState, position: Vector3): (number?, BoardTypes.TileGrid?)
	local tile = state.tiles[position]

	if not tile then
		return nil, nil
	end

	if bit32.btest(tile.state, TileFlag.OPEN + TileFlag.FLAG) then
		return nil, nil
	end

	if bit32.btest(tile.state, TileFlag.MINE) then
		state.lives -= 1
	end

	return BoardState.queueTiles(state, { tile })
end

function BoardState.chordTile(state: BoardTypes.BoardState, position: Vector3): (number?, BoardTypes.TileGrid?)
	local tile = state.tiles[position]

	if not tile or bit32.btest(tile.state, TileFlag.MINE) then
		return nil, nil
	end

	local nearbyMines = bit32.rshift(tile.state, 3)

	if nearbyMines == 0 then
		return nil, nil
	end

	local knownMines = 0
	local lifeLost = false
	local queue: { BoardTypes.Tile } = {}

	-- Count flags and add closed neighbors to queue
	for _, offset in NEIGHBOR_OFFSETS[state.tileShape] do
		local neighbor = state.tiles[tile.position + offset]

		local isOpen = bit32.btest(neighbor.state, TileFlag.OPEN)
		local isMine = bit32.btest(neighbor.state, TileFlag.MINE)
		local isFlag = bit32.btest(neighbor.state, TileFlag.FLAG)
		
		local isKnownMine = if isOpen then isMine else isFlag

		if isKnownMine then
			knownMines += 1
		elseif not isOpen then
			table.insert(queue, neighbor)
			
			lifeLost = isMine or lifeLost
		end
	end

	if knownMines ~= nearbyMines or #queue == 0 then
		return nil, nil
	end

	if lifeLost then
		state.lives -= 1
	end

	return BoardState.queueTiles(state, queue)
end

function BoardState.countFlaggedMines(state: BoardTypes.BoardState): (number, { [Player]: number })
	local flagCount = 0
	local flagCountPerPlayer: { [Player]: number } = {}

	for _, mine in state.mines do
		if bit32.btest(mine.state, TileFlag.FLAG) then
			flagCount += 1
		end
		
		if mine.flagCreator then
			local count = flagCountPerPlayer[mine.flagCreator] or 0
			flagCountPerPlayer[mine.flagCreator] = count + 1
		end
	end
	
	return flagCount, flagCountPerPlayer
end

function BoardState.countFlaggedMinesByPlayer(state: BoardTypes.BoardState, player: Player): number
	local flagCount = 0

	for _, mine in state.mines do
		if mine.flagCreator == player then
			flagCount += 1
		end
	end

	return flagCount
end

function BoardState.clear(state: BoardTypes.BoardState)
	table.clear(state.tiles)
	table.clear(state.mines)
	table.clear(state.flags)
	table.clear(state.history)
	
	state.tileCount = 0
	state.mineCount = 0
	state.flagCount = 0
	state.structureCount = 0
	state.historyCount = 0
end

return BoardState
