--!native
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BoardTypes = require(ReplicatedStorage.Board.BoardTypes)
local TileFlag = require(ReplicatedStorage.Board.Enum.TileFlag)

local function getFlagCount(tile: BoardTypes.Tile): number
	return if bit32.btest(tile.state, TileFlag.FLAG) then 1 else 0
end

return getFlagCount