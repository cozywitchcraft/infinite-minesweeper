local warningButton = script.Parent

local function showWarningButton()
	warningButton.Visible = not workspace:GetAttribute("StatsEnabled")
end

warningButton.Activated:Connect(function()
	warningButton.Visible = false
end)

workspace:GetAttributeChangedSignal("StatsEnabled"):Connect(showWarningButton)
showWarningButton()