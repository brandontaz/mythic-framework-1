function RegisterItems()
	Inventory.Items:RegisterUse("weedseed_male", "Weed", function(source, item)
		if GlobalState[string.format("%s:House", source)] == nil then
			local char = Fetch:Source(source):GetData("Character")
			local veh = GetVehiclePedIsIn(GetPlayerPed(source))
			if veh == 0 then
				Callbacks:ClientCallback(source, "Weed:PlantingAnim", {}, function(data)
					if data.error == nil then
						Inventory.Items:RemoveList(char:GetData("SID"), 1, { { name = "weedseed_male", count = 1 } })
						local plant = Weed.Planting:Create(
							true,
							{ x = data.coords.x, y = data.coords.y, z = data.coords.z },
							data.material
						)

						_plants[plant._id] = {
							plant = plant,
						}

						Weed.Planting:Set(plant._id, false)
					else
						if data.error == 2 then
							Execute:Client(source, "Notification", "Error", "The soil quality is insufficient for planting.")
						elseif data.error == 3 then
							Execute:Client(source, "Notification", "Error", "You are too close to another plant.")
						end
					end
				end)
			else
				Execute:Client(source, "Notification", "Error", "You cannot plant while inside a vehicle.")
			end
		else
			Execute:Client(source, "Notification", "Error", "This plant requires natural sunlight to grow.")
		end
	end)

	Inventory.Items:RegisterUse("weedseed_female", "Weed", function(source, item)
		if GlobalState[string.format("%s:House", source)] == nil then
			local char = Fetch:Source(source):GetData("Character")
			local veh = GetVehiclePedIsIn(GetPlayerPed(source))
			if veh == 0 then
				Callbacks:ClientCallback(source, "Weed:PlantingAnim", {}, function(data)
					if data.error == nil then
						Inventory.Items:RemoveList(char:GetData("SID"), 1, { { name = "weedseed_female", count = 1 } })
						local plant = Weed.Planting:Create(
							false,
							{ x = data.coords.x, y = data.coords.y, z = data.coords.z },
							data.material
						)

						_plants[plant._id] = {
							plant = plant,
						}

						Weed.Planting:Set(plant._id, false)
					else
						if data.error == 2 then
							Execute:Client(source, "Notification", "Error", "The soil quality is insufficient for planting.")
						elseif data.error == 3 then
							Execute:Client(source, "Notification", "Error", "You are too close to another plant.")
						end
					end
				end)
			else
				Execute:Client(source, "Notification", "Error", "You cannot plant while inside a vehicle.")
			end
		else
			Execute:Client(source, "Notification", "Error", "This plant requires natural sunlight to grow.")
		end
	end)

	Inventory.Items:RegisterUse("rolling_paper", "Weed", function(source, item)
		local char = Fetch:Source(source):GetData("Character")
		if Inventory.Items:Has(char:GetData("SID"), 1, "weed_bud", 1) then
			Callbacks:ClientCallback(source, "Weed:RollingAnim", {}, function(success)
				if success then
					Inventory.Items:RemoveList(
						char:GetData("SID"),
						1,
						{ { name = "rolling_paper", count = 1 }, { name = "weed_bud", count = 1 } }
					)
					Inventory:AddItem(char:GetData("SID"), "weed_joint", 2, {}, 1)
				end
			end)
		else
			Execute:Client(source, "Notification", "Error", "You do not have the required cannabis bud.")
		end
	end)

	Inventory.Items:RegisterUse("weed_joint", "Weed", function(source, item)
		local char = Fetch:Source(source):GetData("Character")
		Callbacks:ClientCallback(source, "Weed:SmokingAnim", {}, function(success, count)
			Inventory.Items:RemoveList(char:GetData("SID"), 1, { { name = "weed_joint", count = 1 } })

			local stressTicks = {}
			for i = 0, count do
				table.insert(stressTicks, "3")
			end

			Player(source).state.stressTicks = stressTicks
		end)
	end)

	Inventory.Items:RegisterUse("weed_brick", "Weed", function(source, item)
		local char = Fetch:Source(source):GetData("Character")
		if Inventory.Items:Has(char:GetData("SID"), 1, "weed_brick", 1) then
			local veh = GetVehiclePedIsIn(GetPlayerPed(source))
			if veh == 0 then
				Callbacks:ClientCallback(source, "Weed:MakingBrick", {
					label = "Unpacking Cannabis Brick",
					time = 10,
				}, function(success)
					if success then
						Inventory.Items:RemoveList(char:GetData("SID"), 1, { { name = "weed_brick", count = 1 } })
						Inventory:AddItem(char:GetData("SID"), "weed_bud", 200, {}, 1)
					end
				end)
			else
				Execute:Client(source, "Notification", "Error", "You must exit the vehicle before packing the cannabis brick.")
			end
		else
			Execute:Client(source, "Notification", "Error", "You do not have the required cannabis brick to pack.")
		end
	end)

	Inventory.Items:RegisterUse("weed_baggy", "Weed", function(source, item)
		local char = Fetch:Source(source):GetData("Character")
		if Inventory.Items:Has(char:GetData("SID"), 1, "weed_baggy", 1) then
			Callbacks:ClientCallback(source, "Weed:MakingBrick", {
				label = "Separating Cannabis Bud",
				time = 3,
			}, function(success)
				if success then
					Inventory.Items:RemoveList(char:GetData("SID"), 1, { { name = "weed_baggy", count = 1 } })
					Inventory:AddItem(char:GetData("SID"), "weed_bud", 2, {}, 1)
				end
			end)
		else
			Execute:Client(source, "Notification", "Error", "You do not have the required quantity of cannabis bud.")
		end
	end)
end
