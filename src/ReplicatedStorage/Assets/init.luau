local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assetsFolder = ReplicatedStorage._Assets
local texturesFolder = assetsFolder.Textures

return {
	Flags = require(script.Flags),
	Skyboxes = require(script.Skyboxes),
	Structures = require(script.Structures),

	explosion = assetsFolder.Explosion,

	hexagonTile = assetsFolder.Hexagon,
	sphereTile = assetsFolder.Sphere,
	squareTile = assetsFolder.Square,

	numberTextures = {
		texturesFolder.Number1,
		texturesFolder.Number2,
		texturesFolder.Number3,
		texturesFolder.Number4,
		texturesFolder.Number5,
		texturesFolder.Number6,
		texturesFolder.Number7,
		texturesFolder.Number8,
	},

	crossTexture = texturesFolder.Cross,
	mineTexture = texturesFolder.Mine,
}
