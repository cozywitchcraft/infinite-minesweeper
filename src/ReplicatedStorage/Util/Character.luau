--!strict
local Character = {}

function Character.bindHumanoid(character: Model, callback: (Humanoid) -> ())
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		callback(humanoid)
		return
	end

	local connection: RBXScriptConnection

	connection = character.ChildAdded:Connect(function(instance)
		if instance:IsA("Humanoid") then
			connection:Disconnect()
			callback(instance)
		end
	end)
end

function Character.getHumanoid(character: Model?): Humanoid?
	return character and character:FindFirstChildOfClass("Humanoid")
end

function Character.onExplosionHit(hit: BasePart)
	local humanoid = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
	
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	end
end

function Character.explode(character: Model?)
	local humanoid = Character.getHumanoid(character)

	if not humanoid or humanoid:GetState() == Enum.HumanoidStateType.Dead then
		return
	end

	local rootPart = humanoid.RootPart

	if not rootPart then
		return
	end

	humanoid:ChangeState(Enum.HumanoidStateType.Dead)

	local explosion = Instance.new("Explosion")
	explosion.BlastPressure = 1e6
	explosion.BlastRadius = 2
	explosion.Position = rootPart.Position
	explosion.Parent = workspace

	explosion.Hit:Connect(Character.onExplosionHit)

	explosion:AddTag("Explosion")
end

function Character.teleport(character: Model?, cframe: CFrame)
	local humanoid = Character.getHumanoid(character)

	if not humanoid or humanoid:GetState() == Enum.HumanoidStateType.Dead then
		return
	end

	local rootPart = humanoid.RootPart

	if rootPart then
		local hipHeight = 0.5 * rootPart.Size.Y + humanoid.HipHeight

		if humanoid.RigType == Enum.HumanoidRigType.R6 then
			hipHeight += 2
		end

		rootPart.CFrame = cframe + hipHeight * Vector3.yAxis
	end
end

function Character.quickRespawn(player: Player, cframe: CFrame)
	local humanoid = Character.getHumanoid(player.Character)

	if not humanoid or humanoid:GetState() == Enum.HumanoidStateType.Dead then
		pcall(function()
			player:LoadCharacterAsync()
		end)
	end

	Character.teleport(player.Character, cframe)
end

return Character
