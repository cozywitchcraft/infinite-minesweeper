--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Settings = require(ReplicatedStorage.Settings.Settings)

local alertGroup = SoundService.AlertGroup
local characterGroup = SoundService.CharacterGroup
local explosionGroup = SoundService.ExplosionGroup
local flagGroup = SoundService.FlagGroup

local connections: { [Model]: RBXScriptConnection } = {}

local function bindVolumeSetting(setting: Settings.Setting<number>, soundGroup: SoundGroup)
	setting.changed:connect(function()
		soundGroup.Volume = 0.01 * setting.value
	end)

	soundGroup.Volume = 0.01 * setting.value
end

local function onDescendantAdded(child: Instance)
	if child:IsA("Sound") then
		child.SoundGroup = characterGroup
	end
end

local function onCharacterAdded(character: Model)
	connections[character] = character.DescendantAdded:Connect(onDescendantAdded)

	for _, instance in character:GetDescendants() do
		onDescendantAdded(instance)
	end
end

local function onCharacterRemoving(character: Model)
	if connections[character] then
		connections[character] = connections[character]:Disconnect()
	end
end

local function onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(onCharacterAdded)
	player.CharacterRemoving:Connect(onCharacterRemoving)

	if player.Character then
		onCharacterAdded(player.Character)
	end
end

bindVolumeSetting(Settings.alertVolume, alertGroup)
bindVolumeSetting(Settings.characterVolume, characterGroup)
bindVolumeSetting(Settings.explosionVolume, explosionGroup)
bindVolumeSetting(Settings.flagVolume, flagGroup)

Players.PlayerAdded:Connect(onPlayerAdded)

for _, player in Players:GetPlayers() do
	onPlayerAdded(player)
end
