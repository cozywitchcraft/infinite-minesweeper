local Signal = require(script.Parent.Parent.Util.Signal)

local MAX_ITEMS = 4

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(options)
	local self = setmetatable({
		items = options.items,
		changed = Signal.new(),
	}, Dropdown)
	
	self.instance = script.Dropdown:Clone()
	self.instance.Label.Text = options.name
	self.instance.Parent = options.parent
	
	self.button = self.instance.Button
	self.itemsFrame = self.instance.Items
	
	if #self.items > MAX_ITEMS then
		self.itemsFrame.CanvasSize = UDim2.new(0, 0, #self.items, 0)
	end
	
	local size = math.min(#self.items, MAX_ITEMS)
	
	self.itemsFrame.Size = UDim2.new(0.5, 0, size, 0)
	
	self.button.Activated:Connect(function()
		self.itemsFrame.CanvasPosition = Vector2.new()
		self.itemsFrame.Visible = not self.itemsFrame.Visible
	end)
	
	for value, item in self.items do
		self:createButton(value - 1, item)
	end
	
	self:setValue(options.value)
	
	return self
end

function Dropdown:setValue(value)
	self.value = value
	
	self.button.Value.Text = self.items[value + 1]
end

function Dropdown:createButton(value, item)
	local button = Instance.new("TextButton")
	button.Name = "Item"
	button.BackgroundTransparency = 1
	button.Font = Enum.Font.Gotham
	button.Size = UDim2.new(1, 0, 1 / #self.items, 0)
	button.Text = item
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Parent = self.itemsFrame
	
	button.Activated:Connect(function()
		if self.value ~= value then
			self:setValue(value)
			self.changed:fire()
		end
		
		self.itemsFrame.Visible = false
	end)
end

return Dropdown