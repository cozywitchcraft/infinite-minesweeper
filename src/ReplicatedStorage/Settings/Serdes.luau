--!strict
local Serdes = {}

function Serdes.serialize(value: any): any
	if typeof(value) == "Color3" then
		return { 
			math.clamp(value.R, 0, 1),
			math.clamp(value.G, 0, 1),
			math.clamp(value.B, 0, 1),
		}
	end
	
	return value
end

function Serdes.deseralize(value: any): any
	if typeof(value) == "table" then
		return Color3.new(value[1], value[2], value[3])
	end
	
	return value
end

return Serdes