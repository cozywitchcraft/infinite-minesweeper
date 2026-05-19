local MessagingService = game:GetService("MessagingService")
local ServerScriptService = game:GetService("ServerScriptService")

local RemoteServer = require(ServerScriptService.RemoteServer)

local announced = RemoteServer.getRemoteEvent("Announced")

MessagingService:SubscribeAsync("announce", function(message)
	if typeof(message.Data) == "string" then
		announced:FireAllClients(message.Data, "FFFF00")
	end
end)