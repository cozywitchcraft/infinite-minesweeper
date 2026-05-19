--!nonstrict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Player = require(ReplicatedStorage.Util.Player)
local Time = require(ReplicatedStorage.Util.Time)

local PLACEHOLDER_IMAGE = "rbxassetid://59414129"

local localPlayer = Players.LocalPlayer

local statsGui = script.Parent

local windowFrame = statsGui.Window

local dataFrame = windowFrame.Data
local infoFrame = windowFrame.Info

local searchBox = windowFrame.Search

local backButton = windowFrame.Back
local closeButton = windowFrame.Close

local timePlayedLabel = dataFrame.TimePlayed
local roundsPlayedLabel = dataFrame.RoundsPlayed

local tilesShownLabel = dataFrame.TilesShown
local minesFlaggedLabel = dataFrame.MinesFlagged
local livesLostLabel = dataFrame.LivesLost

local iconLabel = infoFrame.Icon

local displayNameLabel = infoFrame.DisplayName
local userIdLabel = infoFrame.UserId
local accountAgeLabel = infoFrame.AccountAge

local connections = {}

local watchingPlayer

local function updateTimePlayed()
	local timePlayed = watchingPlayer:GetAttribute("TimePlayed")
	local joinTime = watchingPlayer:GetAttribute("JoinTime")
	
	if timePlayed and joinTime then
		local duration = timePlayed + workspace:GetServerTimeNow() - joinTime
		timePlayedLabel.Text = "Time Played: " .. Time.formatTimeHours(duration)
	end
end

local function updateRoundsPlayed()
	local roundsPlayed = watchingPlayer:GetAttribute("RoundsPlayed")
	
	if roundsPlayed then
		roundsPlayedLabel.Text = "Rounds Finished: " .. roundsPlayed
	end
end

local function updateTilesShown()
	local tilesShown = watchingPlayer:GetAttribute("TilesShown")
	
	if tilesShown then
		tilesShownLabel.Text = "Tiles Shown: " .. tilesShown
	end
end

local function updateMinesFlagged()
	local minesFlagged = watchingPlayer:GetAttribute("MinesFlagged")
	
	if minesFlagged then
		minesFlaggedLabel.Text = "Mines Flagged: " .. minesFlagged
	end
end

local function updateLivesLost()
	local livesLost = watchingPlayer:GetAttribute("LivesLost")
	
	if livesLost then
		livesLostLabel.Text = "Lives Lost: " .. livesLost
	end
end

local function watchPlayer(player)
	if watchingPlayer == player then
		return
	end
	
	watchingPlayer = player
	
	for _, connection in connections do
		connection:Disconnect()
	end
	
	table.clear(connections)
	
	table.insert(connections, player:GetAttributeChangedSignal("RoundsPlayed")
		:Connect(updateRoundsPlayed))
	
	table.insert(connections, player:GetAttributeChangedSignal("TilesShown")
		:Connect(updateTilesShown))
	
	table.insert(connections, player:GetAttributeChangedSignal("MinesFlagged")
		:Connect(updateMinesFlagged))
	
	table.insert(connections, player:GetAttributeChangedSignal("LivesLost")
		:Connect(updateLivesLost))
	
	updateTimePlayed()
	updateRoundsPlayed()
	updateTilesShown()
	updateMinesFlagged()
	updateLivesLost()
	
	backButton.Visible = player ~= localPlayer
	
	displayNameLabel.Text = Player.getDisplayName(player)
	userIdLabel.Text = "User ID: " .. player.UserId
	accountAgeLabel.Text = "Account Age: " .. player.AccountAge
	
	local success, content, isReady = pcall(function()
		return Players:GetUserThumbnailAsync(player.UserId,
			Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	end)
	
	if success then
		iconLabel.Image = isReady and content or PLACEHOLDER_IMAGE
	else
		warn("Error while getting user thumbnail:", content)
	end
end

backButton.Activated:Connect(function()
	watchPlayer(localPlayer)
end)

closeButton.Activated:Connect(function()
	statsGui.Enabled = false
end)

searchBox.FocusLost:Connect(function()
	local player = Player.getPlayerByName(searchBox.Text)
	
	if player then
		watchPlayer(player)
	end
end)

watchPlayer(localPlayer)

while task.wait(1) do
	updateTimePlayed()
end