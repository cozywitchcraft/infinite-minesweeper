local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Character = require(ReplicatedStorage.Util.Character)
local ClientConfig = require(ReplicatedStorage.Board.ClientConfig)
local Settings = require(ReplicatedStorage.Settings.Settings)
local TilePosition = require(ReplicatedStorage.Board.TilePosition)
local bindVisibilitySetting = require(ReplicatedStorage.UI.bindVisibilitySetting)

local localPlayer = assert(Players.LocalPlayer, "LocalPlayer is nil")

local coordsLabel = script.Parent

local postSimulationConnection: RBXScriptConnection

local function onHumanoidDied()
	if postSimulationConnection and postSimulationConnection.Connected then
		postSimulationConnection:Disconnect()
	end
end

local function onHumanoidAdded(humanoid: Humanoid)
	postSimulationConnection = RunService.PostSimulation:Connect(function()
		local rootPart = humanoid.RootPart
		
		if not rootPart then
			return
		end
		
		local position = TilePosition.toGrid(
			rootPart.Position,
			ClientConfig.config.tileSize,
			ClientConfig.config.tileShape
		)
		
		coordsLabel.Text = string.format("(%d, %d)", position.X, position.Z)
	end)
	
	humanoid.Died:Once(onHumanoidDied)
end

local function onCharacterAdded(character: Model)
	Character.bindHumanoid(character, onHumanoidAdded)
end

bindVisibilitySetting(Settings.showCoords, coordsLabel)

localPlayer.CharacterAdded:Connect(onCharacterAdded)
localPlayer.CharacterRemoving:Connect(onHumanoidDied)

if localPlayer.Character then
	onCharacterAdded(localPlayer.Character)
end