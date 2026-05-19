local TweenService = game:GetService("TweenService")

local ACTIVATE_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
local FADE_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
local PULSE_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true)

local SubspaceMine = {}
SubspaceMine.__index = SubspaceMine

function SubspaceMine.new(mine)
	local self = setmetatable({
		mine = mine,
		
		mesh = script.Mesh:Clone(),
		
		calibrateSound = script.Calibrate:Clone(),
		explodeSound = script.Explode:Clone(),
		pulseSound = script.Pulse:Clone(),
		
		activateTween = TweenService:Create(mine, ACTIVATE_INFO, {
			Transparency = 1,
		}),
		
		fadeInTween = TweenService:Create(mine, FADE_INFO, {
			Transparency = 0,
		}),
		
		fadeOutTween = TweenService:Create(mine, FADE_INFO, {
			Transparency = 1,
		}),
		
		pulseTween = TweenService:Create(mine, PULSE_INFO, {
			Transparency = 0.5,
		}),
	}, SubspaceMine)
	
	self.mesh.Parent = mine
	
	self.calibrateSound.Parent = mine
	self.explodeSound.Parent = mine
	self.pulseSound.Parent = mine
	
	self.touchedConn = mine.Touched:Connect(function()
		self:onTouched()
	end)
	
	if mine:GetAttribute("Calibrated") then
		mine.Transparency = 1
	else
		self:calibrate()
	end
	
	return self
end

function SubspaceMine:calibrate()
	if self.calibrateSound then
		self.calibrateSound:Play()
	end
	
	self.calibrationConn = self.mine:GetAttributeChangedSignal("Calibrated"):Once(function()
		self.calibrationConn = self.calibrationConn:Disconnect()
		self:activate()
	end)
end

function SubspaceMine:activate()	
	self.activateTween.Completed:Once(function()
		self.mine.Transparency = 1
		
		if self.calibrateSound then
			self.calibrateSound:Stop()
		end
	end)
	
	self.activateTween:Play()
end

function SubspaceMine:pulse()
	if self.pulseSound then
		self.pulseSound:Play()
	end

	self.pulseTween:Play()
end

function SubspaceMine:explode()
	if self.explodeSound then
		self.explodeSound:Play()
	end

	self.fadeOutTween:Play()
end

function SubspaceMine:onTouched()
	if self.mine:GetAttribute("Calibrated") then
		self.touchedConn = self.touchedConn:Disconnect()
		self.fadeInTween:Play()
	end
end

function SubspaceMine:destroy()
	if self.touchedConn then
		self.touchedConn = self.touchedConn:Disconnect()
	end
	
	if self.calibrationConn then
		self.calibrationConn = self.calibrationConn:Disconnect()
	end
	
	self.mesh = self.mesh:Destroy()

	self.calibrateSound = self.calibrateSound:Destroy()
	self.explodeSound = self.explodeSound:Destroy()
	self.pulseSound = self.pulseSound:Destroy()
	
	self.activateTween = self.activateTween:Destroy()
	self.fadeInTween = self.fadeInTween:Destroy()
	self.fadeOutTween = self.fadeOutTween:Destroy()
	self.pulseTween = self.pulseTween:Destroy()
end

return SubspaceMine