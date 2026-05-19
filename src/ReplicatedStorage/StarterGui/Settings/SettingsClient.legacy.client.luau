--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Color = require(ReplicatedStorage.UI.Color)
local DefaultSettings = require(ReplicatedStorage.Settings.DefaultSettings)
local Dropdown = require(ReplicatedStorage.UI.Dropdown)
local Field = require(ReplicatedStorage.UI.Field)
local RemoteClient = require(ReplicatedStorage.Remote.RemoteClient)
local Materials = require(ReplicatedStorage.Materials)
local Serdes = require(ReplicatedStorage.Settings.Serdes)
local Settings = require(ReplicatedStorage.Settings.Settings)
local Skyboxes = require(ReplicatedStorage.Assets.Skyboxes)
local Slider = require(ReplicatedStorage.UI.Slider)
local Switch = require(ReplicatedStorage.UI.Switch)
local createHeading = require(ReplicatedStorage.UI.createHeading)

local settingsReset = RemoteClient.getRemoteEvent("SettingsReset")
local settingsLoaded = RemoteClient.getRemoteEvent("SettingsLoaded")
local settingUpdated = RemoteClient.getRemoteEvent("SettingUpdated")

local settingsGui = script.Parent

local windowFrame = settingsGui.Window
local optionsFrame = windowFrame.Options

local closeButton = windowFrame.Close
local resetButton = windowFrame.Reset

local layout = optionsFrame.Layout

local materials = {}

for _, material in Materials do
	table.insert(materials, material.Name)
end

local skyboxes = {}

for _, skybox in Skyboxes do
	table.insert(skyboxes, skybox.Name)
end

local settings = Settings :: { [string]: Settings.Setting<any> }
local defaultSettings = DefaultSettings :: { [string]: Settings.Setting<any> }

-- blegh
local function createElement(settingName, class, options)
	local setting = settings[settingName]
	
	options.value = setting.value
	options.parent = optionsFrame
	
	local element = class.new(options)
	
	element.changed:connect(function()
		setting:changeValue(element.value)
		settingUpdated:FireServer(settingName, element.value)
	end)

	setting.changed:connect(function()
		element:setValue(setting.value)
	end)
end

createHeading("General", optionsFrame)

createElement("announcementsEnabled", Switch, { name = "Announcements" })
createElement("vignetteEnabled", Switch, { name = "Vignette" })

createElement("skybox", Dropdown, {
	name = "Skybox",
	items = skyboxes,
})

createHeading("Particles", optionsFrame)

createElement("explosionsEnabled", Switch, { name = "Explosions" })
createElement("sparklesEnabled", Switch, { name = "Sparkles" })

createHeading("Camera", optionsFrame)

createElement("topdownView", Switch, { name = "Top-Down View" })
createElement("freezeCameraOnDeath", Switch, { name = "Freeze Camera on Death" })
createElement("cameraShake", Dropdown, {
	name = "Camera Shake",
	items = {
		"Auto",
		"On",
		"Off",
	}
})

createHeading("Board", optionsFrame)

createElement("chordingEnabled", Switch, { name = "Chording Enabled" })
createElement("ignoreFlags", Switch, { name = "Ignore Flags" })

createElement("fieldColorLight", Color, { name = "Field Color Light" })
createElement("fieldColorDark", Color, { name = "Field Color Dark" })

createElement("groundColorLight", Color, { name = "Ground Color Light" })
createElement("groundColorDark", Color, { name = "Ground Color Dark" })

createElement("fieldMaterial", Dropdown, {
	name = "Field Material",
	items = materials,
})

createElement("groundMaterial", Dropdown, {
	name = "Ground Material",
	items = materials,
})

createHeading("Highlight", optionsFrame)

createElement("highlightEnabled", Switch, { name = "Highlight Enabled" })
createElement("highlightColor", Color, { name = "Highlight Color" })
createElement("highlightSpeed", Field, {
	name = "Highlight Speed",
	min = 0,
	precision = 0.01,
})

createHeading("Sound", optionsFrame)

createElement("characterVolume", Slider, {
	name = "Character Volume",
	min = 0,
	max = 100,
	precision = 1,
})

createElement("explosionVolume", Slider, {
	name = "Explosion Volume",
	min = 0,
	max = 100,
	precision = 1,
})

createElement("flagVolume", Slider, {
	name = "Flag Volume",
	min = 0,
	max = 100,
	precision = 1,
})

createElement("alertVolume", Slider, {
	name = "Alert Volume",
	min = 0,
	max = 100,
	precision = 1,
})

createHeading("Display", optionsFrame)

createElement("showTileCount", Switch, { name = "Show Tile Count" })
createElement("showMineCount", Switch, { name = "Show Mine Count" })
createElement("showFlagCount", Switch, { name = "Show Flag Count" })

createElement("showScore", Switch, { name = "Show Score" })
createElement("showCoords", Switch, { name = "Show Coordinates" })

createHeading("Timers", optionsFrame)

createElement("showRoundTimer", Switch, { name = "Show Round Timer" })
createElement("showSessionTimer", Switch, { name = "Show Session Timer" })

-- Fix overlap
local children = optionsFrame:GetChildren()

for index, child in children do
	if child:IsA("GuiBase2d") then
		child.ZIndex = #children - index
	end
end

settingsLoaded.OnClientEvent:Connect(function(settingsData)	
	for settingName, value in settingsData do
		Settings[settingName]:changeValue(Serdes.deseralize(value))
	end
end)

closeButton.Activated:Connect(function()
	settingsGui.Enabled = false
end)

resetButton.Activated:Connect(function()
	for settingName, setting in settings do
		setting:changeValue(DefaultSettings[settingName])
	end

	settingsReset:FireServer()
end)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	optionsFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5)
end)

optionsFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5)