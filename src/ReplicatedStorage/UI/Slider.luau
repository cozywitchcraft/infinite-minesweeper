local Draggable = require(script.Parent.Draggable)
local Field = require(script.Parent.Field)
local Signal = require(script.Parent.Parent.Util.Signal)
local Math = require(script.Parent.Parent.Util.Math)

local Slider = {}
Slider.__index = Slider

function Slider.new(options)
	local self = setmetatable({
		min = options.min,
		max = options.max,
		precision = options.precision,
		field = Field.new(options),
		changed = Signal.new(),
	}, Slider)
	
	self.instance = script.Slider:Clone()
	self.instance.Parent = options.parent
	
	self.fill = self.instance.Fill
	
	self.draggable = Draggable.new(self.instance)

	self.draggable.changed:connect(function(position)
		self:setValue(self:getValue(position.X))
	end)

	self.draggable.ended:connect(function(position)
		self:setValue(self:getValue(position.X))
		self.changed:fire()
	end)
	
	self.field.changed:connect(function()
		self:setValue(self.field.value)
		self.changed:fire()
	end)
	
	self:setValue(options.value)
	
	return self
end

function Slider:getValue(x)
	local position = self.instance.AbsolutePosition.X
	local size = self.instance.AbsoluteSize.X
	
	local min = 0.05 * size + position
	local max = 0.95 * size + position
	
	local rawTheta = Math.invLerp(min, max, x)
	local theta = math.clamp(rawTheta, 0, 1)
	
	local rawValue = Math.lerp(self.min, self.max, theta)
	
	return Math.round(rawValue, self.precision)
end

function Slider:setValue(value)
	self.value = value
	
	local size = Math.remap(self.min, self.max, 0.1, 1, value)
	self.fill.Size = UDim2.new(size, 0, 1, 0)
	
	self.field:setValue(value)
end

return Slider