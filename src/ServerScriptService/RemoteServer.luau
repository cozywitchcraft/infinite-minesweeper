--!strict

--[[
	Creates remote instances as needed
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteEventsFolder = Instance.new("Folder")
remoteEventsFolder.Name = "RemoteEvents"
remoteEventsFolder.Parent = ReplicatedStorage

local remoteFunctionsFolder = Instance.new("Folder")
remoteFunctionsFolder.Name = "RemoteFunctions"
remoteFunctionsFolder.Parent = ReplicatedStorage

local unreliableRemoteEventsFolder = Instance.new("Folder")
unreliableRemoteEventsFolder.Name = "UnreliableRemoteEvents"
unreliableRemoteEventsFolder.Parent = ReplicatedStorage

local remoteEvents: { [string]: RemoteEvent } = {}
local remoteFunctions: { [string]: RemoteFunction } = {}
local unreliableRemoteEvents: { [string]: UnreliableRemoteEvent } = {}

local RemoteServer = {}

function RemoteServer.getRemoteEvent(name: string): RemoteEvent
	local remoteEvent = remoteEvents[name]

	if not remoteEvent then
		remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = name
		remoteEvent.Parent = remoteEventsFolder

		remoteEvents[name] = remoteEvent
	end

	return remoteEvent
end

function RemoteServer.getRemoteFunction(name: string): RemoteFunction
	local remoteFunction = remoteFunctions[name]

	if not remoteFunction then
		remoteFunction = Instance.new("RemoteFunction")
		remoteFunction.Name = name
		remoteFunction.Parent = remoteFunctionsFolder

		remoteFunctions[name] = remoteFunction
	end

	return remoteFunction
end

function RemoteServer.getUnreliableRemoteEvent(name: string): UnreliableRemoteEvent
	local unreliableRemoteEvent = unreliableRemoteEvents[name]

	if not unreliableRemoteEvent then
		unreliableRemoteEvent = Instance.new("UnreliableRemoteEvent")
		unreliableRemoteEvent.Name = name
		unreliableRemoteEvent.Parent = unreliableRemoteEventsFolder

		unreliableRemoteEvents[name] = unreliableRemoteEvent
	end

	return unreliableRemoteEvent
end

return RemoteServer
