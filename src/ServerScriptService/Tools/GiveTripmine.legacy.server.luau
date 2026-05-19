--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")

local removeTool = require(script.Parent.removeTool)

local GAMEPASS_ID = 77494914

local subspaceTripmine = ServerStorage.Tools.SubspaceTripmine

local configFolder = ReplicatedStorage.Config

local function destroyTripmines()
	for _, tripmine in CollectionService:GetTagged("SubspaceMine") do
		tripmine:Destroy()
	end
end

local function giveTripmine(player: Player)
	local starterGear = player:FindFirstChild("StarterGear")

	if not starterGear then
		return
	end

	-- Prevent player from receiving subspace tripmine more than once
	if starterGear:FindFirstChild("SubspaceTripmine") then
		return
	end
	
	subspaceTripmine:Clone().Parent = player.Backpack
	subspaceTripmine:Clone().Parent = starterGear
end

local function onPlayerAdded(player: Player)
	if not configFolder:GetAttribute("TripminesEnabled") then
		return
	end
	
	-- TODO: Change premium benefits
	if player.MembershipType == Enum.MembershipType.Premium then
		giveTripmine(player)
		return
	end
	
	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, GAMEPASS_ID)
	end)

	if not success then
		warn("Error while checking if user owns game pass:", result)
		return
	end

	if result then
		giveTripmine(player)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- TODO: Consolidate gamepass purchases
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, wasPurchased)
	assert(player:IsA("Player"), "Luau")
	
	if wasPurchased and gamepassId == GAMEPASS_ID then
		giveTripmine(player)
	end
end)

configFolder:GetAttributeChangedSignal("TripminesEnabled"):Connect(function()
	if configFolder:GetAttribute("TripminesEnabled") then
		for _, player in Players:GetPlayers() do
			onPlayerAdded(player)
		end
	else
		for _, player in Players:GetPlayers() do
			removeTool(player, "SubspaceTripmine")
		end

		destroyTripmines()
	end
end)

