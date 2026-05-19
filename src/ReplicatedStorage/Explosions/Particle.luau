--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = require(ReplicatedStorage.Assets)

export type Particle = {
	attachment: Attachment,
	chunk: ParticleEmitter,
	core: ParticleEmitter,
	implosion: ParticleEmitter,
}

local Particle = {}

function Particle.new(): Particle
	local attachment = Assets.explosion:Clone()
	attachment.Parent = workspace.Terrain

	return {
		attachment = attachment,
		chunk = attachment.Chunk,
		core = attachment.Core,
		implosion = attachment.Implosion,
	}
end

function Particle.use(particle: Particle, position: Vector3, count: number)
	particle.attachment.Position = position

	particle.chunk:Emit(count)
	particle.core:Emit(count)
	particle.implosion:Emit(count)
end

return Particle
