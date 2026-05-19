--!strict
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Util.Signal)

export type BadgeInfo = {
	Name: string,
	Description: string,
	IconImageId: string,
	IsEnabled: string,
}

local badgeInfoMemo: { [number]: BadgeInfo } = {}
local hasBadgeMemo: { [string]: boolean } = {}

local function BadgeInfo(dictionary: { [string]: any }): BadgeInfo
	return dictionary
end

local Badges = {
	badgeAwarded = Signal.new()
}

function Badges.hasBadge(player: Player, badgeId: number): boolean
	local userId = player.UserId

	if hasBadgeMemo[`{userId}_{badgeId}`] then
		return true
	end

	local success, hasBadge = pcall(function()
		return BadgeService:UserHasBadgeAsync(userId, badgeId)
	end)

	if success and hasBadge then
		hasBadgeMemo[`{userId}_{badgeId}`] = true
	elseif not success then
		warn("Error while checking if user has badge:", hasBadge)
		return false
	end

	return hasBadge
end

function Badges.awardBadge(player: Player, badgeId: number): boolean
	if Badges.hasBadge(player, badgeId) then
		return true
	end

	local userId = player.UserId

	local success, result = pcall(function()
		return BadgeService:AwardBadgeAsync(userId, badgeId)
	end)

	if success and result then
		hasBadgeMemo[`{userId}_{badgeId}`] = true
		Badges.badgeAwarded:fire(player, badgeId)
	elseif not success then
		warn("Error while awarding badge:", result)
		return false
	elseif not result then
		warn("Failed to award badge.")
		return false
	end

	return result
end

function Badges.getBadgeInfo(badgeId: number): BadgeInfo?
	if badgeInfoMemo[badgeId] then
		return badgeInfoMemo[badgeId]
	end
	
	local success, badgeInfo = pcall(function()
		return BadgeService:GetBadgeInfoAsync(badgeId)
	end)
	
	if success then
		badgeInfoMemo[badgeId] = BadgeInfo(badgeInfo)
	else
		warn("Error while getting badge info:", badgeInfo)
		return nil
	end
	
	return BadgeInfo(badgeInfo)
end

return table.freeze(Badges)