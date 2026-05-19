local function createDummy(parent: Instance)
	local dummy = Instance.new("Model")
	dummy.Name = "Dummy"

	local humanoid = Instance.new("Humanoid")
	humanoid.AutoRotate = false
	humanoid.EvaluateStateMachine = false
	humanoid.Parent = dummy

	local rootPart = Instance.new("Part")
	rootPart.Anchored = true
	rootPart.CanCollide = false
	rootPart.CanQuery = false
	rootPart.Transparency = 1
	rootPart.Size = Vector3.new(2, 2, 1)
	rootPart.Name = "HumanoidRootPart"
	rootPart.Parent = dummy

	dummy.Parent = parent

	return {
		humanoid = humanoid,
		rootPart = rootPart,
	}
end

return createDummy
