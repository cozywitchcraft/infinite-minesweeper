--!nonstrict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local Flags = require(ReplicatedStorage.Assets.Flags)
local ItemData = require(ReplicatedStorage.ItemData)
local RemoteClient = require(ReplicatedStorage.Remote.RemoteClient)

local AUTOSCROLL_DELAY = 8

local FOCUS = Vector3.new(0, 8.3, 0)
local OFFSET = Vector3.new(-7, 7, -7)

local GAMEPASS_IDS = { 77494914, 77494914 }

local coinsUpdated = RemoteClient.getRemoteEvent("CoinsUpdated")
local flagUpdated = RemoteClient.getRemoteEvent("FlagUpdated")
local inventoryLoaded = RemoteClient.getRemoteEvent("InventoryLoaded")

local requestItem = RemoteClient.getRemoteFunction("RequestItem")

local localPlayer = Players.LocalPlayer

local shopGui = script.Parent

local windowFrame = shopGui.Window

local flagsFrame = windowFrame.Flags
local showMoreButton = flagsFrame.ShowMore

local featuredFrame = flagsFrame.Featured
local featuredLayout = featuredFrame.Layout

local gamepassesFrame = windowFrame.Gamepasses
local previousButton = gamepassesFrame.Previous
local nextButton = gamepassesFrame.Next

local pagesFrame = gamepassesFrame.Pages
local pagesLayout = pagesFrame.Layout

local itemsFrame = windowFrame.Items
local itemsLayout = itemsFrame.Layout

local viewFrame = windowFrame.View
local viewIcon = viewFrame.Icon
local viewLabel = viewFrame.Label
local purchaseButton = viewFrame.Purchase

local backButton = windowFrame.Back
local closeButton = windowFrame.Close
local coinsButton = windowFrame.Coins
local inventoryButton = windowFrame.Inventory

local autoscrollEnabled = true

local onsaleItems = {}
local ownedItems = {}

local inventory = {}

local viewingInventory = false
local viewingItem = false

local currentItemId = 0
local equippedFlag = 0

local thread

local camera = Instance.new("Camera")
camera.CFrame = CFrame.new(FOCUS + OFFSET, FOCUS)

local function getPrice(price)
	return price > 0 and "$" .. price or "Free"
end

local function compareItems(a, b)
	if a.price == b.price then
		return a.id < b.id
	else
		return a.price < b.price
	end
end

local function createGamepass(gamepassId, parent)
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfoAsync(gamepassId, Enum.InfoType.GamePass)
	end)
	
	if not success then
		warn("Error while getting product info:", info)
		return
	end
	
	local gamepassFrame = script.Gamepass:Clone()
	gamepassFrame.Title.Text = info.Name
	gamepassFrame.Description.Text = info.Description
	gamepassFrame.Purchase.Text = "R$" .. info.PriceInRobux
	gamepassFrame.Icon.Image = "rbxassetid://" .. info.IconImageAssetId
	
	gamepassFrame.Purchase.Activated:Connect(function()
		MarketplaceService:PromptGamePassPurchase(localPlayer, gamepassId)
	end)
	
	gamepassFrame.Parent = parent
end

local function showDisplay()
	viewingInventory = false

	backButton.Visible = false
	
	itemsFrame.Visible = false
	viewFrame.Visible = false

	flagsFrame.Visible = true
	gamepassesFrame.Visible = true
	
	inventoryButton.Visible = true
	
	inventoryButton.Position = UDim2.new(0, 8, 0.9, -8)
	inventoryButton.Size = UDim2.new(1, -16, 0.1, 0)
	
	inventoryButton.Text = "Inventory"
end

local function setPurchaseButtonText()
	if equippedFlag == currentItemId then
		purchaseButton.Text = "Equipped"
	elseif inventory[currentItemId] then
		purchaseButton.Text = "Equip"
	else
		purchaseButton.Text = "Purchase"
	end
end

local function viewItem(item)
	viewingItem = true
	
	flagsFrame.Visible = false
	gamepassesFrame.Visible = false
	itemsFrame.Visible = false
	
	inventoryButton.Visible = false
	
	backButton.Visible = true
	viewFrame.Visible = true
	
	backButton.Size = UDim2.new(1, -16, 0.1, 0)
	
	currentItemId = item.id
	
	viewLabel.Text = `{item.name} | {getPrice(item.price)}`
	
	setPurchaseButtonText()
	
	viewIcon:ClearAllChildren()
	
	local flagPrefab = Flags[item.id + 1]

	if flagPrefab then
		local model = flagPrefab:Clone()
		model.Parent = viewIcon
		model:PivotTo(CFrame.identity)
	end
end

local function createItem(item, parent)
	local itemButton = script.Item:Clone()
	itemButton.Label.Text = item.name
	itemButton.Price.Text = getPrice(item.price)
	itemButton.Icon.CurrentCamera = camera
	
	local flagPrefab = Flags[item.id + 1]

	if flagPrefab then
		local model = flagPrefab:Clone()
		model.Parent = itemButton.Icon
		model:PivotTo(CFrame.identity)
	end
	
	itemButton.Activated:Connect(function()
		viewItem(item)
	end)
	
	itemButton.Parent = parent
end

local function showItems(items)
	viewingItem = false
	
	flagsFrame.Visible = false
	gamepassesFrame.Visible = false
	viewFrame.Visible = false
	
	itemsFrame.Visible = true
	
	backButton.Visible = true
	inventoryButton.Visible = true
	
	backButton.Size = UDim2.new(0.3, -12, 0.1, 0)
	
	inventoryButton.Position = UDim2.new(0.3, 4, 0.9, -8)
	inventoryButton.Size = UDim2.new(0.7, -12, 0.1, 0)
	
	if viewingInventory then
		inventoryButton.Text = "Onsale"
	else
		inventoryButton.Text = "Inventory"
	end
	
	-- Clear previous items
	for _, instance in itemsFrame:GetChildren() do
		if instance.ClassName == "TextButton" then
			instance:Destroy()
		end
	end
	
	for _, item in items do
		createItem(item, itemsFrame)
	end
end

coinsUpdated.OnClientEvent:Connect(function(coins)
	assert(typeof(coins) == "number", "coins must be a number")
	coinsButton.Text = "$" .. coins
end)

flagUpdated.OnClientEvent:Connect(function(flagId)
	equippedFlag = flagId
	setPurchaseButtonText()
end)
	
inventoryLoaded.OnClientEvent:Connect(function(newInventory)
	for _, itemId in newInventory do
		inventory[itemId] = true
		table.insert(ownedItems, ItemData[itemId + 1])
	end
end)

closeButton.Activated:Connect(function()
	shopGui.Enabled = false
end)

gamepassesFrame.InputBegan:Connect(function()
	autoscrollEnabled = false
end)

previousButton.Activated:Connect(function()
	autoscrollEnabled = false
	pagesLayout:Previous()
end)

nextButton.Activated:Connect(function()
	autoscrollEnabled = false
	pagesLayout:Next()
end)

purchaseButton.Activated:Connect(function()
	local success, itemId = requestItem:InvokeServer(currentItemId)
	
	if not success then
		purchaseButton.Text = itemId
		
		if thread then
			task.cancel(thread)
		end

		thread = task.delay(1, setPurchaseButtonText)
		
		return
	end
	
	if not inventory[itemId] then
		inventory[itemId] = true
		table.insert(ownedItems, ItemData[itemId])
	end
end)

backButton.Activated:Connect(function()
	if viewingItem then
		if viewingInventory then
			showItems(ownedItems)
		else
			showItems(onsaleItems)
		end
	else
		showDisplay()
	end
end)

inventoryButton.Activated:Connect(function()
	viewingInventory = not viewingInventory
	
	if viewingInventory then
		showItems(ownedItems)
	else
		showItems(onsaleItems)
	end
end)

showMoreButton.Activated:Connect(function()
	showItems(onsaleItems)
end)

featuredLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	featuredFrame.CanvasSize = UDim2.new(0, featuredLayout.AbsoluteContentSize.X, 0, 0)
end)

itemsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	itemsFrame.CanvasSize = UDim2.new(0, 0, 0, itemsLayout.AbsoluteContentSize.Y)
end)

viewIcon.CurrentCamera = camera

for _, item in ItemData do
	if not item.offsale then
		table.insert(onsaleItems, item)
	end
end

table.sort(onsaleItems, compareItems)

for _, item in onsaleItems do
	if item.featured then
		createItem(item, featuredFrame)
	end
end

for _, gamepassId in GAMEPASS_IDS do
	createGamepass(gamepassId, pagesFrame)
end

while autoscrollEnabled do
	task.wait(AUTOSCROLL_DELAY)
	
	if autoscrollEnabled then
		pagesLayout:Next()
	end
end