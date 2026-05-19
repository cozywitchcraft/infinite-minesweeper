--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Character = require(ReplicatedStorage.Util.Character)
local Settings = require(ReplicatedStorage.Settings.Settings)
local createDummy = require(script.createDummy)

local freezeCameraOnDeath = Settings.freezeCameraOnDeath

local localPlayer = assert(Players.LocalPlayer, "expected Player, got nil")
local camera = assert(workspace.CurrentCamera, "expected CurrentCamera, got nil")

local dummy = createDummy(camera)

local function onHumanoidAdded(humanoid: Humanoid)
	camera.CameraSubject = humanoid

	humanoid.Died:Once(function()
		if not freezeCameraOnDeath.value then
			return
		end

		local rootPart = humanoid.RootPart

		if rootPart then
			camera.CameraSubject = dummy.humanoid
			dummy.rootPart.CFrame = rootPart.CFrame
		end
	end)
end

local function onCharacterAdded(character: Model)
	Character.bindHumanoid(character, onHumanoidAdded)
end

localPlayer.CharacterAdded:Connect(onCharacterAdded)

if localPlayer.Character then
	task.defer(onCharacterAdded, localPlayer.Character)
end
