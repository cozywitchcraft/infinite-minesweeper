local ReplicatedStorage = game:GetService("ReplicatedStorage")

local skyboxesFolder = ReplicatedStorage._Assets.Skyboxes

local Skyboxes: { Sky } = {
	skyboxesFolder.Black,
	skyboxesFolder.White,
	skyboxesFolder.Classic,
	skyboxesFolder.Sunset,
	skyboxesFolder.Nebula,
	skyboxesFolder.Day,
	skyboxesFolder.Night,
	skyboxesFolder.Green,
	skyboxesFolder.Mountains,
	skyboxesFolder.Crossroads,
	skyboxesFolder.SFOTH,
	skyboxesFolder.Jeff,
	skyboxesFolder.Nuke,
	skyboxesFolder.Galaxy,
	skyboxesFolder.Epic,
	skyboxesFolder.Tron,
}

return Skyboxes
