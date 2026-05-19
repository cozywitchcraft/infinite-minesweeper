local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Attribute = require(ReplicatedStorage.Util.Attribute)
local RemoteClient = require(ReplicatedStorage.Remote.RemoteClient)

local lifeLost = RemoteClient.getRemoteEvent("LifeLost")

lifeLost.OnClientEvent:Connect(function()
	if Attribute.getNumber(workspace, "Lives") == 0 then
		SoundService.GameOver:Play()
	else
		SoundService.Alert:Play()
	end
end)