--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

local RemoteClient = require(ReplicatedStorage.Remote.RemoteClient)
local Settings = require(ReplicatedStorage.Settings.Settings)

local lifeLost = RemoteClient.getRemoteEvent("LifeLost")

local vignetteEnabled = Settings.vignetteEnabled

local localPlayer = assert(Players.LocalPlayer, "expected Player, got nil")

local vignette = script.Parent

local tween = TweenService:Create(vignette, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
	Size = UDim2.new(2, 0, 2, 0)
})

tween.Completed:Connect(function(playbackState)
	if playbackState == Enum.PlaybackState.Completed then
		vignette.Visible = false
	end
end)

local function animateVignette()
	if not vignetteEnabled.value then
		return
	end

	if tween.PlaybackState == Enum.PlaybackState.Playing then
		tween:Cancel()
	end

	vignette.Visible = true
	vignette.Size = UDim2.new(1, 0, 1, 0)

	tween:Play()
end

lifeLost.OnClientEvent:Connect(function(player: Player)
	if player == localPlayer then
		animateVignette()
	end
end)

ContentProvider:PreloadAsync({ vignette })