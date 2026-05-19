local LocalizationService = game:GetService("LocalizationService")

local localizationTable = Instance.new("LocalizationTable")
localizationTable:SetEntries({
	{
		Key = "translatedNumber",
		Source = "{1:num}",
		Values = { [LocalizationService.RobloxLocaleId] = "{1:num}" },
	},
})

local function localizeInt(number: number): string
	local translator = localizationTable:GetTranslator(LocalizationService.RobloxLocaleId)
	assert(translator:IsA("Translator"), "Luau")
	
	return string.sub(translator:FormatByKey("translatedNumber", { number }), 1, -4)
end

return localizeInt