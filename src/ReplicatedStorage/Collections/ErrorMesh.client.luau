local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

RunService.Heartbeat:Connect(function()
	local color = Vector3.one * (1 + math.sin(os.clock() * math.pi * 4) / 4)

	for _, mesh in CollectionService:GetTagged("ErrorMesh") do
		if mesh:IsA("SpecialMesh") then
			mesh.VertexColor = color
		end
	end
end)