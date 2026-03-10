_characterLoaded, GLOBAL_PED = false, nil

_interactionPeds = {}
_spawnedInteractionPeds = {}

AddEventHandler('PedInteraction:Shared:DependencyUpdate', RetrieveComponents)
function RetrieveComponents()
    Callbacks = exports['mythic-base']:FetchComponent('Callbacks')
    Notification = exports['mythic-base']:FetchComponent('Notification')
    Game = exports['mythic-base']:FetchComponent('Game')
    Utils = exports['mythic-base']:FetchComponent('Utils')
    Logger = exports['mythic-base']:FetchComponent('Logger')
    Targeting = exports['mythic-base']:FetchComponent('Targeting')
    PedInteraction = exports['mythic-base']:FetchComponent('PedInteraction')
end

AddEventHandler('Core:Shared:Ready', function()
    exports['mythic-base']:RequestDependencies('PedInteraction', {
        'Callbacks',
        'Notification',
        'Game',
        'Utils',
        'Logger',
        'Targeting',
        'PedInteraction',
    }, function(error)
        if #error > 0 then return; end
        RetrieveComponents()

        -- PedInteraction:Add('fuck', `a_m_y_soucent_04`, vector3(-810.171, -1311.092, 4.000), 332.419, 50.0, {
        --     { icon = 'boxes-stacked', text = 'F', event = 'F', data = {}, minDist = 2.0, jobs = false },
        -- })
    end)
end)

RegisterNetEvent("Characters:Client:Spawn")
AddEventHandler("Characters:Client:Spawn", function()
    _characterLoaded = true

    CreateThread(function()
        while _characterLoaded do
            Wait(1500)
            local pedCoords = GetEntityCoords(PlayerPedId())

            for k, v in pairs(_interactionPeds) do
                if v.enabled or v.force then
                    local inRange = v.force or #(v.coords - pedCoords) <= v.range
                    if inRange and not _spawnedInteractionPeds[k] then
                        _spawnedInteractionPeds[k] = CreateDumbAssPed(v.model, v.coords, v.heading, v.menu, v.icon, v.scenario, v.anim, v.component)
                    elseif not inRange and not v.force and _spawnedInteractionPeds[k] then
                        DeletePed(_spawnedInteractionPeds[k])
                        Targeting:RemovePed(_spawnedInteractionPeds[k])
                        _spawnedInteractionPeds[k] = nil
                    end
                elseif _spawnedInteractionPeds[k] then
                    DeletePed(_spawnedInteractionPeds[k])
                    Targeting:RemovePed(_spawnedInteractionPeds[k])
                    _spawnedInteractionPeds[k] = nil
                end
            end
        end
    end)
end)

RegisterNetEvent('Characters:Client:Logout')
AddEventHandler('Characters:Client:Logout', function()
    _characterLoaded = false

    for k, v in pairs(_spawnedInteractionPeds) do
        DeleteEntity(v)
    end

    _spawnedInteractionPeds = {}
end)

_pedShit = {
    Add = function(self, id, model, coords, heading, range, menu, icon, scenario, enabled, anim, component)
        if id and model and type(coords) == 'vector3' and type(heading) == 'number' then
            if enabled == nil then
                enabled = true
            end

            local modelRaw = nil
            if type(model) == 'string' then
                modelRaw = model
                model = GetHashKey(model)
            end

            if not range then
                range = 50.0
            end

            if not IsModelValid(model) or not IsModelAPed(model) then
                Logger:Error('PedInteraction', 'Failed to Add Ped ID: '.. id .. ' - It\'s Model is Invalid')
                return
            end

            _interactionPeds[id] = {
                enabled = enabled,
                range = range,
                model = model,
                modelRaw = modelRaw,
                coords = coords,
                heading = heading,
                icon = icon,
                menu = menu,
                scenario = scenario,
                anim = anim,
                component = component,
            }
        end
    end,
    Toggle = function(self, id, enabled)
        if _interactionPeds[id] then
            _interactionPeds[id].enabled = enabled
        end
    end,
    Remove = function(self, id)
        if _interactionPeds[id] then
            _interactionPeds[id] = nil
            if _spawnedInteractionPeds[id] then
                DeleteEntity(_spawnedInteractionPeds[id])
                Targeting:RemovePed(_spawnedInteractionPeds[id])
                _spawnedInteractionPeds[id] = nil
            end
        end
    end,
    GetPed = function(self, id)
        if _spawnedInteractionPeds[id] then
            return _spawnedInteractionPeds[id]
        end
        return false
    end,
    GetAll = function(self)
        local out = {
            total = 0,
            spawned = 0,
            peds = {},
        }

        for id, def in pairs(_interactionPeds) do
            local snap = buildPedSnapshot(id, def)
            out.peds[#out.peds + 1] = snap
            out.total = out.total + 1
            if snap.spawned then out.spawned = out.spawned + 1 end
        end

        table.sort(out.peds, function(a, b)
            return tostring(a.id) < tostring(b.id)
        end)

        return out
    end,
    ForceSpawn = function(self, id)
        if _interactionPeds[id] then
            _interactionPeds[id].force = true
        end
    end,
    ForceDespawn = function(self, id)
        if _interactionPeds[id] then
            _interactionPeds[id].force = false
        end
        if _spawnedInteractionPeds[id] then
            DeleteEntity(_spawnedInteractionPeds[id])
            Targeting:RemovePed(_spawnedInteractionPeds[id])
            _spawnedInteractionPeds[id] = nil
        end
    end,
    Update = function(self, id, patch)
        if not id or not _interactionPeds[id] or type(patch) ~= 'table' then return false end

        local def = _interactionPeds[id]
        patch = normalizePatchForPed(def, patch)

        for k, v in pairs(patch) do
            def[k] = v
        end

        if def.model and (not IsModelValid(def.model) or not IsModelAPed(def.model)) then
            Logger:Error('PedInteraction', 'Update failed: invalid model for ' .. tostring(id))
            return false
        end

        if _spawnedInteractionPeds[id] and DoesEntityExist(_spawnedInteractionPeds[id]) then
            DeleteEntity(_spawnedInteractionPeds[id])
            Targeting:RemovePed(_spawnedInteractionPeds[id])
            _spawnedInteractionPeds[id] = nil
        end

        return true
    end,
    CreateTemp = function(self, tempId, def)
        if not tempId or _interactionPeds[tempId] then return false end
        if type(def) ~= 'table' then return false end

        if type(def.model) == 'string' then
            def.modelRaw = def.model
            def.model = GetHashKey(def.model)
        end

        def.coords = toVector3(def.coords)
        def.heading = toNumber(def.heading, 0.0)
        def.range = toNumber(def.range, 25.0)
        def.menu = normalizeMenuForRuntime(def.menu or {})
        def.anim = normalizeAnim(def.anim)
        if def.scenario == '' then def.scenario = nil end
        if def.scenario then def.anim = nil end

        if not def.model or not def.coords then return false end
        if not IsModelValid(def.model) or not IsModelAPed(def.model) then
            Logger:Error('PedInteraction', 'CreateTemp failed: invalid model ' .. tostring(tempId))
            return false
        end

        _interactionPeds[tempId] = {
            enabled = def.enabled ~= false,
            range = def.range,
            model = def.model,
            modelRaw = def.modelRaw,
            coords = def.coords,
            heading = def.heading,
            icon = def.icon,
            menu = def.menu,
            scenario = def.scenario,
            anim = def.anim,
            component = type(def.component) == 'table' and def.component or nil,
            force = def.force and true or false,
            temp = true,
        }

        if _spawnedInteractionPeds[tempId] then
            DeleteEntity(_spawnedInteractionPeds[tempId])
            Targeting:RemovePed(_spawnedInteractionPeds[tempId])
            _spawnedInteractionPeds[tempId] = nil
        end

        return true
    end,
    RemoveTemp = function(self, id)
        if not id or not _interactionPeds[id] then return false end
        if not _interactionPeds[id].temp then return false end
        self:Remove(id)
        return true
    end,
}

AddEventHandler('Proxy:Shared:RegisterReady', function()
    exports['mythic-base']:RegisterComponent('PedInteraction', _pedShit)
end)

function buildPedSnapshot(id, def)
    local spawned = _spawnedInteractionPeds[id] ~= nil and DoesEntityExist(_spawnedInteractionPeds[id])
    local entity = spawned and _spawnedInteractionPeds[id] or nil
    local currentCoords = nil
    local netId = nil

    if spawned and entity then
        local ec = GetEntityCoords(entity)
        currentCoords = { x = ec.x, y = ec.y, z = ec.z }
        if NetworkGetEntityIsNetworked(entity) then
            netId = NetworkGetNetworkIdFromEntity(entity)
        end
    end

    local menuSnapshot = {}
    if def.menu and type(def.menu) == 'table' then
        for i, opt in ipairs(def.menu) do
            menuSnapshot[i] = {
                icon = opt.icon,
                text = opt.text or opt.label,
                event = opt.event,
                data = opt.data,
                minDist = opt.minDist,
                jobs = opt.jobs or opt.jobPerms or false,
            }
        end
    end

    return {
        id = id,
        enabled = def.enabled,
        range = def.range,
        model = def.model,
        modelRaw = def.modelRaw,
        coords = def.coords and { x = def.coords.x, y = def.coords.y, z = def.coords.z } or nil,
        heading = def.heading,
        icon = def.icon,
        scenario = def.scenario,
        anim = def.anim,
        component = def.component,
        menu = menuSnapshot,
        spawned = spawned,
        entity = entity,
        netId = netId,
        currentCoords = currentCoords,
        force = def.force or false,
        temp = def.temp or false,
    }
end

function toVector3(v)
    if type(v) == 'vector3' then return v end
    if type(v) == 'table' and v.x and v.y and v.z then
        return vector3(tonumber(v.x) or 0.0, tonumber(v.y) or 0.0, tonumber(v.z) or 0.0)
    end
    return nil
end

function toNumber(n, default)
    n = tonumber(n)
    if n == nil then return default end
    return n
end

function normalizeAnim(anim)
    if type(anim) ~= 'table' then return nil end
    if not anim.animDict or not anim.anim then return nil end
    return {
        animDict = anim.animDict,
        anim = anim.anim,
        flag = toNumber(anim.flag, 1),
        blendIn = toNumber(anim.blendIn, 8.0),
        blendOut = toNumber(anim.blendOut, 8.0),
        duration = toNumber(anim.duration, -1),
        playback = toNumber(anim.playback, 0),
        lockX = toNumber(anim.lockX, 0),
        lockY = toNumber(anim.lockY, 0),
        lockZ = toNumber(anim.lockZ, 0),
    }
end

function normalizeMenuForRuntime(menu)
    if type(menu) ~= 'table' then return {} end
    for i = 1, #menu do
        local opt = menu[i]
        if type(opt) == 'table' then
            if type(opt.data) == 'string' then
                local ok, decoded = pcall(json.decode, opt.data)
                if ok and type(decoded) == 'table' then
                    opt.data = decoded
                else
                    opt.data = {}
                end
            end
            opt.minDist = toNumber(opt.minDist, 2.0)
            if opt.jobs == '' then opt.jobs = false end
        end
    end
    return menu
end

function normalizePatchForPed(def, patch)
    if type(patch) ~= 'table' then return patch end

    if patch.coords ~= nil then
        local v = toVector3(patch.coords)
        if v then patch.coords = v else patch.coords = def.coords end
    end

    if patch.model ~= nil then
        if type(patch.model) == 'string' then
            patch.modelRaw = patch.model
            patch.model = GetHashKey(patch.model)
        end
    end

    if patch.modelRaw ~= nil and type(patch.modelRaw) == 'string' and patch.modelRaw ~= '' then
        if patch.model == nil then
            patch.model = GetHashKey(patch.modelRaw)
        end
    end

    if patch.range ~= nil then patch.range = toNumber(patch.range, def.range or 50.0) end
    if patch.heading ~= nil then patch.heading = toNumber(patch.heading, def.heading or 0.0) end

    if patch.enabled ~= nil then patch.enabled = patch.enabled and true or false end
    if patch.force ~= nil then patch.force = patch.force and true or false end

    if patch.scenario ~= nil then
        if patch.scenario == '' then patch.scenario = nil end
    end
    if patch.anim ~= nil then
        patch.anim = normalizeAnim(patch.anim)
    end
    if patch.scenario and type(patch.scenario) == 'string' and patch.scenario ~= '' then
        patch.anim = nil
    end

    if patch.menu ~= nil then
        patch.menu = normalizeMenuForRuntime(patch.menu)
    end

    if patch.component ~= nil and type(patch.component) ~= 'table' then
        patch.component = nil
    end

    return patch
end

function CreateDumbAssPed(model, coords, heading, menu, icon, scenario, anim, component)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end

    local ped = CreatePed(5, model, coords.x, coords.y, coords.z, heading, false, false)
    SetEntityAsMissionEntity(ped, true, true)
    FreezeEntityPosition(ped, true)
    SetPedCanRagdoll(ped, false)
    TaskSetBlockingOfNonTemporaryEvents(ped, 1)
    SetBlockingOfNonTemporaryEvents(ped, 1)
    SetPedFleeAttributes(ped, 0, 0)
    SetPedCombatAttributes(ped, 17, 1)
    SetEntityInvincible(ped, true)
    SetPedSeeingRange(ped, 0)
    SetPedDefaultComponentVariation(ped)
    SetModelAsNoLongerNeeded(model)

    if component and type(component) == "table" then
        SetPedComponentVariation(ped, component.componentId or 0, component.drawableId or 0, component.texture or 0, component.textureId or 0, component.paletteId or 0)
    end

    if anim and type(anim) == "table" and anim.animDict and anim.anim then
        ClearPedTasks(ped)
        LoadAnim(anim.animDict)
        TaskPlayAnim(ped, anim.animDict, anim.anim, anim.blendIn or 8.0, anim.blendOut or 8.0, anim.duration or -1, anim.flag or 1, anim.playback or 0, anim.lockX or 0, anim.lockY or 0, anim.lockZ or 0)
    elseif scenario and type(scenario) == "string" then
        ClearPedTasks(ped)
        TaskStartScenarioInPlace(ped, scenario, 0, true)
    end

    if menu then
        if not icon then icon = 'person-walking' end
        Targeting:AddPed(ped, icon, menu)
    end

    return ped
end

function LoadAnim(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end