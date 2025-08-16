local QBCore = exports[Config.CoreName]:GetCoreObject()

local cooldown = false

-- Item Handler
RegisterNetEvent("sd-airdrop:server:ItemHandler", function(kind, item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if kind == 'add' then
        Player.Functions.AddItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', amount)
    elseif kind == 'remove' then
        Player.Functions.RemoveItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove', amount)
    end    
end)

QBCore.Functions.CreateCallback('sd-airdrop:server:cooldown', function(source, cb)
	if cooldown then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('sd-airdrop:server:startCooldown', function()
    if cooldown == false then
        cooldown = true 
        local timer = Config.Cooldown * 60000
        print("Airdrop: Cooldown started")
        
        -- Global emergency message to all players via LB-Phone
        local players = QBCore.Functions.GetQBPlayers()
        for src, player in pairs(players) do
            local phoneNumber = exports['lb-phone']:GetEquippedPhoneNumber(src)
            if phoneNumber then
                local success, err = pcall(function()
                    exports['lb-phone']:SendMessage('EMERGENCY-ALERT', phoneNumber, '🚨 GOVERNMENT ALERT: Unidentified package being dropped, check GPS for location. Citizens are advised to maintain safe distance as area is reported KOS. Proceed with extreme caution.', {})
                end)
                
                if not success then
                    print('[SD-AIRDROP] Failed to send emergency message to player ' .. src .. ': ' .. tostring(err))
                end
            end
        end
        
        -- Use non-blocking SetTimeout instead of blocking while loop
        SetTimeout(timer, function()
            TriggerClientEvent('sd-airdrop:crate:clearcrate', -1)
            print('Airdrop: Cooldown finished')
            cooldown = false
        end)
    end
end)

RegisterNetEvent('sd-airdrop:crate:deleteCrate', function(netId)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then 
        print("[sd-airdrop] Error: Invalid player in deleteCrate event")
        return 
    end

    if not netId or netId == 0 then
        print("[sd-airdrop] Error: Invalid netId in deleteCrate event")
        return
    end

    local crate = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(crate) then
        DeleteEntity(crate)
        TriggerClientEvent('sd-airdrop:crate:destroyzone', -1)
    else
        print("[sd-airdrop] Warning: Crate entity does not exist for netId: " .. tostring(netId))
    end
end)

RegisterNetEvent('dropCoords:server:setPoly', function(dropCoords)
    TriggerClientEvent('dropCoords:client:setPoly', -1, dropCoords)
end)

RegisterNetEvent("sd-airdrop:crate:spawnCrate")
AddEventHandler("sd-airdrop:crate:spawnCrate", function(crateSpawn, item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then 
        print("[sd-airdrop] Error: Invalid player in spawnCrate event")
        return 
    end
    
    if not crateSpawn or not crateSpawn.x or not crateSpawn.y or not crateSpawn.z then
        print("[sd-airdrop] Error: Invalid coordinates in spawnCrate event")
        return
    end
    
    if not item or not amount or amount <= 0 then
        print("[sd-airdrop] Error: Invalid item or amount in spawnCrate event")
        return
    end
    
    local crate = CreateObject(GetHashKey(Config.CrateModel), crateSpawn, true, true, true)
    
    local attempts = 0
    while not DoesEntityExist(crate) and attempts < 100 do 
        Wait(25)
        attempts = attempts + 1
    end
    
    if not DoesEntityExist(crate) then
        print("[sd-airdrop] Error: Failed to create crate entity after 100 attempts")
        return
    end
    
    local netId = NetworkGetNetworkIdFromEntity(crate)
    if not netId or netId == 0 then
        print("[sd-airdrop] Error: Failed to get network ID for crate")
        DeleteEntity(crate)
        return
    end
    
    Wait(25)
    TriggerClientEvent("sd-airdrop:crate:applyNatives", src, netId) 
    
    -- Increased timeout to ensure better network sync
    SetTimeout(5000, function()
        if DoesEntityExist(crate) then
            TriggerClientEvent("sd-airdrop:crate:createQbTarget", -1, netId, crate, item, amount)
        else
            print("[sd-airdrop] Warning: Crate no longer exists when creating target")
        end
    end)
end)

-- get amount of cops online and on duty
QBCore.Functions.CreateCallback('sd-airdrop:server:getCops', function(source, cb)
    local count = 0
    for _, job in pairs(Config.PoliceJobs) do
        local amount = QBCore.Functions.GetDutyCount(job)
        count += amount
    end	
    Wait(100)
    cb(count)
end)

-- Golden Satalite Phone
QBCore.Functions.CreateUseableItem("goldenphone", function(source, item)
    local src = source    
    TriggerClientEvent("sd-airdrop:client:CreateDrop", src, tostring(item.name), true, 400)            
end)

-- Red Satellite Phone
QBCore.Functions.CreateUseableItem("redphone", function(source, item)
    local src = source    
    TriggerClientEvent("sd-airdrop:client:CreateDrop", src, tostring(item.name), true, 400)            
end)

-- Green Satellite Phone
QBCore.Functions.CreateUseableItem("greenphone", function(source, item)
    local src = source    
    TriggerClientEvent("sd-airdrop:client:CreateDrop", src, tostring(item.name), true, 400)            
end)
