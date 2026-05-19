--!strict

--[[
	Attribute identity functions
]]

local Attribute = {}

function Attribute.getBoolean(instance: Instance, name: string): boolean
	local attribute = instance:GetAttribute(name)

	assert(typeof(attribute) == "boolean", `Attribute {instance.Name}.{name} must be a boolean`)

	return attribute
end

function Attribute.getNumber(instance: Instance, name: string): number
	local attribute = instance:GetAttribute(name)

	assert(typeof(attribute) == "number", `Attribute {instance.Name}.{name} must be a number`)

	return attribute
end

return Attribute
