local stringToIntId: { [string]: number } = {
	Red = 0,
	Ace = 1,
	Aro = 2,
	Bi = 3,
	Checkers = 4,
	Enby = 5,
	Gay = 6,
	Italy = 7,
	Lesbian = 8,
	Noob = 9,
	Pan = 10,
	Pride = 11,
	Short = 12,
	Tall = 13,
	Trans = 14,
	Wedge = 15,
}

local function convertFlagId(id: string): number
	return stringToIntId[id] or 0
end

return convertFlagId