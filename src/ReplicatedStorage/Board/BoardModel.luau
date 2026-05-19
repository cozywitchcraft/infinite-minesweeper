--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Assets = require(ReplicatedStorage.Assets)
local BoardConfig = require(script.Parent.BoardConfig)
local BoardTypes = require(script.Parent.BoardTypes)
local TileFlag = require(ReplicatedStorage.Board.Enum.TileFlag)
local TilePosition = require(script.Parent.TilePosition)
local TileShape = require(ReplicatedStorage.Board.Enum.TileShape)

local EPSILON = 1e-3

local DEFAULT_CONFIG = BoardConfig.default()

local DEFAULT_FLAG = Assets.Flags[1]

local DEFAULT_FIELD_COLOR_LIGHT = Color3.fromRGB(99, 95, 98)
local DEFAULT_FIELD_COLOR_DARK = Color3.fromRGB(80, 77, 79)
local DEFAULT_GROUND_COLOR_LIGHT = Color3.fromRGB(248, 248, 248)
local DEFAULT_GROUND_COLOR_DARK = Color3.fromRGB(200, 200, 200)
local DEFAULT_MATERIAL = Enum.Material.Plastic

local FIELD_MINE_COLOR = Color3.new(0, 0, 0)
local GROUND_MINE_COLOR = Color3.new(1, 0, 0)

local DEFAULT_PHYSICS = PhysicalProperties.new(Enum.Material.Plastic)
local SLIPPERY_PHYSICS = PhysicalProperties.new(0.7, 0, 0.5, 100, 1)

local function isCheckered(position: Vector3, tileShape: number): boolean
	if tileShape == TileShape.HEXAGON then
		return position.X % 3 == position.Z % 3
	end
	
	return (position.X + position.Z) % 2 == 0
end

local function playFlagSound(part: MeshPart, tileSize: number)
	local flagSound = SoundService.Flag:Clone()

	if tileSize ~= 5 then
		flagSound.PlaybackSpeed = math.exp(0.05 - 0.01 * tileSize)
	end

	flagSound.Parent = part

	flagSound.Ended:Once(function()
		flagSound:Destroy()
	end)

	flagSound:Play()
end

local function getPartTemplate(spheres: boolean, tileShape: number): MeshPart
	if spheres then
		return Assets.sphereTile
	elseif tileShape == TileShape.HEXAGON then
		return Assets.hexagonTile
	else
		return Assets.squareTile
	end
end

local function getModelTemplate(state: number, id: number?): Model
	id = id or 0
	
	if bit32.btest(state, TileFlag.OPEN) then
		return Assets.Structures[id + 1]
	else
		return Assets.Flags[id + 1]
	end
end

local function createTile(model: BoardTypes.BoardModel, position: Vector3): BoardTypes.TileModel
	local partTemplate = getPartTemplate(model.spheres, model.tileShape)

	local tile: BoardTypes.TileModel = {
		position = position,
		state = 0,
		part = partTemplate:Clone(),
	}

	local worldPosition = TilePosition.toWorld(
		position,
		model.tileSize,
		model.tileShape,
		model.terrainDensity,
		model.terrainIntensity,
		model.terrainSeed
	)

	local height = math.max(2 * model.terrainIntensity / model.terrainDensity, 1)
	local offset = 0.5 * model.tileSize * height * Vector3.yAxis

	tile.part.CFrame = CFrame.fromMatrix(worldPosition - offset, -Vector3.xAxis, Vector3.yAxis)

	if height > 1 then
		tile.part.Size *= model.tileSize * Vector3.new(1, height, 1)
	else
		tile.part.Size *= model.tileSize
	end

	tile.part.CustomPhysicalProperties = if model.slippery then SLIPPERY_PHYSICS else DEFAULT_PHYSICS

	return tile
end

local BoardModel = {}

function BoardModel.new(options: BoardTypes.BoardModelOptions?): BoardTypes.BoardModel
	options = options or {} :: BoardTypes.BoardModelOptions

	local instance = Instance.new("Folder")
	instance.Name = "Board"
	instance.Parent = options.parent

	return {
		tiles = {},
		instance = instance,
		tileShape = options.tileShape or DEFAULT_CONFIG.tileShape,
		tileSize = options.tileSize or DEFAULT_CONFIG.tileSize,
		terrainIntensity = options.terrainIntensity or DEFAULT_CONFIG.terrainIntensity,
		terrainSeed = options.terrainSeed or DEFAULT_CONFIG.terrainSeed,
		terrainDensity = options.terrainDensity or DEFAULT_CONFIG.terrainDensity,
		slippery = options.slippery or DEFAULT_CONFIG.slippery,
		spheres = options.spheres or DEFAULT_CONFIG.spheres,
		fieldColorDark = options.fieldColorDark or DEFAULT_FIELD_COLOR_DARK,
		fieldColorLight = options.fieldColorLight or DEFAULT_FIELD_COLOR_LIGHT,
		groundColorDark = options.groundColorDark or DEFAULT_GROUND_COLOR_DARK,
		groundColorLight = options.groundColorLight or DEFAULT_GROUND_COLOR_LIGHT,
		fieldMaterial = options.fieldMaterial or DEFAULT_MATERIAL,
		groundMaterial = options.groundMaterial or DEFAULT_MATERIAL,
	}
end

function BoardModel.addTile(model: BoardTypes.BoardModel, position: Vector3): BoardTypes.TileModel
	local tile = createTile(model, position)
	model.tiles[position] = tile

	return tile
end

function BoardModel.updateTile(
	model: BoardTypes.BoardModel,
	position: Vector3,
	state: number,
	flagId: number?
)
	local tile = model.tiles[position]

	if tile then
		if tile.state == state then
			return
		elseif state == TileFlag.FLAG then
			playFlagSound(tile.part, model.tileSize)
		end
	else
		tile = BoardModel.addTile(model, position)
	end

	tile.state = state

	if bit32.btest(state, TileFlag.OPEN) then
		local nearbyMines = bit32.rshift(state, 3)

		if bit32.btest(state, TileFlag.MINE) then
			local texture = Assets.mineTexture:Clone()
			texture.Parent = tile.part

			tile.part.Color = GROUND_MINE_COLOR
		elseif nearbyMines > 0 then
			local texture = Assets.numberTextures[nearbyMines]:Clone()
			texture.Parent = tile.part

			tile.part.Color = model.groundColorDark
		else
			tile.part.Color = model.groundColorLight
		end

		tile.part.Material = model.groundMaterial
	else
		if bit32.btest(state, TileFlag.MINE) then
			local texture = Assets.crossTexture:Clone()
			texture.Parent = tile.part

			tile.part.Color = FIELD_MINE_COLOR
		elseif isCheckered(position, model.tileShape) then
			tile.part.Color = model.fieldColorDark
		else
			tile.part.Color = model.fieldColorLight
		end

		tile.part.Material = model.fieldMaterial
	end

	if tile.flag then
		tile.flag = tile.flag:Destroy()
	end

	if bit32.btest(state, TileFlag.FLAG) then
		local flagTemplate = getModelTemplate(state, flagId) or DEFAULT_FLAG
		
		local newFlag = flagTemplate:Clone()
		newFlag:ScaleTo(0.2 * model.tileSize)
		newFlag:PivotTo(tile.part.CFrame + 0.5 * tile.part.Size.Y * Vector3.yAxis)
		newFlag.Parent = model.instance

		tile.flag = newFlag
	end

	tile.part.Parent = model.instance
end

local function getTileFromWorldPosition(model: BoardTypes.BoardModel, position: Vector3): BoardTypes.TileModel
	local gridPosition = TilePosition.toGrid(position, model.tileSize, model.tileShape)
	return model.tiles[gridPosition]
end

function BoardModel.getTileFromPart(model: BoardTypes.BoardModel, part: BasePart): BoardTypes.TileModel?
	local parent = part.Parent

	if parent == model.instance then
		return getTileFromWorldPosition(model, part.Position)
	elseif parent and parent:IsA("Model") and parent.Parent == model.instance then
		return getTileFromWorldPosition(model, parent:GetPivot().Position)
	end

	return nil
end

function BoardModel.getFloorTile(
	model: BoardTypes.BoardModel,
	position: Vector3,
	hipHeight: number
): BoardTypes.TileModel?
	local tile = getTileFromWorldPosition(model, position)
	
	if not tile then
		return nil
	end
	
	local tileHeight = tile.part.Position.Y + 0.5 * tile.part.Size.Y
	local distance = position.Y - tileHeight
	
	if distance >= 0 and distance <= hipHeight + EPSILON then
		return tile
	else
		return nil
	end
end

function BoardModel.setConfig(model: BoardTypes.BoardModel, config: BoardTypes.BoardConfig)
	model.tileShape = config.tileShape
	model.tileSize = config.tileSize
	model.terrainIntensity = config.terrainIntensity
	model.terrainSeed = config.terrainSeed
	model.terrainDensity = config.terrainDensity
	model.slippery = config.slippery
	model.spheres = config.spheres
end

function BoardModel.setFieldColorLight(model: BoardTypes.BoardModel, color: Color3)
	if model.fieldColorLight == color then
		return
	end

	model.fieldColorLight = color

	for position, tile in model.tiles do
		if
			not bit32.btest(tile.state, TileFlag.OPEN) and
			not bit32.btest(tile.state, TileFlag.MINE) and
			not isCheckered(position, model.tileShape)
		then
			tile.part.Color = color
		end
	end
end

function BoardModel.setFieldColorDark(model: BoardTypes.BoardModel, color: Color3)
	if model.fieldColorDark == color then
		return
	end

	model.fieldColorDark = color

	for position, tile in model.tiles do
		if
			not bit32.btest(tile.state, TileFlag.OPEN) and
			not bit32.btest(tile.state, TileFlag.MINE) and
			isCheckered(position, model.tileShape)
		then
			tile.part.Color = color
		end
	end
end

function BoardModel.setGroundColorLight(model: BoardTypes.BoardModel, color: Color3)
	if model.groundColorLight == color then
		return
	end

	model.groundColorLight = color

	for _, tile in model.tiles do
		if
			bit32.btest(tile.state, TileFlag.OPEN) and
			not bit32.btest(tile.state, TileFlag.MINE) and
			bit32.rshift(tile.state, 3) == 0
		then
			tile.part.Color = color
		end
	end
end

function BoardModel.setGroundColorDark(model: BoardTypes.BoardModel, color: Color3)
	if model.groundColorDark == color then
		return
	end

	model.groundColorDark = color

	for _, tile in model.tiles do
		if
			bit32.rshift(tile.state, 3) > 0 and
			not bit32.btest(tile.state, TileFlag.MINE)
		then
			tile.part.Color = color
		end
	end
end

function BoardModel.setFieldMaterial(model: BoardTypes.BoardModel, material: Enum.Material)
	if model.fieldMaterial == material then
		return
	end

	model.fieldMaterial = material

	for _, tile in model.tiles do
		if not bit32.btest(tile.state, TileFlag.OPEN) then
			tile.part.Material = material
		end
	end
end

function BoardModel.setGroundMaterial(model: BoardTypes.BoardModel, material: Enum.Material)
	if model.groundMaterial == material then
		return
	end

	model.groundMaterial = material

	for _, tile in model.tiles do
		if bit32.btest(tile.state, TileFlag.OPEN) then
			tile.part.Material = material
		end
	end
end

function BoardModel.clear(model: BoardTypes.BoardModel)
	table.clear(model.tiles)

	model.instance:ClearAllChildren()
end

return BoardModel
