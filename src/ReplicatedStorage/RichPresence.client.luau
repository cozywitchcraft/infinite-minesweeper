--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Attribute = require(ReplicatedStorage.Util.Attribute)
local BloxstrapRPC = require(ReplicatedStorage.Packages.BloxstrapRPC)

local function updateRoundInfo()
	local roundStart = Attribute.getNumber(workspace, "RoundStart")
	local roundEnd = Attribute.getNumber(workspace, "RoundEnd")

	if roundStart > roundEnd then
		local state = "Round in progress"

		local lives = Attribute.getNumber(workspace, "Lives")

		if lives > 1 then
			state ..= ` ({lives} lives left)`
		elseif lives == 1 then
			state ..= " (1 life left)"
		end

		BloxstrapRPC.SetRichPresence({
			state = state,
			timeStart = roundStart,
			timeEnd = 0,
		})
	else
		BloxstrapRPC.SetRichPresence({
			state = "Round over",
			timeStart = roundStart,
			timeEnd = roundEnd,
		})
	end
end

if not RunService:IsStudio() then
	workspace:GetAttributeChangedSignal("RoundStart"):Connect(updateRoundInfo)
	workspace:GetAttributeChangedSignal("RoundEnd"):Connect(updateRoundInfo)
	workspace:GetAttributeChangedSignal("Lives"):Connect(updateRoundInfo)

	updateRoundInfo()
end
