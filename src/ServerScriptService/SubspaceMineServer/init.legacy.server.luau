--!nonstrict
local CollectionService = game:GetService("CollectionService")

local RemoteServer = require(script.Parent.RemoteServer)
local SubspaceMine = require(script.SubspaceMine)

local minesPulsed = RemoteServer.getRemoteEvent("MinesPulsed")

local subspaceMines = {}

CollectionService:GetInstanceAddedSignal("SubspaceMine"):Connect(function(mine)
	subspaceMines[mine] = SubspaceMine.new(mine)
end)

CollectionService:GetInstanceRemovedSignal("SubspaceMine"):Connect(function(mine)
	subspaceMines[mine] = subspaceMines[mine]:destroy()
end)

while true do
	local deltaTime = task.wait(0.5)

	for _, subspaceMine in subspaceMines do
		subspaceMine:update(deltaTime)
	end
	
	if #SubspaceMine.pulsed > 0 then
		minesPulsed:FireAllClients(SubspaceMine.pulsed)
		table.clear(SubspaceMine.pulsed)
	end
end