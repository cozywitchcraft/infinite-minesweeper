--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteClient = require(ReplicatedStorage.Remote.RemoteClient)
local Dropdown = require(ReplicatedStorage.UI.Dropdown)
local Field = require(ReplicatedStorage.UI.Field)
local Slider = require(ReplicatedStorage.UI.Slider)
local Switch = require(ReplicatedStorage.UI.Switch)
local createHeading = require(ReplicatedStorage.UI.createHeading)

local MAX_SAFE_INTEGER = 2 ^ 53 - 1
local MAX_TERRAIN_SEED = 2 ^ 31 - 1

local configChanged = RemoteClient.getRemoteEvent("ConfigChanged")
local configReset = RemoteClient.getRemoteEvent("ConfigReset")

local restarted = RemoteClient.getRemoteEvent("Restarted")

local configFolder = ReplicatedStorage.Config

local configGui = script.Parent

local windowFrame = configGui.Window
local optionsFrame = windowFrame.Options

local closeButton = windowFrame.Close
local resetButton = windowFrame.Reset
local restartButton = windowFrame.Restart

local layout = optionsFrame.Layout

local function createElement(attribute, class, options)
	options.value = configFolder:GetAttribute(attribute)
	options.parent = optionsFrame

	local element = class.new(options)

	element.changed:connect(function()
		configFolder:SetAttribute(attribute, element.value)
		configChanged:FireServer(attribute, element.value)
	end)

	configFolder:GetAttributeChangedSignal(attribute):Connect(function()
		element:setValue(configFolder:GetAttribute(attribute))
	end)
end

createHeading("Board", optionsFrame)

--createElement("AutosaveEnabled", Switch, { name = "Autosave Enabled" })
createElement("UseSeed", Switch, { name = "Use Seed" })

createElement("Seed", Field, {
	name = "Seed",
	min = -MAX_SAFE_INTEGER,
	max = MAX_SAFE_INTEGER,
	precision = 1,
})

createElement("TileSize", Field, {
	name = "Tile Size",
	min = 0,
	max = 2048,
})

createElement("TileShape", Dropdown, {
	name = "Tile Shape",
	items = {
		"Square",
		"Hexagon",
	},
})

createElement("MineChance", Slider, {
	name = "Mine Chance",
	min = 0,
	max = 1,
	precision = 100,
})

createElement("StructureChance", Slider, {
	name = "Structure Chance",
	min = 0,
	max = 1,
	precision = 100,
})

createElement("MaxDistance", Field, {
	name = "Max Distance",
	min = 0,
	max = MAX_SAFE_INTEGER,
	precision = 1,
})

createElement("ExplodeCharacters", Switch, { name = "Explode Characters" })

createHeading("Terrain", optionsFrame)

createElement("TerrainIntensity", Field, {
	name = "Terrain Intensity",
	min = 0,
	max = MAX_SAFE_INTEGER,
	precision = 1,
})

createElement("TerrainDensity", Field, {
	name = "Terrain Density",
	min = 0,
	max = MAX_SAFE_INTEGER,
	precision = 1,
})

createHeading("Lives", optionsFrame)

createElement("AdjustLives", Switch, { name = "Adjust Lives" })

createElement("Lives", Field, {
	name = "Lives",
	min = -1,
	precision = 1,
})

createHeading("Restart", optionsFrame)

createElement("AutoRestart", Switch, { name = "Auto-Restart" })

createElement("RestartDelay", Field, {
	name = "Restart Delay",
	min = 0,
})

createHeading("Modifiers", optionsFrame)

createElement("Flagless", Switch, { name = "Flagless" })
createElement("Jumpless", Switch, { name = "Jumpless" })
createElement("Slippery", Switch, { name = "Slippery" })
createElement("Spheres", Switch, { name = "Spheres" })

createHeading("Tools", optionsFrame)

createElement("TripminesEnabled", Switch, { name = "Tripmines Enabled" })
createElement("TeleportEnabled", Switch, { name = "Teleport Enabled" })

-- Fix overlap
local children = optionsFrame:GetChildren()

for index, child in children do
	if child:IsA("GuiBase2d") then
		child.ZIndex = #children - index
	end
end

closeButton.Activated:Connect(function()
	configGui.Enabled = false
end)

resetButton.Activated:Connect(function()
	configReset:FireServer()
end)

restartButton.Activated:Connect(function()
	restarted:FireServer()
end)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	optionsFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5)
end)

optionsFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5)