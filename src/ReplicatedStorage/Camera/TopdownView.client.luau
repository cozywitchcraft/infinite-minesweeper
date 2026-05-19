--!nonstrict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local localPlayer = assert(Players.LocalPlayer, "expected Player, got nil")
local playerScripts = localPlayer.PlayerScripts

local Settings = require(ReplicatedStorage.Settings.Settings)

local topdownView = Settings.topdownView

local camera = assert(workspace.CurrentCamera, "expected CurrentCamera, got nil")

local function onPlayerScriptsLoaded()
	local ZoomController = require(playerScripts.PlayerModule.CameraModule.ZoomController)

	local function onRenderStepped()
		local zoomRadius = ZoomController.GetZoomRadius()
		local position = camera.Focus.Position + zoomRadius * Vector3.yAxis

		camera.CFrame = CFrame.fromMatrix(position, Vector3.xAxis, -Vector3.zAxis)
	end

	local function toggleTopdownView()
		if topdownView.value then
			camera.FieldOfView = 60

			RunService:BindToRenderStep("TopdownView", Enum.RenderPriority.Camera.Value + 1, onRenderStepped)
		else
			camera.FieldOfView = 70

			RunService:UnbindFromRenderStep("TopdownView")
		end
	end

	topdownView.changed:connect(toggleTopdownView)

	toggleTopdownView()
end

if game:GetAttribute("PlayerScriptsLoaded") then
	onPlayerScriptsLoaded()
else
	game:GetAttributeChangedSignal("PlayerScriptsLoaded"):Once(onPlayerScriptsLoaded)
end
