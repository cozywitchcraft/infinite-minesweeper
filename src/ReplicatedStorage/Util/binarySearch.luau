--!native

local function binarySearch(array: { number }, target: number): number
	local left = 1
	local right = #array

	while left < right do
		local mid = (left + right) // 2

		if array[mid] < target then
			left = mid + 1
		else
			right = mid
		end
	end

	return left
end

return binarySearch