--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Attribute = require(ReplicatedStorage.Util.Attribute)
local BoardConfig = require(ReplicatedStorage.Board.BoardConfig)
local BoardData = require(ServerScriptService.Identity.BoardData)
local BoardDataStore = require(ServerScriptService.BoardDataStore)
local Badges = require(ServerScriptService.Badges)
local BoardState = require(ReplicatedStorage.Board.BoardState)
local BoardTypes = require(ReplicatedStorage.Board.BoardTypes)
local Character = require(ReplicatedStorage.Util.Character)
local DeathMessages = require(ReplicatedStorage.DeathMessages)
local RateLimit = require(ReplicatedStorage.Remote.RateLimit)
local RemoteServer = require(ServerScriptService.RemoteServer)
local PlayerDataStore = require(ServerScriptService.PlayerDataStore)
local Scores = require(script.Scores)
local Statistics = require(script.Statistics)
local StructureData = require(ReplicatedStorage.Board.StructureData)
local TileBuffer = require(ReplicatedStorage.Board.TileBuffer)
local TileFlag = require(ReplicatedStorage.Board.Enum.TileFlag)
local TilePosition = require(ReplicatedStorage.Board.TilePosition)
local TileShape = require(ReplicatedStorage.Board.Enum.TileShape)
local getEquippedFlag = require(script.getEquippedFlag)
local getFlagCount = require(script.getFlagCount)
local loadBoardState = require(script.loadBoardState)
local writeBoardState = require(script.writeBoardState)

local DIAGONAL = 2 ^ -.5
local MAX_TERRAIN_SEED = 2 ^ 31 - 1

local announced = RemoteServer.getRemoteEvent("Announced")
local badgeAwarded = RemoteServer.getRemoteEvent("BadgeAwarded")
local boardLoaded = RemoteServer.getRemoteEvent("BoardLoaded")
local boardUpdated = RemoteServer.getRemoteEvent("BoardUpdated")
local lifeLost = RemoteServer.getRemoteEvent("LifeLost")
local restarted = RemoteServer.getRemoteEvent("Restarted")
local restarting = RemoteServer.getRemoteEvent("Restarting")
local tileChorded = RemoteServer.getRemoteEvent("TileChorded")
local tileFlagged = RemoteServer.getRemoteEvent("TileFlagged")
local tileOpened = RemoteServer.getRemoteEvent("TileOpened")

local configFolder = ReplicatedStorage.Config

local boardRateLimit = RateLimit.new(20, 1)
local badgeRateLimit = RateLimit.new(5, 1)

local boardConfig = BoardConfig.default()
local boardState = BoardState.new()

local boardDisabled = true
local boardId = 0

local function validateTileAction(player: Player, position: Vector3): boolean
	if not RateLimit.checkRequest(boardRateLimit, player) then
		return false
	end
	
	if boardDisabled then
		return false
	end

	local humanoid = Character.getHumanoid(player.Character)

	if not humanoid or humanoid:GetState() == Enum.HumanoidStateType.Dead then
		return false
	end

	local rootPart = humanoid.RootPart

	if not rootPart then
		return false
	end

	local worldPosition = TilePosition.toWorld(
		position,
		boardConfig.tileSize,
		boardConfig.tileShape,
		boardConfig.terrainDensity,
		boardConfig.terrainIntensity,
		boardConfig.terrainSeed
	)

	local distance = (rootPart.Position - worldPosition).Magnitude 
	
	return distance <= boardConfig.maxDistance + boardConfig.tileSize * DIAGONAL
end

local function serializeBoard(): buffer
	local header, err = BoardConfig.serialize(boardConfig)
	assert(header, err)

	local tileBuffer = TileBuffer.create(boardState.tileCount, boardState.structureCount + boardState.flagCount, header)

	if boardDisabled then
		TileBuffer.writeTiles(tileBuffer, buffer.len(header), boardState.tiles)
	else
		TileBuffer.writeTilesSanitized(tileBuffer, buffer.len(header), boardState.tiles)
	end

	return tileBuffer
end

local function createBoardSave(): BoardData.BoardSave
	return {
		tileShape = boardConfig.tileShape,
		tileSize = boardConfig.tileSize,
		terrainDensity = boardConfig.terrainDensity,
		terrainIntensity = boardConfig.terrainIntensity,
		terrainSeed = boardConfig.terrainSeed,
		flagless = boardConfig.flagless,
		jumpless = boardConfig.jumpless,
		slippery = boardConfig.slippery,
		spheres = boardConfig.spheres,
		maxDistance = boardConfig.maxDistance,
		mineChance = boardState.mineChance,
		structureChance = boardState.structureChance,
		structureWeights = boardState.structureWeights,
		scores = Scores.getScores(),
		lives = boardState.lives,
		seed = boardState.seed,
		data = writeBoardState(boardState),
	}
end

local function loadDefaultBoard()
	boardConfig.tileShape = Attribute.getNumber(configFolder, "TileShape")
	boardConfig.tileSize = Attribute.getNumber(configFolder, "TileSize")
	boardConfig.terrainIntensity = Attribute.getNumber(configFolder, "TerrainIntensity")
	boardConfig.terrainDensity = Attribute.getNumber(configFolder, "TerrainDensity")
	boardConfig.flagless = Attribute.getBoolean(configFolder, "Flagless")
	boardConfig.spheres = Attribute.getBoolean(configFolder, "Spheres")
	boardConfig.slippery = Attribute.getBoolean(configFolder, "Slippery")
	boardConfig.jumpless = Attribute.getBoolean(configFolder, "Jumpless")
	boardConfig.maxDistance = Attribute.getNumber(configFolder, "MaxDistance")
	boardConfig.terrainSeed = math.random(MAX_TERRAIN_SEED)

	boardState.tileShape = boardConfig.tileShape
	boardState.mineChance = Attribute.getNumber(configFolder, "MineChance")

	if Attribute.getBoolean(configFolder, "UseSeed") then
		BoardState.setSeed(boardState, Attribute.getNumber(configFolder, "Seed"))
	else
		BoardState.setSeed(boardState)
	end

	if Attribute.getBoolean(configFolder, "AdjustLives") then
		boardState.lives = 2 * math.max(#Players:GetPlayers(), 1) + 1
	else
		boardState.lives = Attribute.getNumber(configFolder, "Lives")
	end	

	if boardConfig.tileShape == TileShape.SQUARE and boardConfig.terrainIntensity == 0 then
		boardState.structureChance = Attribute.getNumber(configFolder, "StructureChance")
	else
		boardState.structureChance = 0
	end

	BoardState.setStructureWeights(boardState, StructureData.weights)
	BoardState.addRange(boardState, Vector3.zero, 2)
	BoardState.openTile(boardState, Vector3.zero)	

	Scores.reset()
end

local function loadBoardSaveUnsafe(boardSave: BoardData.BoardSave)
	boardConfig.tileShape = boardSave.tileShape
	boardConfig.tileSize = boardSave.tileSize
	boardConfig.terrainIntensity = boardSave.terrainIntensity
	boardConfig.terrainDensity = boardSave.terrainDensity
	boardConfig.flagless = boardSave.flagless
	boardConfig.spheres = boardSave.spheres
	boardConfig.slippery = boardSave.slippery
	boardConfig.jumpless = boardSave.jumpless
	boardConfig.maxDistance = boardSave.maxDistance
	boardConfig.terrainSeed = boardSave.terrainSeed

	boardState.tileShape = boardSave.tileShape
	boardState.lives = boardSave.lives
	boardState.mineChance = boardSave.mineChance
	boardState.structureChance = boardSave.structureChance

	BoardState.setSeed(boardState, boardSave.seed)
	BoardState.setStructureWeights(boardState, boardSave.structureWeights)
	BoardState.addRange(boardState, Vector3.zero, 2)

	loadBoardState(boardState, boardSave.data)

	Scores.setScores(boardSave.scores)
end

local function loadBoardSave(boardSave: BoardData.BoardSave)
	local success, err = pcall(loadBoardSaveUnsafe, boardSave)

	if not success then
		announced:FireAllClients("Failed to load board save! Data might be corrupted.", "ff0000")
		warn("Error while loading board save:", err)
		
		return loadDefaultBoard()
	end
	
	configFolder:SetAttribute("AutosaveEnabled", true)
end

local function loadBoard(boardSave: BoardData.BoardSave?)
	BoardState.clear(boardState)
	
	if boardSave then
		loadBoardSave(boardSave)
	else
		loadDefaultBoard()
	end
	
	boardDisabled = boardState.lives == 0
	boardId += 1
	
	boardLoaded:FireAllClients(serializeBoard())

	workspace:SetAttribute("Lives", boardState.lives)
	workspace:SetAttribute("TileCount", boardState.tileCount)
	workspace:SetAttribute("MineCount", boardState.mineCount)
	workspace:SetAttribute("FlagCount", boardState.flagCount)
	
	if boardDisabled then
		workspace:SetAttribute("RoundStart", 0)
		workspace:SetAttribute("RoundEnd", 0)
	else
		workspace:SetAttribute("RoundStart", workspace:GetServerTimeNow())
	end
	
	workspace:SetAttribute("StatsEnabled", boardState.mineChance >= 0.16 and boardState.mineChance <= 0.25)

	for _, player in Players:GetPlayers() do
		task.defer(Character.quickRespawn, player, CFrame.identity)
	end
end

local function restartBoard()
	local currentId = boardId
	local restartDelay = Attribute.getNumber(configFolder, "RestartDelay")

	if restartDelay > 1 then
		restarting:FireAllClients(restartDelay)
	end

	task.wait(restartDelay)

	if currentId == boardId then
		loadBoard()
	end
end

local function disableBoard()
	boardDisabled = true

	local flagCount, flagCountPerPlayer = BoardState.countFlaggedMines(boardState)

	local tileBuffer = TileBuffer.create(boardState.mineCount, flagCount)
	TileBuffer.writeTiles(tileBuffer, 0, boardState.mines)
	
	boardUpdated:FireAllClients(tileBuffer)
	
	Statistics.incrementRoundsPlayed()
	
	for player, count in flagCountPerPlayer do
		Statistics.incrementMinesFlagged(player, count)
	end

	workspace:SetAttribute("RoundEnd", workspace:GetServerTimeNow())

	if Attribute.getBoolean(configFolder, "AutoRestart") then
		restartBoard()
	end
end

local function resetTile(player: Player, position: Vector3)
	local tile = boardState.tiles[position]

	if not tile then
		return
	end
	
	local tileBuffer = TileBuffer.create(1, getFlagCount(tile))
	TileBuffer.writeTileSanitized(tileBuffer, 0, tile)

	boardUpdated:FireClient(player, tileBuffer)
end

local function onTileFlagged(player: Player, position: unknown)
	assert(typeof(position) == "Vector3", "position must be a Vector3")

	if boardConfig.flagless or not validateTileAction(player, position) then
		resetTile(player, position)
		return 
	end

	local tile = BoardState.flagTile(boardState, position, player, getEquippedFlag(player))

	if not tile then
		resetTile(player, position)
		return 
	end

	local tileBuffer = TileBuffer.create(1, getFlagCount(tile))
	TileBuffer.writeTileSanitized(tileBuffer, 0, tile)

	workspace:SetAttribute("FlagCount", boardState.flagCount)

	for _, otherPlayer in Players:GetPlayers() do
		if otherPlayer ~= player then
			boardUpdated:FireClient(otherPlayer, tileBuffer)
		end
	end
end

local function onTileAction(
	player: Player,
	position: unknown,
	action: (state: BoardTypes.BoardState, position: Vector3) -> (number?, BoardTypes.TileGrid?)
)
	assert(typeof(position) == "Vector3", "position must be a Vector3")

	if not validateTileAction(player, position) then
		resetTile(player, position)
		return
	end

	local lives = boardState.lives
	local structureCount = boardState.structureCount
	local openTileCount = boardState.openTileCount

	local tileCount, tiles = action(boardState, position)

	if not tileCount or not tiles then
		resetTile(player, position)
		return
	end

	local tileBuffer = TileBuffer.create(tileCount, boardState.structureCount - structureCount)
	TileBuffer.writeTilesSanitized(tileBuffer, 0, tiles)

	boardUpdated:FireAllClients(tileBuffer)

	workspace:SetAttribute("TileCount", boardState.tileCount)
	workspace:SetAttribute("MineCount", boardState.mineCount)
	workspace:SetAttribute("FlagCount", boardState.flagCount)
	workspace:SetAttribute("Lives", boardState.lives)

	if boardState.lives == lives then
		Scores.increment(player, tileCount)
	else
		Scores.increment(player, -tileCount)
		Statistics.incrementLivesLost(player)

		lifeLost:FireAllClients(player, math.random(1, #DeathMessages))

		if Attribute.getBoolean(configFolder, "ExplodeCharacters") then
			Character.explode(player.Character)
		end
	end

	Statistics.incrementTilesShown(player, boardState.openTileCount - openTileCount)

	if boardState.lives == 0 then
		disableBoard()
	end
end

local function onTileChorded(player: Player, position: unknown)
	onTileAction(player, position, BoardState.chordTile)
end

local function onTileOpened(player: Player, position: unknown)
	onTileAction(player, position, BoardState.openTile)
end

local function onPlayerAdded(player: Player)
	RateLimit.addPlayer(boardRateLimit, player)
	RateLimit.addPlayer(badgeRateLimit, player)
	
	Scores.addPlayer(player)
	
	boardLoaded:FireClient(player, serializeBoard())
end

local function onPlayerRemoving(player: Player)
	RateLimit.removePlayer(boardRateLimit, player)
	RateLimit.removePlayer(badgeRateLimit, player)
	
	Scores.removePlayer(player)
end

PlayerDataStore.dataLoaded:connect(function(dataInstance)
	local userId = tonumber(dataInstance.key)
	local player = userId and Players:GetPlayerByUserId(userId)
	
	if not player then
		return
	end
	
	dataInstance.beforeRelease:connect(function()
		local flagCount = BoardState.countFlaggedMinesByPlayer(boardState, player)
		
		dataInstance.data.coins += flagCount -- TODO: Remove this
		dataInstance.data.minesFlagged += flagCount
	end)
end)

BoardDataStore.loaded:connect(function()
	local dataInstance = BoardDataStore.getDataInstance()
	
	if not dataInstance then
		return
	end
	
	dataInstance.beforeSave:connect(function()
		if Attribute.getBoolean(configFolder, "AutosaveEnabled") then
			dataInstance.data.autosave = createBoardSave()
		end
	end)

	if dataInstance.data.autosave then
		loadBoard(dataInstance.data.autosave)
	end
end)

restarted.OnServerEvent:Connect(function(player)
	if player:GetAttribute("Admin") then
		loadBoard()
	end
end)

badgeAwarded.OnServerEvent:Connect(function(player)
	if not workspace:GetAttribute("StatsEnabled") then
		return
	end
	
	if not RateLimit.checkRequest(badgeRateLimit, player) then
		return
	end

	local humanoid = Character.getHumanoid(player.Character)
	local rootPart = humanoid and humanoid.RootPart

	if not rootPart then
		return
	end

	local position = TilePosition.toGrid(rootPart.Position, boardConfig.tileSize, boardConfig.tileShape)
	local tile = boardState.tiles[position]

	if tile.structureId == 3 then
		Badges.awardBadge(player, 2140896100)
	end
end)

tileChorded.OnServerEvent:Connect(onTileChorded)
tileFlagged.OnServerEvent:Connect(onTileFlagged)
tileOpened.OnServerEvent:Connect(onTileOpened)

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

loadBoard()

for _, player in Players:GetPlayers() do
	task.defer(onPlayerAdded, player)
end