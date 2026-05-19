local BoardTypes = require(script.Parent.BoardTypes)

local structures: { BoardTypes.Structure } = {
	{ id = 0, size = 4, weight = 1 }, -- Ruins
	{ id = 1, size = 6, weight = 2 }, -- Tower
	{ id = 2, size = 3, weight = 1 }, -- Column
	{ id = 3, size = 4, weight = 1 }, -- BadgeAwarder
	{ id = 4, size = 6, weight = 2 }, -- RedTower
	{ id = 5, size = 6, weight = 2 }, -- Trampoline
	{ id = 6, size = 3, weight = 1 }, -- Tree
	{ id = 7, size = 3, weight = 1 }, -- YoungTree
}

local weights: { number } = {}
local totalWeight = 0

for _, structure in structures do	
	totalWeight += structure.weight
	table.insert(weights, totalWeight)
end

return {
	structures = structures,
	weights = weights,
}