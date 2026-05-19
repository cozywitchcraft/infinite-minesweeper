--!strict
local function darken(color: { number }): { number }
	return { 0.8 * color[1], 0.8 * color[2], 0.8 * color[3] }
end

local function updateSettings(settings: { [string]: any }?): { [string]: any }
	if settings == nil then
		return {}
	end
	
	settings = table.clone(settings)
	settings.announcementsEnabled = settings.announcements

	-- Decrement ids by 1
	if settings.skybox then
		settings.skybox -= 1
	end

	if settings.fieldMaterial then
		settings.fieldMaterial -= 1
	end

	if settings.groundMaterial then
		settings.groundMaterial -= 1
	end

	-- Update colors
	if settings.fieldColor then
		settings.fieldColorLight = settings.fieldColor
		settings.fieldColorDark = darken(settings.fieldColor)
	end

	if settings.groundColor then
		settings.groundColorLight = settings.groundColor
		settings.groundColorDark = darken(settings.groundColor)
	end
	
	return settings
end 

return updateSettings