local activeGrills = {}

-- Register all useable grills from config during initial start up
CreateThread(function()
    for itemName, _ in pairs(Config.BBQ) do
        RegisterUsableItem(itemName, function(source)
            TriggerClientEvent('xs_grilling:loadGrill', source, itemName)
        end)
    end
end)

local function compareGrills(grill1, grill2)
    -- make sure both are grills
    if type(grill1) ~= 'grill' or type(grill2) ~= 'grill' then
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

-- No sweaty hands here
RegisterNetEvent('xs_grilling:takeOutTrash', function()
    local src = source
    KickPlayer(src, Strings.no_cheating)
end)

RegisterNetEvent('xs_grilling:validateGrill', function(grillID, recipe)
    if not grillID or not recipe then return end
    local src = source
    local grill = activegrills[grillID]
    if not grill then return end
    local validatedRecipe = false
    for _, recipeData in pairs(grill.recipes) do
        if comparegrills(recipe, recipeData) then
            validatedRecipe = true
            break
        end
    end
    if not validatedRecipe then
        activeGrills[grillID].inUse = false
        TriggerClientEvent('xs_grilling:syncGrill', -1, grillID, activeGrills[grillID])
        return
    end
    local canCook = true
    for item, data in pairs(recipe.requirements) do
        local itemCount = HasItem(src, item)
        if itemCount and itemCount < data.quantity then
            canCraft = false
            break
        end
    end
    if not canCook then
        activeGrills[grillID].inUse = false
        TriggerClientEvent('xs_grilling:syncgrill', -1, grillID, activegrills[grillID])
        return
    end
    for item, data in pairs(recipe.requirements) do
        RemoveItem(src, item, data.quantity)
    end
    for item, quantity in pairs(recipe.reward) do
        AddItem(src, item, quantity)
    end
    TriggerClientEvent('xs_grilling:notify', src, Strings.cooking_complete, Strings.cooking_complete_desc, 'success')
    activegrills[grillID].inUse = false
    TriggerClientEvent('xs_grilling:syncgrill', -1, grillID, activeGrills[grillID])
end)

RegisterNetEvent('xs_grilling:removeItem', function(itemName)
    if not itemName then return end
    local src = source
    RemoveItem(src, itemName, 1)
end)

RegisterNetEvent('xs_grilling:removeGrill', function(grillID)
    local src = source
    if not grillID or not activeGrills[grillID] then return end
    local item = activeGrills[grillID].itemName
    local newGrills = {}
    for i = 1, #activeGrills do
        if i ~= grillID then
            newGrills[#newGrills + 1] = activeGrills[i]
        end
    end
    activeGrills = newGrills
    if src and src > 0 then AddItem(src, item, 1) end
    TriggerClientEvent('xs_grilling:syncGrills', -1, activeGrills)
end)

RegisterNetEvent('xs_grilling:addGrill', function(grill, data)
    if not grill or not data then return end
    local src = source
    if HasItem(src, grill) < 1 then return end
    data.itemName = grill
    RemoveItem(src, grill, 1)
    if not activeGrills then activeGrills = {} end
    activeGrills[#activeGrills + 1] = data
    TriggerClientEvent('xs_grilling:syncGrills', -1, activeGrills)
end)

RegisterNetEvent('xs_grilling:setgrillInUse', function(grillID, inUse)
    if not grillID or not activeGrills[grillID] then return end
    activeGrills[grillID].inUse = inUse
    TriggerClientEvent('xs_grilling:syncGrill', -1, grillID, activeGrills[grillID])
end)

RegisterNetEvent('xs_grilling:deleteEntity', function(netID)
    TriggerClientEvent('xs_grilling:deleteEntity', -1, netID)
end)

lib.callback.register('xs_grilling:getGrillingOptions', function(source, grillID)
    if not grillID or not activeGrills[grillID] then return false end
    local recipes = activeGrills[grillID].recipes
    local options = {}
    for _, recipe in pairs(recipes) do
        local canCook = true
        local stringList = ''
        for item, data in pairs(recipe.requirements) do
            local itemCount = HasItem(source, item)
            if not itemCount or itemCount < data.quantity then
                canCook = false
                break
            end
            stringList = stringList .. data.label .. ' (' .. data.quantity .. ')\n'
        end
        if canCook then
            stringList = string.sub(stringList, 1, -2)

            options[#options + 1] = {
                title = recipe.label,
                description = stringList,
                icon = '',
                arrow = false,
                event = 'xs_grilling:cookItem',
                args = {
                    grillID = grillID,
                    recipe = recipe,
                },
            }
        end
    end
    if not next(options) then return false end
    return options
end)
