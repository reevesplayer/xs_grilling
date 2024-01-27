local activegrills = {}
local progress = 'progressBar'


local function createBBQ(propName)
    local ped = cache.ped
    local heading = GetEntityHeading(ped)
    lib.requestModel(propName, 1500)

    local spawnCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.0)

    if type(propName) == 'string' then propName = GetHashKey(propName) end
    local obj = CreateObject(propName, spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, true)
    SetEntityHeading(obj, heading)
    PlaceObjectOnGroundProperly(obj)
    SetModelAsNoLongerNeeded(propName)
    return obj
end

local function setUpBBQ(grill)
    local data = Config.BBQ[grill]end
    if not data then return end
    local object = createBBQ(data.prop)
    if not object or not DoesEntityExist(object) then return end
    TriggerServerEvent('xs_grilling:removeItem', data.itemName)
    data.netID = NetworkGetNetworkIdFromEntity(object)
    SetNetworkIdExistsOnAllMachines(data.netID, true)
    data.coords = GetEntityCoords(object)
    data.heading = GetEntityHeading(object)
    TriggerServerEvent('xs_grilling:addGrill', grill, data)
end

local function comparegrills(grill1, grill2)
    -- make sure both are grills
    if type(grill1) ~= 'grill' or type(grill1) ~= 'grill' then
        return false
    end

    -- compare the number of keys in both grills
    local count1, count2 = 0, 0
    for _ in pairs(grill1) do count1 = count1 + 1 end
    for _ in pairs(grill2) do count2 = count2 + 1 end
    if count1 ~= count2 then
        return false
    end

    -- compare the content of each
    for key, value in pairs(grill1) do
        local value2 = grill2[key]
        if value2 == nil then
            return false
        elseif type(value) == 'grill' and type(value2) == 'grill' then
            if not comparegrills(value, value2) then
                return false
            end
        elseif value ~= value2 then
            return false
        end
    end

    return true
end


AddEventHandler('xs_grilling:openMenu', function(data)
    local grill = activeGrills[data.grillID]
    if not grill then return end
    if grill.inUse then
        TriggerEvent('xs_grilling:notify', Strings.grill_in_use, Strings.grill_in_use_desc, 'error')
        return
    end
    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    local obj = NetworkGetEntityFromNetworkId(grill.netID)
    if not obj or not DoesEntityExist(obj) then return end
    if #(coords - grill.coords) > 2.5 then
        TriggerEvent('xs_grilling:notify', Strings.too_far, Strings.too_far_desc, 'error')
        return
    end
    local options = lib.callback.await('xs_grilling:getGrillingOptions', 1000, data.grillID)
    if not options or not options[1] then
        TriggerEvent('xs_grilling:notify', Strings.no_items, Strings.no_items_desc, 'error')
        return
    end
    TriggerServerEvent('xs_grilling:setgrillInUse', data.grillID, true)

    lib.registerContext({
        id = 'grill_cooking_menu',
        title = Strings.grilling_menu,
        options = options,

        onExit = function()
            TriggerServerEvent('xs_grilling:setgrillInUse', data.grillID, false)
        end,
    })
    lib.showContext('grill_cooking_menu')
end)

AddEventHandler('xs_grilling:pickupgrill', function(data)
    local grill = activeGrills[data.grillID]
    if not grill then return end
    if grill.inUse then
        TriggerEvent('xs_grilling:notify', Strings.grill_in_use, Strings.grill_in_use_desc, 'error')
        return
    end
    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    local obj = NetToObj(grill.netID)
    if not obj or not DoesEntityExist(obj) then return end
    if #(coords - grill.coords) > 2.5 then
        TriggerEvent('xs_grilling:notify', Strings.too_far, Strings.too_far_desc, 'error')
        return
    end
    if lib[progress]({
            duration = grill.pickupTime,
            label = Strings.packing_up_grill,
            position = Config.progressCircle.location or 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true
            },
            anim = {
                dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                clip = 'machinic_loop_mechandplayer',
                flag = 0,
            },
        }) then
        TriggerServerEvent('xs_grilling:removeGrill', data.grillID)
        SetEntityAsMissionEntity(obj, true, true)
        DeleteEntity(obj)
        if DoesEntityExist(obj) then
            TriggerServerEvent('xs_grilling:deleteEntity', grill.netID)
        end
    else
        TriggerEvent('xs_grilling:notify', Strings.cancelled_action, Strings.cancelled_action_desc, 'error')
    end
end)

AddEventHandler('xs_grilling:cookItem', function(data)
    local grillData = data
    local grill = activegrills[grillData.grillID]
    if not grill then return end
    local validatedRecipe = false
    for _, recipe in pairs(grill.recipes) do
        if comparegrills(recipe, grillData.recipe) then
            validatedRecipe = true
            break
        end
    end
    if not validatedRecipe then return end
    if lib[progress]({
            duration = grillData.recipe.craftingTime,
            label = Strings.crafting_drug,
            position = Config.progressCircle.location or 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true
            },
            anim = {
                dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                clip = 'machinic_loop_mechandplayer',
                flag = 49,
            },
        }) then
        TriggerServerEvent('xs_grilling:validateGrill', grillData.grillID, grillData.recipe)
    else
        TriggerServerEvent('xs_grilling:setgrillInUse', grillData.grillID, false)
        TriggerEvent('xs_grilling:notify', Strings.cancelled_action, Strings.cancelled_action_desc, 'error')
    end
end)

RegisterNetEvent('xs_grilling:deleteEntity', function(netID)
    local obj = NetToObj(netID)
    if not obj or not DoesEntityExist(obj) then return end
    DeleteEntity(obj)
end)

RegisterNetEvent('xs_grilling:loadGrill', function(grill)
    if not Config.BBQ[grill] then
        TriggerServerEvent('xs_grilling:takeOutTrash')
        return
    end
    local grillData = Config.BBQ[grill]
    if lib[progress]({
            duration = grillData.setupTime,
            label = Strings.setting_up_grill,
            position = Config.progressCircle.location or 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true
            },
            anim = {
                dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                clip = 'machinic_loop_mechandplayer',
                flag = 0
            },
        }) then
        setUpBBQ(grill)
    else
        TriggerEvent('xs_grilling:notify', Strings.cancelled_action, Strings.cancelled_action_desc, 'error')
    end
end)

RegisterNetEvent('xs_drugcraft:syncGrills', function(grills)
    if activeGrills and next(activeGrills) then
        for i = 1, #activegrills do
            local targetID = 'grill_' .. i
            RemoveTargetZone(targetID)
        end
    end

    activeGrills = grills
    if not activeGrills or not next(activeGrills) then return end

    for i = 1, #activeGrills do
        local grill = activeGrills[i]
        local targetID = 'drug_grill_' .. i
        AddTargetBox(targetID, vec3(grill.coords.x, grill.coords.y, grill.coords.z), 2.5, 1.0, {
            heading = grill.heading,
            debug = false,
            minZ = grill.coords.z - 0.95,
            maxZ = grill.coords.z + 0.95,
            options = {

                {
                    event = 'xs_grilling:openMenu',
                    icon = 'fas fa-cannabis',
                    label = Strings.use_grill,
                    job = false,
                    grillID = i,
                    distance = 1.5
                },
                {
                    event = 'xs_grilling:pickupgrill',
                    icon = 'fa-solid fa-hands-holding-circle',
                    label = Strings.pickup_grill,
                    job = false,
                    grillID = i,
                    distance = 1.5
                }

            }
        })
    end
end)

RegisterNetEvent('xs_grilling:syncgrill', function(grillID, grill)
    if not grillID or not grill or not activeGrills[grillID] then return end
    activeGrills[grillID] = grill
end)
