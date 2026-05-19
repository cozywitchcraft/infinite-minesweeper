--!strict

local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CameraShakeOptions = require(script.CameraShakeOptions)
local Explosions = require(ReplicatedStorage.Explosions)
local Settings = require(ReplicatedStorage.Settings.Settings)

local DECAY_RATE = 8

local MAX_ATTACK = 256
local MAX_DISTANCE = 1024
local MAX_MAGNITUDE = 4

local cameraShake = Settings.cameraShake

local camera = assert(workspace.CurrentCamera, "Cannot find CurrentCamera")

local magnitude = 0

local function isCameraShakeDisabled(): boolean
	if cameraShake.value == CameraShakeOptions.AUTO then
		return GuiService.ReducedMotionEnabled
	end

	return cameraShake.value == CameraShakeOptions.OFF
end

local function onExplosionAdded(position: Vector3)
	-- I don't see the need to invert this more than once (not not true == true)
	if isCameraShakeDisabled() then
		return
	end

	local subject = camera.CameraSubject

	if not subject or not subject:IsA("Humanoid") then
		return
	end

	local rootPart = subject.RootPart

	if rootPart then
		local delta = rootPart.Position - position
		local square = delta:Dot(delta)

		if square <= MAX_DISTANCE then
			magnitude = math.min(magnitude + MAX_ATTACK / square, MAX_MAGNITUDE)
		end
	end
end

local function shakeCamera(deltaTime: number)
	local subject = camera.CameraSubject

	if not subject or not subject:IsA("Humanoid") then
		return
	end

	if magnitude > 0 then
		subject.CameraOffset = magnitude * Vector3.new(
			math.random() - 0.5,
			math.random() - 0.5,
			math.random() - 0.5
		)
	else
		subject.CameraOffset = Vector3.zero
	end

	magnitude = math.max(magnitude - DECAY_RATE * deltaTime, 0)
end

Explosions.explosionAdded:connect(onExplosionAdded)

RunService:BindToRenderStep("CameraShake", Enum.RenderPriority.Camera.Value + 2, shakeCamera)
