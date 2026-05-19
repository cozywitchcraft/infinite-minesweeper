--!strict

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = require(ReplicatedStorage.Settings.Settings)
local Skyboxes = require(ReplicatedStorage.Assets.Skyboxes)

local sky: Sky

local function changeSky()
	if sky then
		sky:Destroy()
	end

	local newSky = Skyboxes[Settings.skybox.value + 1]

	if newSky then
		sky = newSky:Clone()
		sky.Parent = Lighting
	end
end

Settings.skybox.changed:connect(changeSky)

changeSky()
