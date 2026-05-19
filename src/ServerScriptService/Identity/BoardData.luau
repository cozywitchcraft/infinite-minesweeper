local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BoardTypes = require(ReplicatedStorage.Board.BoardTypes)

export type BoardSave = {
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
	mineChance: number,
	structureChance: number,
	structureWeights: { number },
	scores: { [string]: number },
	lives: number,
	seed: number,
	data: buffer,
}

export type BoardData = {
	autosave: BoardSave?,
}

local CURRENT_VERSION = 0

local function createBoardData(): BoardData
	return {}
end

local function createMetadata(): { [string]: any }
	return {
		version = CURRENT_VERSION,
	}
end

local function BoardData(data: any, keyInfo: DataStoreKeyInfo?): (BoardData?, { any }?, { [string]: any }?)
	if keyInfo == nil then
		return createBoardData(), nil, createMetadata()
	end
	
	if typeof(data) ~= "table" then
		return nil, nil, nil
	end
	
	-- TODO: Validate data
	
	return data, keyInfo:GetUserIds(), keyInfo:GetMetadata()
end

return BoardData