--!strict
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local lastTouchInput: InputObject?

local function getMouseLocation(): Vector2
	if lastTouchInput then
		local position = lastTouchInput.Position
		return Vector2.new(position.X, position.Y) + GuiService:GetGuiInset()
	else
		return UserInputService:GetMouseLocation()
	end
end

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		lastTouchInput = input
	else
		lastTouchInput = nil
	end
end)

return getMouseLocation