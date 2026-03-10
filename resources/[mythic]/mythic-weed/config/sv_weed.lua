Config = {
	Lifetime = (60 * 60 * 24 * 3),
	FemSeedChance = 25,
	PackagePrice = 7500,
	BrickPrice = 4000,
	Fertilizer = {
		nitrogen = { time = 40, value = 2.0 },
		phosphorus = { time = 40, value = 0.75 },
		potassium = { time = 60, value = 0.4 },
	},
}

GroundTypes = {
	grass = { nitrogen = 0.6, phosphorus = 0.6, potassium = 0.6, water = 0.5, label = "Grass" },
	normal = { nitrogen = 0.3, phosphorus = 0.3, potassium = 0.3, water = 0.4, label = "Normal" },
	grocks = { nitrogen = 0.6, phosphorus = 0.6, potassium = 0.6, water = 0.5, label = "Grassy Rocks" },
	mgrass = { nitrogen = 0.6, phosphorus = 0.6, potassium = 0.6, water = 0.4, label = "Mountain Grass" },
	wet = { nitrogen = 0.9, phosphorus = 0.9, potassium = 0.9, water = 0.9, label = "Wetlands" },
	farm = { nitrogen = 0.9, phosphorus = 0.9, potassium = 0.9, water = 0.5, label = "Farmland" },
	sand = { nitrogen = 0.15, phosphorus = 0.15, potassium = 0.15, water = 0.3, label = "Sand" },
	unk1 = { nitrogen = 0.6, phosphorus = 0.6, potassium = 0.6, water = 0.6, label = "Unknown" },
	unk2 = { nitrogen = 0.3, phosphorus = 0.3, potassium = 0.3, water = 0.5, label = "Unknown" },
	unk3 = { nitrogen = 0.3, phosphorus = 0.3, potassium = 0.3, water = 0.5, label = "Unknown" },
}

-- Locations the Weed Dealer spawns on which day
Locations = {
	["0"] = {
		coords = vector3(928.000, -1487.463, 29.494),
		heading = 86.731,
	},
	["1"] = {
		coords = vector3(928.000, -1487.463, 29.494),
		heading = 86.731,
	},
	["2"] = {
		coords = vector3(497.536, -1959.389, 23.820),
		heading = 305.063,
	},
	["3"] = {
		coords = vector3(497.536, -1959.389, 23.820),
		heading = 305.063,
	},
	["4"] = {
		coords = vector3(-3107.755, 304.206, 4.071),
		heading = 11.543,
	},
	["5"] = {
		coords = vector3(-3107.755, 304.206, 4.071),
		heading = 11.543,
	},
	["6"] = {
		coords = vector3(928.000, -1487.463, 29.494),
		heading = 86.731,
	},
}
