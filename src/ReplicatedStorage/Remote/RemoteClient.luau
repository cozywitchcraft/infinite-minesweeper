--!strict

--[[
	Retrieves remote instances
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local remoteFunctionsFolder = ReplicatedStorage:WaitForChild("RemoteFunctions")
local unreliableRemoteEventsFolder = ReplicatedStorage:WaitForChild("UnreliableRemoteEvents")

local remoteEvents: { [string]: RemoteEvent } = {}
local remoteFunctions: { [string]: RemoteFunction } = {}
local unreliableRemoteEvents: { [string]: UnreliableRemoteEvent } = {}

local function emptyName(instance: RemoteEvent|RemoteFunction|UnreliableRemoteEvent)
	if RunService:IsStudio() then
		return
	end

	instance.Name = ""

	instance:GetPropertyChangedSignal("Name"):Connect(function()
		instance.Name = ""
	end)
end

local RemoteClient = {}

function RemoteClient.getRemoteEvent(name: string): RemoteEvent
	local remoteEvent = remoteEvents[name]

	if not remoteEvent then
		remoteEvent = remoteEventsFolder:WaitForChild(name)
		
		assert(
			remoteEvent:IsA("RemoteEvent"),
			`{remoteEvent.Name} must be a RemoteEvent`
		)

		emptyName(remoteEvent)

		remoteEvents[name] = remoteEvent
	end

	return remoteEvent :: RemoteEvent
end

function RemoteClient.getRemoteFunction(name: string): RemoteFunction
	local remoteFunction = remoteFunctions[name]

	if not remoteFunction then
		remoteFunction = remoteFunctionsFolder:WaitForChild(name)
		
		assert(
			remoteFunction:IsA("RemoteFunction"),
			`{remoteFunction.Name} must be a RemoteFunction`
		)
		
		emptyName(remoteFunction)
		
		remoteFunctions[name] = remoteFunction
	end

	return remoteFunction :: RemoteFunction
end

function RemoteClient.getUnreliableRemoteEvent(name: string): UnreliableRemoteEvent
	local unreliableRemoteEvent = unreliableRemoteEvents[name]

	if not unreliableRemoteEvent then
		unreliableRemoteEvent = unreliableRemoteEventsFolder:WaitForChild(name)
		
		assert(
			unreliableRemoteEvent:IsA("UnreliableRemoteEvent"),
			`{unreliableRemoteEvent.Name} must be an UnreliableRemoteEvent`
		)

		emptyName(unreliableRemoteEvent)

		unreliableRemoteEvents[name] = unreliableRemoteEvent
	end

	return unreliableRemoteEvent :: UnreliableRemoteEvent
end

return RemoteClient
