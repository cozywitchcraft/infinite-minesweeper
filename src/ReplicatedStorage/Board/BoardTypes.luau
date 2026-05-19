--[[
	Board types
]]

export type Tile = {
	position: Vector3,
	state: number,
	flagCreator: Player?,
	flagId: number?,
	lastFlag: number?,
	structureId: number?,
}

export type TileGrid = { [Vector3]: Tile }

export type BoardState = {
	tiles: TileGrid,
	mines: TileGrid,
	flags: TileGrid,
	tileCount: number,
	mineCount: number,
	flagCount: number,
	mineChance: number,
	tileShape: number,
	random: Random,
	seed: number,
	lives: number,
	structureChance: number,
	structureCount: number,
	structureWeights: { number },
	totalWeight: number,
	history: {{ Tile }},
	historyCount: number,
	historyEnabled: boolean,
	openTileCount: number,
}

export type BoardConfig = {
	tileShape: number,
	tileSize: number,
	terrainDensity: number,
	terrainIntensity: number,
	terrainSeed: number,
	flagless: boolean,
	jumpless: boolean,
	slippery: boolean,
	spheres: boolean,
	maxDistance: number,
}

export type TileModel = {
	position: Vector3,
	state: number,
	part: MeshPart,
	flag: Model?,
}

export type BoardModelOptions = {
	tileShape: number,
	tileSize: number,
	terrainDensity: number,
	terrainIntensity: number,
	terrainSeed: number,
	slippery: boolean,
	spheres: boolean,
	fieldColorLight: Color3?,
	fieldColorDark: Color3?,
	groundColorLight: Color3?,
	groundColorDark: Color3?,
	fieldMaterial: Enum.Material?,
	groundMaterial: Enum.Material?,
	parent: Instance?,
}

export type BoardModel = {
	tiles: { [Vector3]: TileModel },
	instance: Folder,
	tileShape: number,
	tileSize: number,
	terrainDensity: number,
	terrainIntensity: number,
	terrainSeed: number,
	slippery: boolean,
	spheres: boolean,
	fieldColorLight: Color3,
	fieldColorDark: Color3,
	groundColorLight: Color3,
	groundColorDark: Color3,
	fieldMaterial: Enum.Material,
	groundMaterial: Enum.Material,
}

export type Structure = {
	id: number,
	size: number,
	weight: number,
}

export type TileQueue = {
	queue: buffer,
	length: number,
	cursor: number,
}

return nil
