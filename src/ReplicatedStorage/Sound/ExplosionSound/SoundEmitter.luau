--!strict

local SoundService = game:GetService("SoundService")

export type SoundEmitter = {
	attachment: Attachment,
	sound: Sound,
}

local SoundEmitter = {}

function SoundEmitter.new(): SoundEmitter
	local attachment = Instance.new("Attachment")
	attachment.Name = "SoundEmitter"
	attachment.Parent = workspace.Terrain

	local sound = SoundService.Explosion:Clone()
	sound.Parent = attachment

	return {
		attachment = attachment,
		sound = sound,
	}
end

function SoundEmitter.use(soundEmitter: SoundEmitter, position: Vector3, pitch: number)
	soundEmitter.attachment.Position = position
	soundEmitter.sound.PlaybackSpeed = pitch

	soundEmitter.sound:Play()
end

return SoundEmitter
