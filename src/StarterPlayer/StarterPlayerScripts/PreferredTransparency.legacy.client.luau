local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")

local function onPreferredTransparencyChanged()
	for _, background in CollectionService:GetTagged("Background") do
		background.BackgroundTransparency = 0.4 * GuiService.PreferredTransparency
	end
end

CollectionService:GetInstanceAddedSignal("Background"):Connect(function(background)
	background.BackgroundTransparency = 0.4 * GuiService.PreferredTransparency
end)

GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(onPreferredTransparencyChanged)

onPreferredTransparencyChanged()