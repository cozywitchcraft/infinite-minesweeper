local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Explosions = require(ReplicatedStorage.Explosions)

local function onExplosionAdded(explosion: Instance)
	assert(explosion:IsA("Explosion"), "Instance must be an Explosion")

	if explosion.Visible then
		explosion.Visible = false

		Explosions.add(explosion.Position)
	end
end

CollectionService:GetInstanceAddedSignal("Explosion"):Connect(onExplosionAdded)
