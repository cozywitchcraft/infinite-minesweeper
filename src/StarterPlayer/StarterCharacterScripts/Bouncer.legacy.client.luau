--!strict
local XZ = Vector3.new(1, 0, 1)

local character = assert(script.Parent, "Parent is nil")
local humanoid = assert(character:FindFirstChildOfClass("Humanoid"), "Cannot find humanoid")

local function hor(v: Vector3, y: number): Vector3
	return XZ * v + y * Vector3.yAxis
end

humanoid.Touched:Connect(function(hit)
	if hit:HasTag("Bouncer") then
		local rootPart = humanoid.RootPart
		
		if rootPart then
			rootPart.AssemblyLinearVelocity = hor(rootPart.AssemblyLinearVelocity, 200)
		end
	end
end)