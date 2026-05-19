local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Attribute = require(ReplicatedStorage.Util.Attribute)
local Badges = require(script.Parent.Parent.Badges)

-- UserIds must be deserialized as strings
local scores: { [string]: number } = {}
local scoreValues: { [Player]: IntValue } = {}

local function getUserId(player: Player): string
	return tostring(player.UserId)
end

local function awardScoreBadge(player: Player, score: number)
	if not Attribute.getBoolean(workspace, "StatsEnabled") then
		return
	end
	
	if score >= 2400 then
		task.defer(Badges.awardBadge, player, 2143154171)
	elseif score >= 1600 then
		task.defer(Badges.awardBadge, player, 2143154146)
	elseif score >= 800 then
		task.defer(Badges.awardBadge, player, 2143154140)
	end
end

local Scores = {}

function Scores.addPlayer(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local scoreValue = Instance.new("IntValue")
	scoreValue.Name = "Score"
	scoreValue.Value = scores[getUserId(player)] or 0
	scoreValue.Parent = leaderstats
	
	scoreValues[player] = scoreValue
end

function Scores.removePlayer(player: Player)
	scoreValues[player] = nil
end

function Scores.getScores()
	return table.clone(scores)
end

function Scores.setScores(newScores: { [string]: number })
	scores = table.clone(newScores)
	
	for player, scoreValue in scoreValues do
		scoreValue.Value = scores[getUserId(player)] or 0
	end
end

function Scores.increment(player: Player, amount: number)
	local score = scores[getUserId(player)] or 0
	score += amount
	
	scores[getUserId(player)] = score
	scoreValues[player].Value = score
	
	awardScoreBadge(player, score)
end

function Scores.reset()
	table.clear(scores)
	
	for _, scoreValue in scoreValues do
		scoreValue.Value = 0
	end
end

return Scores