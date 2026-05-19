local Draggable = require(script.Parent.Draggable)
local Signal = require(script.Parent.Parent.Util.Signal)
local Math = require(script.Parent.Parent.Util.Math)

local Color = {}
Color.__index = Color

function Color.new(options)
	local self = setmetatable({
		changed = Signal.new(),
	}, Color)

	self.instance = script.Color:Clone()
	self.instance.Label.Text = options.name
	self.instance.Parent = options.parent
	
	self.button = self.instance.Button
	self.input = self.instance.Input
	
	self.pickerFrame = self.instance.Picker
	
	self.rgbInput = self.pickerFrame.RGBInput
	self.hsvInput = self.pickerFrame.HSVInput
	
	self.hueSatButton = self.pickerFrame.HueSat
	self.valButton = self.pickerFrame.Val
	
	self.hueSatDraggable = Draggable.new(self.hueSatButton)
	self.valDraggable = Draggable.new(self.valButton)
	
	self.button.Activated:Connect(function()
		self.pickerFrame.Visible = not self.pickerFrame.Visible

		if self.pickerFrame.Visible then
			self.instance.Size = UDim2.new(1, -10, 0.5, -5)
		else
			self.instance.Size = UDim2.new(1, -10, 0.1, -1)
		end
	end)
	
	self.input.FocusLost:Connect(function()
		self:onFocusLost()
	end)
	
	self.rgbInput.FocusLost:Connect(function()
		self:onFocusLostRGB()
	end)
	
	self.hsvInput.FocusLost:Connect(function()
		self:onFocusLostHSV()
	end)
	
	self.hueSatDraggable.changed:connect(function(position)
		self:onHueSatChanged(position.X, position.Y)
	end)
	
	self.hueSatDraggable.ended:connect(function(position)
		self:onHueSatChanged(position.X, position.Y)
		self.changed:fire()
	end)
	
	self.valDraggable.changed:connect(function(position)
		self:onValChanged(position.X)
	end)
	
	self.valDraggable.ended:connect(function(position)
		self:onValChanged(position.X)
		self.changed:fire()
	end)

	self:setValue(options.value)

	return self
end

function Color:update()
	self.button.BackgroundColor3 = self.value

	local text = "#" .. self.value:ToHex()

	self.input.Text = text
	self.input.PlaceholderText = text

	local rgb = string.format("%d, %d, %d",
		255 * self.value.R, 255 * self.value.G, 255 * self.value.B)

	self.rgbInput.Text = rgb
	self.rgbInput.PlaceholderText = rgb

	local hsv = string.format("%d°, %d%%, %d%%",
		360 * self.hue, 100 * self.sat, 100 * self.val)

	self.hsvInput.Text = hsv
	self.hsvInput.PlaceholderText = hsv
	
	self.hueSatButton.Cursor.Position = UDim2.new(self.hue, 0, 1 - self.sat, 0)
	self.valButton.Cursor.Position = UDim2.new(self.val, 0, 1, 0)
end

function Color:setValue(value)
	self.value = value
	self.hue, self.sat, self.val = value:ToHSV()
	
	self:update()
end

function Color:onHSVChanged()
	self.value = Color3.fromHSV(self.hue, self.sat, self.val)
	self:update()
end

function Color:onHueSatChanged(x, y)
	local min = self.hueSatButton.AbsolutePosition
	local max = min + self.hueSatButton.AbsoluteSize

	local rawHue = Math.invLerp(min.X, max.X, x)
	local rawSat = Math.invLerp(max.Y, min.Y, y)

	self.hue = Math.round(math.clamp(rawHue, 0, 1), 360)
	self.sat = Math.round(math.clamp(rawSat, 0, 1), 100)

	self:onHSVChanged()
end

function Color:onValChanged(x)
	local min = self.valButton.AbsolutePosition.X
	local max = min + self.valButton.AbsoluteSize.X

	local rawVal = Math.invLerp(min, max, x)

	self.val = Math.round(math.clamp(rawVal, 0, 1), 100)

	self:onHSVChanged()
end

function Color:onFocusLost()
	local success, value = pcall(function()
		return Color3.fromHex(self.input.Text)
	end)

	if success and self.value ~= value then
		self:setValue(value)
		self.changed:fire()
	else
		self.input.Text = self.input.PlaceholderText
	end
end

function Color:onFocusLostRGB()
	local args = {}
	
	for str in self.rgbInput.Text:gmatch("%d+") do
		local number = tonumber(str)
		
		if number then
			table.insert(args, math.clamp(number, 0, 255))
		end
	end
	
	if #args == 3 then
		local value = Color3.fromRGB(unpack(args))
		
		if self.value ~= value then
			self:setValue(value)
			self.changed:fire()
		else
			self.rgbInput.Text = self.rgbInput.PlaceholderText
		end
	else
		self.rgbInput.Text = self.rgbInput.PlaceholderText
	end
end

function Color:onFocusLostHSV()
	local args = {}
	local max = 360

	for str in self.hsvInput.Text:gmatch("%d+") do
		local number = tonumber(str)

		if number then
			table.insert(args, math.clamp(number / max, 0, 1))
			max = 100
		end
	end

	if #args == 3 then
		local value = Color3.fromHSV(unpack(args))

		if self.value ~= value then
			self:setValue(value)
			self.changed:fire()
		else
			self.hsvInput.Text = self.hsvInput.PlaceholderText
		end
	else
		self.hsvInput.Text = self.hsvInput.PlaceholderText
	end
end

return Color