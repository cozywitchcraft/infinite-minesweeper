local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Attribute = require(ReplicatedStorage.Util.Attribute)
local Settings = require(ReplicatedStorage.Settings.Settings)
local Time = require(ReplicatedStorage.Util.Time)
local bindVisibilitySetting = require(ReplicatedStorage.UI.bindVisibilitySetting)

local roundTimer = script.Parent.RoundTimer
local sessionTimer = script.Parent.SessionTimer

local function getRoundDuration()
	local roundStart = Attribute.getNumber(workspace, "RoundStart")
	local roundEnd = Attribute.getNumber(workspace, "RoundEnd")
	
	if roundStart > roundEnd then
		return workspace:GetServerTimeNow() - roundStart
	else
		return roundEnd - roundStart
	end
end

local function updateTimers()
	if Settings.showRoundTimer.value then
		roundTimer.Text = "Round Duration: " .. Time.formatTimeHours(getRoundDuration())
	end
	
	if Settings.showSessionTimer.value then
		sessionTimer.Text = "Session Duration: " .. Time.formatTimeHours(time())
	end
end

bindVisibilitySetting(Settings.showRoundTimer, roundTimer)
bindVisibilitySetting(Settings.showSessionTimer, sessionTimer)

while true do
	updateTimers()
	task.wait(1)
end