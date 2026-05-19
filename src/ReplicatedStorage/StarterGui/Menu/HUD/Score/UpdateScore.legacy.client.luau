--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = require(ReplicatedStorage.Settings.Settings)
local bindVisibilitySetting = require(ReplicatedStorage.UI.bindVisibilitySetting)

local localPlayer = assert(Players.LocalPlayer, "expected Player, got nil")

local leaderstats = localPlayer:WaitForChild("leaderstats")
local score = leaderstats:WaitForChild("Score")

assert(score:IsA("IntValue"), "expected IntValue, got nil")

local scoreLabel = script.Parent

local function updateScore()
	scoreLabel.Text = "Score: " .. score.Value
end

bindVisibilitySetting(Settings.showScore, scoreLabel)

score:GetPropertyChangedSignal("Value"):Connect(updateScore)

updateScore()