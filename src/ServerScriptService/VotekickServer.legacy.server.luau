--!nonstrict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Player = require(ReplicatedStorage.Util.Player)
local RemoteServer = require(script.Parent.RemoteServer)
local Time = require(ReplicatedStorage.Util.Time)

local VOTEKICK_DURATION = 10

local announced = RemoteServer.getRemoteEvent("Announced")
local playerVoted = RemoteServer.getRemoteEvent("PlayerVoted")
local votekickStarted = RemoteServer.getRemoteEvent("VotekickStarted")
local votekickStopped = RemoteServer.getRemoteEvent("VotekickStopped")

local votekickCommand = TextChatService.TextChatCommands.IMSVotekickCommand

local votekickRunning = false

local playersVoted = {}

local voters = {}
local voterCount = 0

local yesVotes = 0
local noVotes = 0

local lastExecutor, lastCandidate
local lastVotekick = 0

local bannedIds = {}

local function stopVotekick()
	votekickRunning = false
	
	local candidateName = Player.getDisplayName(lastCandidate)	
	local result = `({yesVotes}/{noVotes})`
	
	if yesVotes > noVotes then
		local userId = lastCandidate.UserId
		bannedIds[userId] = tick() + 900
		
		local player = Players:GetPlayerByUserId(userId)
		
		if player then
			player:Kick("You have been votekicked from the server.")
		end
		
		announced:FireAllClients(`Votekick passed {result}! Kicking {candidateName}...`)
	else
		announced:FireAllClients(`Votekick failed {result}! Not enough votes to kick {candidateName}.`)
	end
	
	votekickStopped:FireAllClients(lastCandidate, yesVotes, noVotes)
end

local function startVotekick(executor, candidate)
	local players = Players:GetPlayers()

	if #players < 3 then
		announced:FireClient(executor, "Not enough players to start votekick!")
		return
	end

	local votekickDebounce = 60
	
	-- In case executor rejoins for faster votekick time
	if lastExecutor and executor.UserId == lastExecutor.UserId then
		votekickDebounce = 90
	end
	
	local timeLeft = votekickDebounce - tick() + lastVotekick
	
	if timeLeft > 0 then
		announced:FireClient(executor, string.format("Cannot start votekick for another %d seconds.", timeLeft))
		return
	end
	
	votekickRunning = true
	
	yesVotes = 0
	noVotes = 0
	
	lastExecutor = executor
	lastCandidate = candidate
	
	lastVotekick = tick()
	
	table.clear(playersVoted)
	table.clear(voters)
	
	for _, player in players do
		voters[player] = true
	end
	
	voterCount = #players
	
	votekickStarted:FireAllClients(candidate)
	
	local executorName = Player.getDisplayName(executor)
	local candidateName = Player.getDisplayName(candidate)
	
	announced:FireAllClients(`{executorName} started a votekick for {candidateName}! Need more 'Yes' than 'No' votes to kick.`)

	local current = lastVotekick
	
	task.wait(VOTEKICK_DURATION)
	
	if votekickRunning and lastVotekick == current then
		stopVotekick()
	end
end

playerVoted.OnServerEvent:Connect(function(player, choice)
	if not votekickRunning or not voters[player] then
		return
	end
	
	if playersVoted[player] ~= choice then
		local oldChoice = playersVoted[player]
		
		if oldChoice == true then
			yesVotes -= 1
		elseif oldChoice == false then
			noVotes -= 1
		end
	
		playersVoted[player] = choice
		
		if choice then
			yesVotes += 1
		else
			noVotes += 1
		end
		
		if yesVotes + noVotes >= voterCount then
			stopVotekick()
		end
	end
end)

votekickCommand.Triggered:Connect(function(textSource, message)
	local executor = Players:GetPlayerByUserId(textSource.UserId)
	
	if not executor then
		return
	end
	
	local name = string.sub(message, #"/votekick  ")
	
	if #name == 0 then
		announced:FireClient(executor, "Cannot find player without name.")
		return
	end
	
	local candidate = Player.getPlayerByName(name)
	
	if not candidate then
		announced:FireClient(executor, `Cannot find player '{name}.'`)
		return
	end
	
	startVotekick(executor, candidate)
end)

Players.PlayerAdded:Connect(function(player)
	local bannedUntil = bannedIds[player.UserId] or 0
	local now = tick()
	
	if now < bannedUntil then
		player:Kick(`You were votekicked. You can rejoin in {Time.formatTimeMinutes(bannedUntil - now)} minutes.`)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	if not votekickRunning or not voters[player] then
		return
	end
	
	voters[player] = nil
	voterCount -= 1

	local choice = playersVoted[player]
	
	if choice == true then
		yesVotes -= 1
	elseif choice == false then
		noVotes -= 1
	end
	
	playersVoted[player] = nil

	if yesVotes + noVotes >= voterCount then
		stopVotekick()
	end
end)