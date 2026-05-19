local Signal = require(script.Parent.Parent.Util.Signal)
local Math = require(script.Parent.Parent.Util.Math)

local Field = {}
Field.__index = Field

function Field.new(options)
	local self = setmetatable({
		min = options.min,
		max = options.max,
		precision = options.precision,
		changed = Signal.new(),
	}, Field)
	
	self.instance = script.Field:Clone()
	self.instance.Label.Text = options.name
	self.instance.Parent = options.parent
	
	self.input = self.instance.Input
	
	self.input.FocusLost:Connect(function()
		self:onFocusLost()
	end)
	
	self:setValue(options.value)
	
	return self
end

function Field:setValue(value)
	self.value = value
	
	self.input.Text = value
	self.input.PlaceholderText = value
end

function Field:onFocusLost()
	local value = tonumber(self.input.Text)
	
	if value then
		if self.min then
			value = math.max(value, self.min)
		end

		if self.max then
			value = math.min(value, self.max)
		end

		if self.precision then
			value = Math.round(value, self.precision)
		end
		
		if self.value ~= value then
			self:setValue(value)
			self.changed:fire()
		else
			self.input.Text = self.value
		end
	else
		self.input.Text = self.value
	end
end

return Field