--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Explosions = require(ReplicatedStorage.Explosions)
local Pool = require(ReplicatedStorage.Util.Pool)
local Settings = require(ReplicatedStorage.Settings.Settings)
local SoundEmitter = require(script.SoundEmitter)

local MIN_ROLLOFF = 10000
local MIN_PITCH = 0.2

local soundPool: Pool.Pool<SoundEmitter.SoundEmitter, Vector3, number> = Pool.new(SoundEmitter.new, SoundEmitter.use)

local camera = assert(workspace.CurrentCamera, "expected CurrentCamera, got nil")

local function calculatePitch(position: Vector3): number
	local subject = camera.CameraSubject

	if subject and subject:IsA("Humanoid") then
		local rootPart = subject.RootPart

		if rootPart then
			local delta = rootPart.Position - position
			
			return math.min(MIN_ROLLOFF / delta:Dot(delta), 1)
		end
	end

	return 1
end

local function playExplosionSound(position: Vector3)
	if Settings.explosionVolume.value == 0 then
		return
	end

	local pitch = calculatePitch(position)

	if pitch >= MIN_PITCH then
		soundPool:use(position, pitch)
	end
end

soundPool:allocate(50)

Explosions.explosionAdded:connect(playExplosionSound)
