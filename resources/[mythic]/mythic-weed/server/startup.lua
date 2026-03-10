local _started

local function EnsureWeedPlantsTable(cb)
	exports.oxmysql:execute([[
		CREATE TABLE IF NOT EXISTS `weed_plants` (
			`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
			`data` LONGTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
			PRIMARY KEY (`id`) USING BTREE
		)
		COLLATE='utf8mb4_general_ci'
		ENGINE=InnoDB;
	]], {}, function()
		if cb then cb() end
	end)
end

function Startup()
	if _started then return end
	_started = true

	EnsureWeedPlantsTable(function()
		exports.oxmysql:query("SELECT id, data FROM weed_plants", {}, function(results)
			local count = 0

			if results and #results > 0 then
				for _, row in ipairs(results) do
					local ok, plant = pcall(json.decode, row.data or "{}")
					if ok and plant and plant.planted then
						if os.time() - plant.planted <= Config.Lifetime then
							plant._id = row.id

							_plants[plant._id] = {
								plant = plant,
								stage = getStageByPct(plant.growth or 0),
							}

							count = count + 1
						end
					end
				end
			end

			Logger:Trace("Weed", string.format("Loaded ^2%s^7 Weed Plants", count), { console = true })
		end)
	end)

	Reputation:Create("weed", "Weed", {
		{ label = "Rank 1", value = 3000 },
		{ label = "Rank 2", value = 6000 },
		{ label = "Rank 3", value = 12000 },
		{ label = "Rank 4", value = 21000 },
		{ label = "Rank 5", value = 50000 },
	}, true)
end
