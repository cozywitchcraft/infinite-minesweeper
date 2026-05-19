local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Attribute = require(ReplicatedStorage.Util.Attribute)
local Settings = require(ReplicatedStorage.Settings.Settings)
local bindVisibilitySetting = require(ReplicatedStorage.UI.bindVisibilitySetting)
local localizeInt = require(ReplicatedStorage.UI.localizeInt)

local camera = assert(workspace.CurrentCamera, "CurrentCamera is nil")

local displayFrame = script.Parent

local tileCountLabel = displayFrame.TileCount
local mineCountLabel = displayFrame.MineCount
local flagCountLabel = displayFrame.FlagCount
local livesLabel = displayFrame.Lives

local function onLastInputTypeChanged(lastInputType: Enum.UserInputType)
	local viewportSize = camera.ViewportSize
	local minAxis = math.min(viewportSize.X, viewportSize.Y)

	if minAxis <= 500 and lastInputType == Enum.UserInputType.Touch then
		displayFrame.Position = UDim2.new(1, 0, 1, -90)
	else
		displayFrame.Position = UDim2.new(1, 0, 1, 0)
	end
end

local function updateTileCount()
	local tileCount = Attribute.getNumber(workspace, "TileCount")
	tileCountLabel.Text = "Tiles: " .. localizeInt(tileCount)
end

local function updateMineCount()
	local mineCount = Attribute.getNumber(workspace, "MineCount")
	mineCountLabel.Text = "Mines: " .. localizeInt(mineCount)
end

local function updateFlagCount()
	local flagCount = Attribute.getNumber(workspace, "FlagCount")
	flagCountLabel.Text = "Flags: " .. localizeInt(flagCount)
end

local function updateLives()
	local lives = Attribute.getNumber(workspace, "Lives")
	
	if lives > 5 then
		livesLabel.Text = "\u{2665}x" .. localizeInt(lives)
	elseif lives > 0 then
		livesLabel.Text = string.rep("\u{2665}", lives)
	elseif lives == 0 then
		livesLabel.Text = "<b>\u{2661}</b>x0"
	else
		livesLabel.Text = "\u{2665}x\u{221E}"
	end
end

bindVisibilitySetting(Settings.showTileCount, tileCountLabel)
bindVisibilitySetting(Settings.showMineCount, mineCountLabel)
bindVisibilitySetting(Settings.showFlagCount, flagCountLabel)

workspace:GetAttributeChangedSignal("TileCount"):Connect(updateTileCount)
workspace:GetAttributeChangedSignal("MineCount"):Connect(updateMineCount)
workspace:GetAttributeChangedSignal("FlagCount"):Connect(updateFlagCount)
workspace:GetAttributeChangedSignal("Lives"):Connect(updateLives)

UserInputService.LastInputTypeChanged:Connect(onLastInputTypeChanged)

updateTileCount()
updateMineCount()
updateFlagCount()
updateLives()

onLastInputTypeChanged(UserInputService:GetLastInputType())