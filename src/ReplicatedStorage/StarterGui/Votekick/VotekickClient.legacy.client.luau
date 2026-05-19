local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local RemoteClient = require(ReplicatedStorage.Remote.RemoteClient)
local Player = require(ReplicatedStorage.Util.Player)

local TWEEN_INFO = TweenInfo.new(10, Enum.EasingStyle.Linear)

local playerVoted = RemoteClient.getRemoteEvent("PlayerVoted")

local votekickStarted = RemoteClient.getRemoteEvent("VotekickStarted")
local votekickStopped = RemoteClient.getRemoteEvent("VotekickStopped")

local outlineFrame = script.Outline:Clone()

local votekickGui = script.Parent

local windowFrame = votekickGui.Window
local timerFrame = windowFrame.Timer

local noButton = windowFrame.No
local yesButton = windowFrame.Yes

local messageLabel = windowFrame.Message

local timerFrameTween = TweenService:Create(timerFrame, TWEEN_INFO, {
	Size = UDim2.new(0, 0, 0, 8),
})

votekickStarted.OnClientEvent:Connect(function(candidate)
	if not candidate then
		return
	end
	
	messageLabel.Text = `Kick {Player.getDisplayName(candidate)}?`
	
	timerFrame.Size = UDim2.new(1, 0, 0, 8)

	outlineFrame.Parent = nil

	votekickGui.Enabled = true
	
	timerFrameTween:Play()
end)

timerFrameTween.Completed:Connect(function()
	votekickGui.Enabled = false
end)

votekickStopped.OnClientEvent:Connect(function()
	votekickGui.Enabled = false
end)

noButton.Activated:Connect(function()
	playerVoted:FireServer(false)
	outlineFrame.Parent = noButton
end)

yesButton.Activated:Connect(function()
	playerVoted:FireServer(true)
	outlineFrame.Parent = yesButton
end)
