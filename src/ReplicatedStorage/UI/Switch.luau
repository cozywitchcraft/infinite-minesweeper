local TweenService = game:GetService("TweenService")

local Signal = require(script.Parent.Parent.Util.Signal)

local TWEEN_INFO = TweenInfo.new(0.25)

local Switch = {}
Switch.__index = Switch

function Switch.new(options)
	local self = setmetatable({
		changed = Signal.new(),
	}, Switch)
	
	self.instance = script.Switch:Clone()
	self.instance.Label.Text = options.name
	self.instance.Parent = options.parent
	
	self.button = self.instance.Button
	
	self.onTween = TweenService:Create(self.button.Fill, TWEEN_INFO, {
		Size = UDim2.new(1, 0, 1, 0),
	})
	
	self.offTween = TweenService:Create(self.button.Fill, TWEEN_INFO, {
		Size = UDim2.new(0.5, 0, 1, 0)
	})
	
	self.button.Activated:Connect(function()
		self:setValue(not self.value)
		self.changed:fire()
	end)
	
	self:setValue(options.value)
	
	return self
end

function Switch:setValue(value)
	if self.value ~= value then
		self.value = value
		
		if value then
			self.onTween:Play()
		else
			self.offTween:Play()
		end
	end
end

return Switch