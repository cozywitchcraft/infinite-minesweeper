local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = require(ReplicatedStorage.Assets)

ContentProvider:PreloadAsync({
	Assets.crossTexture,
	Assets.explosion.Chunk,
	Assets.explosion.Core,
	Assets.explosion.Implosion,
	Assets.hexagonTile,
	Assets.mineTexture,
	Assets.sphereTile,
	Assets.squareTile,
	unpack(Assets.numberTextures),
})
