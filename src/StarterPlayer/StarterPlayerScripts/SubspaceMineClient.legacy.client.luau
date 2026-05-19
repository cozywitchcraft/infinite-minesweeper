--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local RemoteClient = require(ReplicatedStorage.Remote.RemoteClient)
local Settings = require(ReplicatedStorage.Settings.Settings)
local SubspaceMine = require(ReplicatedStorage.SubspaceMine)

local sparklesEnabled = Settings.sparklesEnabled

local minesPulsed = RemoteClient.getRemoteEvent("MinesPulsed")

local subspaceMines = {}

local function pinkify(color: Color3): Color3
	return Color3.new(1, if color.G > 0.5 then 1 - color.G else color.G, 1)
end

local function addSubspaceMine(mine)
	subspaceMines[mine] = SubspaceMine.new(mine)
end

local function removeSubspaceMine(mine)
	if subspaceMines[mine] then
		subspaceMines[mine] = subspaceMines[mine]:destroy()
	end
end

local function onExplosionHit(part)
	if part.Mass < 300 then
		part.Color = pinkify(part.Color)
		
		if sparklesEnabled.value then
			local sparkles = Instance.new("Sparkles")
			sparkles.Parent = part
				
			task.wait(5)
				
			sparkles:Destroy()
		end
	end
end

minesPulsed.OnClientEvent:Connect(function(mines)
	for _, mine in mines do
		local subspaceMine = subspaceMines[mine]
		
		if subspaceMine then
			subspaceMine:pulse()
		end
	end
end)

CollectionService:GetInstanceAddedSignal("SubspaceExplosion"):Connect(function(explosion)
	explosion.Hit:Connect(onExplosionHit)
	
	local subspaceMine = subspaceMines[explosion.Parent]
	
	if subspaceMine then
		subspaceMine:explode()
	end
end)

CollectionService:GetInstanceAddedSignal("SubspaceMine"):Connect(addSubspaceMine)
CollectionService:GetInstanceRemovedSignal("SubspaceMine"):Connect(removeSubspaceMine)

for _, mine in CollectionService:GetTagged("SubspaceMine") do
	task.defer(addSubspaceMine, mine)
end