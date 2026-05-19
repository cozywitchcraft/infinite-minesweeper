local UserInputService = game:GetService("UserInputService")

local Signal = require(script.Parent.Parent.Util.Signal)

local Draggable = {}
Draggable.__index = Draggable

function Draggable.new(instance)
	local self = setmetatable({
		instance = instance,
		changed = Signal.new(),
		ended = Signal.new(),
	}, Draggable)
	
	instance.InputBegan:Connect(function(input)
		self:onInputBegan(input)
	end)
	
	return self
end

function Draggable:onInputBegan(input)
	if self.connections then
		return
	end

	local userInputType = input.UserInputType

	if userInputType ~= Enum.UserInputType.MouseButton1 and userInputType ~= Enum.UserInputType.Touch then 
		return
	end
	
	self.connections = {
		UserInputService.InputChanged:Connect(function(input)
			self:onInputChanged(input)
		end),

		UserInputService.InputEnded:Connect(function(input)
			self:onInputEnded(input)
		end),
	}
	
	self.changed:fire(input.Position)
end

function Draggable:onInputChanged(input)
	local userInputType = input.UserInputType

	if userInputType ~= Enum.UserInputType.MouseMovement and userInputType ~= Enum.UserInputType.Touch then 
		return
	end
	
	self.changed:fire(input.Position)
end

function Draggable:onInputEnded(input)
	local userInputType = input.UserInputType

	if userInputType ~= Enum.UserInputType.MouseButton1 and userInputType ~= Enum.UserInputType.Touch then 
		return
	end
	
	for _, connection in self.connections do
		connection:Disconnect()
	end

	self.connections = nil
	
	self.ended:fire(input.Position)
end

return Draggable