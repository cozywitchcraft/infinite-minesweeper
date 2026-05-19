--!strict

local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

local CHARACTER_GROUP = "Characters"

local function onChildAdded(child: Instance)
	if child:IsA("BasePart") then
		child.CollisionGroup = CHARACTER_GROUP
	end
end

local function onCharacterAdded(character: Model)
	character.ChildAdded:Connect(onChildAdded)

	for _, child in character:GetChildren() do
		onChildAdded(child)
	end
end

local function onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(onCharacterAdded)

	local character = player.Character

	if character then
		onCharacterAdded(character)
	end
end

PhysicsService:RegisterCollisionGroup(CHARACTER_GROUP)
PhysicsService:CollisionGroupSetCollidable(CHARACTER_GROUP, CHARACTER_GROUP, false)

Players.PlayerAdded:Connect(onPlayerAdded)

for _, player in Players:GetPlayers() do
	task.defer(onPlayerAdded, player)
end
