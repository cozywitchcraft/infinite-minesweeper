--!nonstrict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local TWEEN_INFO = TweenInfo.new(0.25)

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui

local buttonsFrame = script.Parent
local configButton = buttonsFrame.Config

local activeWindow

local function darken(color)
	return color:Lerp(Color3.new(), 0.2)
end

local function activateWindow(window)
	if activeWindow ~= window then
		if activeWindow then
			activeWindow.Enabled = false
		end

		activeWindow = window
	end

	window.Enabled = not window.Enabled
end

local function addButton(button)
	local window = playerGui:WaitForChild(button.Name)
	
	local icon = button:WaitForChild("Icon")
	local label = button:WaitForChild("Label")
	
	local mouseEnterTweens = {
		TweenService:Create(button, TWEEN_INFO, {
			BackgroundColor3 = darken(button.BackgroundColor3),
		}),
		
		TweenService:Create(icon, TWEEN_INFO, {
			ImageColor3 = darken(icon.ImageColor3),
		}),
		
		TweenService:Create(label, TWEEN_INFO, {
			TextTransparency = 0,
			TextStrokeTransparency = 0.6,
		}),
	}
	
	local mouseLeaveTweens = {
		TweenService:Create(button, TWEEN_INFO, {
			BackgroundColor3 = button.BackgroundColor3,
		}),
		
		TweenService:Create(icon, TWEEN_INFO, {
			ImageColor3 = icon.ImageColor3,
		}),
		
		TweenService:Create(label, TWEEN_INFO, {
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		}),
	}
	
	button.MouseEnter:Connect(function()
		for _, tween in mouseEnterTweens do
			tween:Play()
		end
	end)
	
	button.MouseLeave:Connect(function()
		for _, tween in mouseLeaveTweens do
			tween:Play()
		end
	end)
	
	button.Activated:Connect(function()
		activateWindow(window)
	end)
	
	window.Enabled = false
end

for _, instance in buttonsFrame:GetChildren() do
	if instance:IsA("GuiButton") then
		addButton(instance)
	end
end

localPlayer:GetAttributeChangedSignal("Admin"):Connect(function()
	configButton.Visible = localPlayer:GetAttribute("Admin")
end)

configButton.Visible = localPlayer:GetAttribute("Admin")