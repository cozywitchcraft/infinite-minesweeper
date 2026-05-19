local convertFlagId = require(script.Parent.convertFlagId)

local DEFAULT_FLAG = 0

local function convertInventory(inventory: { string }?): { number }
	if inventory == nil then
		return { DEFAULT_FLAG }
	end
	
	local newInventory = {}
	
	for _, id in inventory do
		table.insert(newInventory, convertFlagId(id))
	end
	
	return newInventory
end

return convertInventory