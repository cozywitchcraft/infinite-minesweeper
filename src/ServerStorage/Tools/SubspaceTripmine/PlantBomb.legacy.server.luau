local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tool = script.Parent
local uses = tool:GetAttribute("Uses")

local function plantBomb(position)
	local bomb = Instance.new("Part")
	bomb.CFrame = tool.Handle.CFrame
	bomb.Size = 2 * Vector3.one
	bomb.Parent = workspace
		
	CollectionService:AddTag(bomb, "SubspaceMine")
end

local function onActivated()
	if not tool.Enabled then
		return
	end
	
	local character = tool.Parent
	
	if not character or character:HasTag("Ghost") then
		return
	end
	
	local player = Players:GetPlayerFromCharacter(character)
	
	if not player then
		return
	end
	
	plantBomb(tool.Handle.Position)

	tool.Enabled = false
	tool.Handle.Transparency = 1
	
	uses -= 1
	
	if uses == 0 then
		tool:Destroy()
		return
	end
	
	task.wait(tool:GetAttribute("Cooldown"))
	
	tool.Handle.Transparency = 0
	tool.Enabled = true
end

tool.Activated:Connect(onActivated)