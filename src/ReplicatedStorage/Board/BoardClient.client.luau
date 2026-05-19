--!strict

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Attribute = require(ReplicatedStorage.Util.Attribute)
local BoardConfig = require(script.Parent.BoardConfig)
local BoardModel = require(script.Parent.BoardModel)
local BoardTypes = require(script.Parent.BoardTypes)
local Character = require(ReplicatedStorage.Util.Character)
local ClientConfig = require(script.Parent.ClientConfig)
local Materials = require(ReplicatedStorage.Materials)
local RemoteClient = require(ReplicatedStorage.Remote.RemoteClient)
local Settings = require(ReplicatedStorage.Settings.Settings)
local TileFlag = require(script.Parent.Enum.TileFlag)
local TileQueue = require(script.Parent.TileQueue)
local getMouseLocation = require(ReplicatedStorage.Util.getMouseLocation)

-- TODO: Toggle casting method
local CAST_POINTS = {
	Vector3.zero,
	--Vector3.new(-1, 0, -1),
	--Vector3.new(0, 0, -1),
	--Vector3.new(1, 0, -1),
	--Vector3.new(-1, 0, 1),
	--Vector3.new(0, 0, 1),
	--Vector3.new(1, 0, 1),
}

local MAX_RUNTIME = 1 / 240

local boardLoaded = RemoteClient.getRemoteEvent("BoardLoaded")
local boardUpdated = RemoteClient.getRemoteEvent("BoardUpdated")
local flagUpdated = RemoteClient.getRemoteEvent("FlagUpdated")
local tileChorded = RemoteClient.getRemoteEvent("TileChorded")
local tileFlagged = RemoteClient.getRemoteEvent("TileFlagged")
local tileOpened = RemoteClient.getRemoteEvent("TileOpened")

local chordingEnabled = Settings.chordingEnabled
local ignoreFlags = Settings.ignoreFlags
local fieldColorLight = Settings.fieldColorLight
local fieldColorDark = Settings.fieldColorDark
local groundColorLight = Settings.groundColorLight
local groundColorDark = Settings.groundColorDark
local fieldMaterial = Settings.fieldMaterial
local groundMaterial = Settings.groundMaterial
local highlightColor = Settings.highlightColor
local highlightEnabled = Settings.highlightEnabled
local highlightSpeed = Settings.highlightSpeed

local localPlayer = assert(Players.LocalPlayer, "LocalPlayer is nil")
local camera = assert(workspace.CurrentCamera, "CurrentCamera is nil")

local clickableFolder = Instance.new("Folder")
clickableFolder.Name = "Clickable"
clickableFolder.Parent = workspace

local clickDetector = Instance.new("ClickDetector")
clickDetector.CursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
clickDetector.Parent = clickableFolder

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.RespectCanCollide = ignoreFlags.value

local highlight = Instance.new("Highlight")
highlight.OutlineColor = highlightColor.value
highlight.FillColor = highlightColor.value
highlight.OutlineTransparency = 0
highlight.FillTransparency = 0.6
highlight.DepthMode = Enum.HighlightDepthMode.Occluded
highlight.Parent = camera

local boardModel = BoardModel.new({
	tileShape = ClientConfig.config.tileShape,
	tileSize = ClientConfig.config.tileSize,
	terrainDensity = ClientConfig.config.terrainDensity,
	terrainIntensity = ClientConfig.config.terrainIntensity,
	terrainSeed = ClientConfig.config.terrainSeed,
	slippery = ClientConfig.config.slippery,
	spheres = ClientConfig.config.spheres,
	fieldColorLight = fieldColorLight.value,
	fieldColorDark = fieldColorDark.value,
	groundColorLight = groundColorLight.value,
	groundColorDark = groundColorDark.value,
	fieldMaterial = Materials[fieldMaterial.value + 1],
	groundMaterial = Materials[groundMaterial.value + 1],
	parent = clickableFolder,
})

local tileQueue = TileQueue.new()

local boardDisabled = true
local equippedFlag = 0

local humanoidConnection: RBXScriptConnection
local tileUpdateConnection: RBXScriptConnection

local function isHumanoidConnected()
	return humanoidConnection and humanoidConnection.Connected
end

local function isMouseDisabled()
	return boardDisabled or ClientConfig.config.flagless or not isHumanoidConnected()
end

local function shouldHighlight(tile: BoardTypes.TileModel): boolean
	return chordingEnabled.value and bit32.rshift(tile.state, 3) > 0 or not bit32.btest(tile.state, TileFlag.OPEN)
end

local function getTarget(mouseLocation: Vector2): BoardTypes.TileModel?
	if isMouseDisabled() then
		return nil
	end

	local ray = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local result = workspace:Raycast(ray.Origin, 1024 * ray.Direction, params)

	if result and localPlayer:DistanceFromCharacter(result.Position) <= ClientConfig.config.maxDistance then
		return BoardModel.getTileFromPart(boardModel, result.Instance :: BasePart)
	else
		return nil
	end
end

local function findFloorTiles(humanoid: Humanoid)
	if boardDisabled or humanoid:GetState() ~= Enum.HumanoidStateType.Running then
		return
	end

	local rootPart = humanoid.RootPart

	if not rootPart then
		return
	end

	local cframe, halfSize = rootPart.CFrame, 0.4 * rootPart.Size
	local hipHeight = humanoid.HipHeight + 0.5 * rootPart.Size.Y

	-- Ignore leg check
	if humanoid.RigType == Enum.HumanoidRigType.R6 then
		hipHeight += 2
	end

	for _, point in CAST_POINTS do
		local position = cframe:PointToWorldSpace(halfSize * point)
		local tile = BoardModel.getFloorTile(boardModel, position, hipHeight)

		if tile and tile.state == 0 then
			tile.state = -1 -- Toggle debounce
			tileOpened:FireServer(tile.position)
		end
	end
end

local function updateHighlight()
	if not highlightEnabled.value then
		return
	end

	local h, s, v = highlightColor.value:ToHSV()
	v += 0.1 * (1 + math.sin(highlightSpeed.value * tick()))

	highlight.FillColor = Color3.fromHSV(h, s, v)
end

local function updateTiles()
	if tileQueue.length == 0 then
		return
	end

	local budget = os.clock() + MAX_RUNTIME

	-- TODO: Render distance
	while tileQueue.cursor < tileQueue.length and os.clock() < budget do
		BoardModel.updateTile(boardModel, TileQueue.nextTile(tileQueue))
	end

	if tileQueue.cursor >= tileQueue.length then
		TileQueue.clear(tileQueue)
	end
end

local function onMouseHoverLeave()
	UserInputService.MouseIcon = ""
	highlight.Adornee = nil
end

local function onMouseHoverEnter()
	local target = getTarget(UserInputService:GetMouseLocation())

	if target and shouldHighlight(target) then
		UserInputService.MouseIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowCursor.png"
		highlight.Adornee = target.part
	else
		onMouseHoverLeave()
	end
end

local function onMouseClick()
	local target = getTarget(getMouseLocation())

	if not target then
		return
	end

	if chordingEnabled.value and bit32.rshift(target.state, 3) > 0 then
		tileChorded:FireServer(target.position)
	elseif not bit32.btest(target.state, TileFlag.OPEN) then
		BoardModel.updateTile(boardModel, target.position, bit32.bxor(target.state, TileFlag.FLAG), equippedFlag)
		tileFlagged:FireServer(target.position)
	end
end

local function onHumanoidDied()
	if isHumanoidConnected() then
		humanoidConnection:Disconnect()
	end
	
	onMouseHoverLeave()
end

local function onHumanoidAdded(humanoid: Humanoid)
	humanoidConnection = RunService.PostSimulation:Connect(function()
		findFloorTiles(humanoid)
	end)

	humanoid.Died:Once(onHumanoidDied)
end

local function onCharacterAdded(character: Model)
	if not tileUpdateConnection then
		tileUpdateConnection = RunService.PostSimulation:Connect(updateTiles)
	end
	
	params.FilterDescendantsInstances = { character }
	Character.bindHumanoid(character, onHumanoidAdded)
end

local function onBoardLoaded(tileBuffer: unknown)
	assert(typeof(tileBuffer) == "buffer", "tileBuffer must be a buffer")
	
	TileQueue.clear(tileQueue)
	BoardModel.clear(boardModel)

	local config, offset = BoardConfig.deserialize(tileBuffer)
	BoardModel.setConfig(boardModel, config)
	ClientConfig.setConfig(config)

	clickDetector.MaxActivationDistance = config.maxDistance

	TileQueue.add(tileQueue, tileBuffer, offset)
end

local function onBoardUpdated(tileBuffer: unknown)
	assert(typeof(tileBuffer) == "buffer", "tileBuffer must be a buffer")

	TileQueue.add(tileQueue, tileBuffer)
end

local function onFlagUpdated(flagId: number)
	assert(typeof(flagId) == "number", "flagId must be a number")

	equippedFlag = flagId
end

local function updateBoardDisabled()
	local roundStart = Attribute.getNumber(workspace, "RoundStart")
	local roundEnd = Attribute.getNumber(workspace, "RoundEnd")
	
	boardDisabled = roundStart <= roundEnd
	
	if boardDisabled then
		onMouseHoverLeave()
	end
end

highlightEnabled.changed:connect(function()
	highlight.Enabled = highlightEnabled.value
end)

ignoreFlags.changed:connect(function()
	params.RespectCanCollide = ignoreFlags.value
end)

fieldColorDark.changed:connect(function()
	BoardModel.setFieldColorDark(boardModel, fieldColorDark.value)
end)

fieldColorLight.changed:connect(function()
	BoardModel.setFieldColorLight(boardModel, fieldColorLight.value)
end)

groundColorDark.changed:connect(function()
	BoardModel.setGroundColorDark(boardModel, groundColorDark.value)
end)

groundColorLight.changed:connect(function()
	BoardModel.setGroundColorLight(boardModel, groundColorLight.value)
end)

fieldMaterial.changed:connect(function()
	BoardModel.setFieldMaterial(boardModel, Materials[fieldMaterial.value + 1])
end)

groundMaterial.changed:connect(function()
	BoardModel.setGroundMaterial(boardModel, Materials[groundMaterial.value + 1])
end)

clickDetector.MouseClick:Connect(onMouseClick)

clickDetector.MouseHoverEnter:Connect(onMouseHoverEnter)
clickDetector.MouseHoverLeave:Connect(onMouseHoverLeave)

localPlayer.CharacterAdded:Connect(onCharacterAdded)
localPlayer.CharacterRemoving:Connect(onHumanoidDied)

boardLoaded.OnClientEvent:Connect(onBoardLoaded)
boardUpdated.OnClientEvent:Connect(onBoardUpdated)
flagUpdated.OnClientEvent:Connect(onFlagUpdated)

ContextActionService.LocalToolEquipped:Connect(onMouseHoverLeave)
ContextActionService.LocalToolUnequipped:Connect(onMouseHoverEnter)

RunService.PostSimulation:Connect(updateHighlight)

workspace:GetAttributeChangedSignal("RoundStart"):Connect(updateBoardDisabled)
workspace:GetAttributeChangedSignal("RoundEnd"):Connect(updateBoardDisabled)

updateBoardDisabled()

if localPlayer.Character then
	task.defer(onCharacterAdded, localPlayer.Character)
end
