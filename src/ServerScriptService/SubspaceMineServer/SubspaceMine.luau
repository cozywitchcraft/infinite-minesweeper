--!nonstrict
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Character = require(ReplicatedStorage.Util.Character)

local CALIBRATION_TIME = 2
local MAX_LIFETIME = 120

local SubspaceMine = {
	pulsed = {},
}

SubspaceMine.__index = SubspaceMine

function SubspaceMine.new(mine)
	local self = setmetatable({
		mine = mine,
		lifetime = 0,
		calibrated = false,
	}, SubspaceMine)

	self.touchedConn = mine.Touched:Connect(function(hit)
		self:onTouched(hit)
	end)

	return self
end

function SubspaceMine:activate()
	self.calibrated = true
	self.mine:SetAttribute("Calibrated", true)
end

function SubspaceMine:explode()
	self.touchedConn = self.touchedConn:Disconnect()

	task.wait(0.25)

	local explosion = Instance.new("Explosion")
	explosion.BlastRadius = 16
	explosion.BlastPressure = 1e6
	explosion.Position = self.mine.Position
	explosion.Parent = self.mine
	
	CollectionService:AddTag(explosion, "Explosion")
	CollectionService:AddTag(explosion, "SubspaceExplosion")

	explosion.Hit:Connect(Character.onExplosionHit)

	task.wait(4.25)
	
	self.mine:Destroy()
end

function SubspaceMine:onTouched(hit)
	if not self.calibrated then
		self.lifetime = 0
	else
		self:explode()
	end
end

function SubspaceMine:update(deltaTime)
	if not self.calibrated then
		if self.mine.Velocity.Magnitude > 0.05 then
			self.lifetime = 0
		end

		if self.lifetime > CALIBRATION_TIME then
			self:activate()
		end
	else
		if math.random(1, 20) == 2 then -- why?
			table.insert(SubspaceMine.pulsed, self.mine)
		end

		if self.lifetime > MAX_LIFETIME then
			self.mine:Destroy()
		end
	end

	self.lifetime += deltaTime
end

function SubspaceMine:destroy()
	if self.touchedConn then
		self.touchedConn = self.touchedConn:Disconnect()
	end
end

return SubspaceMine