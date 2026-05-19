--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DefaultSettings = require(ReplicatedStorage.Settings.DefaultSettings)
local Serdes = require(ReplicatedStorage.Settings.Serdes)

local defaultSettings = DefaultSettings :: { [string]: any }

local function resetInvalidSettings(settings: { [string]: any }?): { [string]: any }
	if settings == nil then
		return {}
	end
	
	settings = table.clone(settings)
		
	for name, value in settings do
		local defaultValue = Serdes.serialize(defaultSettings[name])

		if typeof(defaultValue) ~= typeof(value) then
			settings[name] = nil
		end
	end
	
	return settings
end

return resetInvalidSettings