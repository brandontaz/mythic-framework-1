local _run = false

AddEventHandler("Core:Server:ForceSave", function()
	SaveAllPlants()
end)

function SaveAllPlants()
    local docs = {}
    for k, v in pairs(_plants) do
        if v and v.plant then
            table.insert(docs, v.plant)
        end
    end

    if #docs > 0 then
		Logger:Info("Weed", string.format("Saving ^2%s^7 Plants", #docs))
        for _, plant in ipairs(docs) do
            if plant._id then
                exports.oxmysql:update(
                    "UPDATE weed_plants SET data = ? WHERE id = ?", { json.encode(plant), plant._id }
                )
            end
        end
    end
end

function RegisterTasks()
	if _run then return end
	_run = true
	
	CreateThread(function()
		while true do
			Wait((1000 * 60) * 10)
			SaveAllPlants()
		end
	end)
	
	CreateThread(function()
		while true do
			Wait((1000 * 60) * 10)
			Logger:Trace("Weed", "Processing plant growth")
            local updatingStuff = {}

            for k, v in pairs(_plants) do
				if (os.time() - v.plant.planted) >= Config.Lifetime then
					Logger:Trace("Weed", "Removing plant due to expiration (not harvested in time)")
                    Weed.Planting:Delete(k)
                else
                    if v.plant.growth < 100 then
                        local mat = Materials[v.plant.material]
                        if mat ~= nil then
                            local gt = GroundTypes[mat.groundType]
                            if gt ~= nil then
                                local phosphorus = gt.phosphorus
                                if v.plant.fertilizer ~= nil and v.plant.fertilizer.type == "phosphorus" then
                                    phosphorus = phosphorus + v.plant.fertilizer.value
                                end
                                v.plant.growth = v.plant.growth + (1 + phosphorus)
                                if v.stage ~= getStageByPct(v.plant.growth) then
                                    local res = Weed.Planting:Set(k, true, true)
                                    if res then
                                        table.insert(updatingStuff, res)
                                    end
                                end
                            else
                                Weed.Planting:Delete(k)
                            end
                        else
                            Weed.Planting:Delete(k)
                        end
                    end
                end
            end

            if #updatingStuff > 0 then
                TriggerLatentClientEvent("Weed:Client:Objects:UpdateMany", -1, 30000, updatingStuff)
            end
        end
    end)
	
	CreateThread(function()
		while true do
			Wait((1000 * 60) * 20)
			Logger:Trace("Weed", "Updating plant yield output")
			for k, v in pairs(_plants) do
				if v.plant.growth < 100 then
					local mat = Materials[v.plant.material]
					if mat ~= nil then
						local gt = GroundTypes[mat.groundType]
						if gt ~= nil then
							local nitrogen = gt.nitrogen
							if v.plant.fertilizer ~= nil and v.plant.fertilizer.type == "nitrogen" then
								nitrogen = nitrogen + v.plant.fertilizer.value
							end
							v.plant.output = (v.plant.output or 0) + (1 * (1 + nitrogen))
						end
					end
				end
			end
		end
	end)
	
	CreateThread(function()
		while true do
			Wait((1000 * 60) * 10)
			Logger:Trace("Weed", "Updating plant water levels")
			for k, v in pairs(_plants) do
				if v.plant.water > -25 then
					local mat = Materials[v.plant.material]
					if mat ~= nil then
						local gt = GroundTypes[mat.groundType]
						if gt ~= nil then
							local potassium = gt.potassium
							if v.plant.fertilizer ~= nil and v.plant.fertilizer.type == "potassium" then
								potassium = potassium + v.plant.fertilizer.value
							end
	
							v.plant.water = v.plant.water - ((1.0 * (1.0 + (1.0 - potassium))) - gt.water)
						else
							Weed.Planting:Delete(k)
						end
					else
						Weed.Planting:Delete(k)
					end
				else
					Logger:Trace("Weed", "Removing plant due to critical dehydration")
					Weed.Planting:Delete(k)
				end
			end
		end
	end)
	
	CreateThread(function()
		while true do
			Wait((1000 * 60) * 1)
			Logger:Trace("Weed", "Updating fertilizer duration")
			for k, v in pairs(_plants) do
				if v.plant.fertilizer ~= nil then
					if v.plant.fertilizer.time > 0 then
						v.plant.fertilizer.time = v.plant.fertilizer.time - 1
					else
						v.plant.fertilizer = nil
					end
				end
			end
		end
	end)
end
