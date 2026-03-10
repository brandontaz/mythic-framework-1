AddEventHandler("Phone:Server:RegisterCallbacks", function()
	Callbacks:RegisterServerCallback("Phone:CityServices:GetBusinesses", function(source, data, cb)
		local businesses = {}
		local onlineJobs = {}
		
		-- Loop through all online players to find who's on duty
		for _, player in pairs(Fetch:All()) do
			if player ~= nil then
				local char = player:GetData("Character")
				if char ~= nil then
					local src = player:GetData("Source")
					local onDuty = Player(src).state.onDuty
					
					if onDuty then
						local jobData = Jobs:Get(onDuty)
						if jobData then
							-- Include police but exclude other government jobs
							local isExcluded = onDuty == "ems" or onDuty == "government" or onDuty == "prison"
							
							if not isExcluded and not jobData.Hidden then
								if not onlineJobs[jobData.Id] then
									onlineJobs[jobData.Id] = {
										Id = jobData.Id,
										Name = jobData.Name,
										Type = jobData.Type or "Business",
										Owner = jobData.Owner,
										EmployeeCount = 0,
										Workplaces = {},
									}
								end
								
								-- Track workplace for police
								if onDuty == "police" then
									local workplace = Player(src).state.onDutyWorkplace or "lspd"
									if not onlineJobs[jobData.Id].Workplaces[workplace] then
										onlineJobs[jobData.Id].Workplaces[workplace] = 0
									end
									onlineJobs[jobData.Id].Workplaces[workplace] = onlineJobs[jobData.Id].Workplaces[workplace] + 1
								end
								
								onlineJobs[jobData.Id].EmployeeCount = onlineJobs[jobData.Id].EmployeeCount + 1
							end
						end
					end
				end
			end
		end
		
		-- Convert to array
		for k, v in pairs(onlineJobs) do
			table.insert(businesses, v)
		end
		
		-- Sort by name
		table.sort(businesses, function(a, b)
			return a.Name < b.Name
		end)
		
		cb(businesses)
	end)
end)
