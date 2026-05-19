local function isEmpty(t: { [any]: any }): boolean
	for _ in t do
		return false
	end

	return true
end

return isEmpty