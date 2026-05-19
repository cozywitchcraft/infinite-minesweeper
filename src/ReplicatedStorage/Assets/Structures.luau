local ReplicatedStorage = game:GetService("ReplicatedStorage")

local structuresFolder = ReplicatedStorage._Assets.Structures

local Structures: { Model } = {
	structuresFolder.Ruins,
	structuresFolder.Tower,
	structuresFolder.Column,
	structuresFolder.BadgeAwarder,
	structuresFolder.RedTower,
	structuresFolder.Trampoline,
	structuresFolder.Tree,
	structuresFolder.YoungTree,
}

return Structures
