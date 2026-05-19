-- TODO: Reduce number of materials
local materials: { Enum.Material } = {}

for _, material in Enum.Material:GetEnumItems() do
	if material ~= Enum.Material.Air and material ~= Enum.Material.Water then
		table.insert(materials, material)
	end
end

return materials
