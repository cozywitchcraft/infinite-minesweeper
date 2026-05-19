--!strict

export type Item = {
	name: string,
	id: number,
	price: number,
	offsale: boolean,
	featured: boolean,
}

local ItemData: { Item } = {
	{ name = "Red", id = 0, price = 0, offsale = false, featured = false },
	{ name = "Ace", id = 1, price = 0, offsale = false, featured = false },
	{ name = "Aro", id = 2, price = 0, offsale = false, featured = false },
	{ name = "Bi", id = 3, price = 0, offsale = false, featured = false },
	{ name = "Checkered", id = 4, price = 45, offsale = false, featured = false },
	{ name = "Enby", id = 5, price = 0, offsale = false, featured = false },
	{ name = "Gay", id = 6, price = 0, offsale = false, featured = false },
	{ name = "Italian", id = 7, price = 0, offsale = false, featured = false },
	{ name = "Lesbian", id = 8, price = 0, offsale = false, featured = false },
	{ name = "Noob", id = 9, price = 30, offsale = false, featured = false },
	{ name = "Pan", id = 10, price = 0, offsale = false, featured = false },
	{ name = "Pride", id = 11, price = 0, offsale = false, featured = false },
	{ name = "Short", id = 12, price = 25, offsale = false, featured = false },
	{ name = "Tall", id = 13, price = 75, offsale = false, featured = false },
	{ name = "Trans", id = 14, price = 0, offsale = false, featured = false },
	{ name = "Triangular", id = 15, price = 15, offsale = false, featured = false },
	{ name = "Genderfluid", id = 16, price = 0, offsale = false, featured = false },
	-- new stuff past this point
	{ name = "Curvy", id = 17, price = 125, offsale = false, featured = true },
	{ name = "Flipped", id = 18, price = 74, offsale = false, featured = true },
	{ name = "Stick", id = 19, price = 0, offsale = false, featured = false },
	{ name = "Different", id = 20, price = 0, offsale = false, featured = false },
	{ name = "Non-Linear", id = 21, price = 0, offsale = true, featured = false },
	{ name = "Lamp", id = 22, price = 50, offsale = false, featured = true },
	{ name = "Evil", id = 23, price = 666, offsale = false, featured = false },
	{ name = "Classic", id = 24, price = 98, offsale = false, featured = true },
	{ name = "Expensive", id = 25, price = 9999, offsale = false, featured = true },
	{ name = "Green", id = 26, price = 0, offsale = false, featured = false },
	{ name = "Source", id = 27, price = 333, offsale = false, featured = true },
	{ name = "ERROR", id = 28, price = 3333, offsale = false, featured = true },
	{ name = "Statue", id = 29, price = 150, offsale = false, featured = true },
	{ name = "Brittle", id = 30, price = 150, offsale = false, featured = false },
	{ name = "Burger", id = 31, price = 200, offsale = false, featured = false },
	{ name = "Nothing", id = 32, price = 200, offsale = true, featured = false },
	{ name = "Baby", id = 33, price = 2023, offsale = true, featured = false },
	{ name = "Too Tall", id = 34, price = 1125, offsale = false, featured = false },
	{ name = "Burger With Lettuce", id = 35, price = 250, offsale = false, featured = false },
	{ name = "Aroace", id = 36, price = 0, offsale = false, featured = false },
	{ name = "Bob", id = 37, price = 2024, offsale = true, featured = false },
}

return ItemData