local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = require(ReplicatedStorage.Settings.Settings)

local function bindVisibilitySetting(setting: Settings.Setting<boolean>, guiObject: GuiObject): () -> ()
	guiObject.Visible = setting.value
	
	return setting.changed:connect(function()
		guiObject.Visible = setting.value
	end)
end

return bindVisibilitySetting