local Time = {}

function Time.formatTimeMinutes(seconds: number): string
	return string.format("%02d:%02d", seconds // 60, seconds % 60)
end

function Time.formatTimeHours(seconds: number): string
	return string.format("%02d:%02d:%02d", seconds // 3600, seconds // 60 % 60, seconds % 60)
end

return Time
