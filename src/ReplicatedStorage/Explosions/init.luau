--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Particle = require(script.Particle)
local Pool = require(ReplicatedStorage.Util.Pool)
local Settings = require(ReplicatedStorage.Settings.Settings)
local Signal = require(ReplicatedStorage.Util.Signal)

local particlePool: Pool.Pool<Particle.Particle, Vector3, number> = Pool.new(Particle.new, Particle.use)
particlePool:allocate(10)

local explosionAdded: Signal.Signal<Vector3> = Signal.new()

local Explosions = {
	explosionAdded = explosionAdded,
}

function Explosions.add(position: Vector3)
	if not Settings.explosionsEnabled.value then
		return
	end

	particlePool:use(position, 30)

	explosionAdded:fire(position)
end

return table.freeze(Explosions)
