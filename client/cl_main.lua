local QBCore = exports[Config.CoreName]:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local inZone = false
local currentZone = nil
local currentCrate = nil
local currentNetId = nil
local crateBlip = nil
local dropBlip = nil
local dropZone = nil
local isInDropZone = false

-- Player data update
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

-- Utility Functions
local function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function ShowNotification(text, type)
    if type == 'error' then
        QBCore.Functions.Notify(text, 'error', 5000)
    elseif type == 'success' then
        QBCore.Functions.Notify(text, 'success', 5000)
    else
        QBCore.Functions.Notify(text, 'primary', 5000)
    end
end

local function GetRandomDropLocation()
    local locations = Config.DropLocations
    if #locations == 0 then
        print("[sd-airdrop] Error: No drop locations configured")
        return nil
    end
    
    local randomIndex = math.random(1, #locations)
    return locations[randomIndex]
end

local function CreateDropBlip(coords)
    if dropBlip then
        RemoveBlip(dropBlip)
    end
    
    dropBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(dropBlip, 478)
    SetBlipDisplay(dropBlip, 4)
    SetBlipScale(dropBlip, 1.0)
    SetBlipColour(dropBlip, 1)
    SetBlipAsShortRange(dropBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Airdrop Zone")
    EndTextCommandSetBlipName(dropBlip)
end

local function CreateCrateBlip(coords)
    if crateBlip then
        RemoveBlip(crateBlip)
    end
    
    crateBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(crateBlip, 478)
    SetBlipDisplay(crateBlip, 4)
    SetBlipScale(crateBlip, 1.2)
    SetBlipColour(crateBlip, 2)
    SetBlipAsShortRange(crateBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Supply Crate")
    EndTextCommandSetBlipName(crateBlip)
end

local function CreateDropZone(coords)
    if dropZone then
        exports['qb-polyzone']:RemoveZone("airdrop_zone")
    end
    
    dropZone = exports['qb-polyzone']:CreateCircleZone("airdrop_zone", coords, Config.DropZoneRadius, {
        name = "airdrop_zone",
        debugPoly = Config.Debug
    })
    
    dropZone:onPlayerInOut(function(isPointInside)
        isInDropZone = isPointInside
        if isPointInside then
            ShowNotification("You have entered the airdrop zone!", "primary")
        else
            ShowNotification("You have left the airdrop zone!", "primary")
        end
    end)
end

local function RemoveDropZone()
    if dropZone then
        exports['qb-polyzone']:RemoveZone("airdrop_zone")
        dropZone = nil
        isInDropZone = false
    end
end

local function SpawnPlane(dropLocation)
    local planeModel = GetHashKey(Config.PlaneModel)
    RequestModel(planeModel)
    
    local attempts = 0
    while not HasModelLoaded(planeModel) and attempts < 100 do
        Wait(50)
        attempts = attempts + 1
    end
    
    if not HasModelLoaded(planeModel) then
        print("[sd-airdrop] Error: Failed to load plane model")
        return nil
    end
    
    local spawnCoords = vector3(dropLocation.x + Config.PlaneSpawnDistance, dropLocation.y + Config.PlaneSpawnDistance, dropLocation.z + Config.PlaneHeight)
    local plane = CreateVehicle(planeModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, false)
    
    if not DoesEntityExist(plane) then
        print("[sd-airdrop] Error: Failed to create plane entity")
        return nil
    end
    
    SetEntityInvincible(plane, true)
    SetVehicleEngineOn(plane, true, true, false)
    SetVehicleForwardSpeed(plane, Config.PlaneSpeed)
    
    -- Calculate heading towards drop location
    local heading = GetHeadingFromVector_2d(dropLocation.x - spawnCoords.x, dropLocation.y - spawnCoords.y)
    SetEntityHeading(plane, heading)
    
    return plane
end

local function SpawnParachute(coords)
    local parachuteModel = GetHashKey(Config.ParachuteModel)
    RequestModel(parachuteModel)
    
    local attempts = 0
    while not HasModelLoaded(parachuteModel) and attempts < 100 do
        Wait(50)
        attempts = attempts + 1
    end
    
    if not HasModelLoaded(parachuteModel) then
        print("[sd-airdrop] Error: Failed to load parachute model")
        return nil
    end
    
    local parachute = CreateObject(parachuteModel, coords.x, coords.y, coords.z + 100, true, true, true)
    
    if not DoesEntityExist(parachute) then
        print("[sd-airdrop] Error: Failed to create parachute entity")
        return nil
    end
    
    return parachute
end

local function AnimateParachuteDrop(parachute, targetCoords)
    if not DoesEntityExist(parachute) then
        return
    end
    
    local startCoords = GetEntityCoords(parachute)
    local dropTime = Config.DropTime * 1000 -- Convert to milliseconds
    local startTime = GetGameTimer()
    
    CreateThread(function()
        while DoesEntityExist(parachute) do
            local currentTime = GetGameTimer()
            local elapsed = currentTime - startTime
            local progress = math.min(elapsed / dropTime, 1.0)
            
            if progress >= 1.0 then
                SetEntityCoords(parachute, targetCoords.x, targetCoords.y, targetCoords.z)
                break
            end
            
            local currentZ = startCoords.z - (progress * (startCoords.z - targetCoords.z))
            SetEntityCoords(parachute, targetCoords.x, targetCoords.y, currentZ)
            
            Wait(16) -- ~60 FPS
        end
        
        -- Clean up parachute
        if DoesEntityExist(parachute) then
            DeleteEntity(parachute)
        end
    end)
end

-- Main airdrop creation function
RegisterNetEvent("sd-airdrop:client:CreateDrop")
AddEventHandler("sd-airdrop:client:CreateDrop", function(item, isPhone, radius)
    QBCore.Functions.TriggerCallback('sd-airdrop:server:getCops', function(cops)
        if cops < Config.MinCops then
            ShowNotification("Not enough police online! (" .. cops .. "/" .. Config.MinCops .. ")", "error")
            return
        end
        
        QBCore.Functions.TriggerCallback('sd-airdrop:server:cooldown', function(cooldownActive)
            if cooldownActive then
                ShowNotification("Airdrop is on cooldown!", "error")
                return
            end
            
            local dropLocation = GetRandomDropLocation()
            if not dropLocation then
                ShowNotification("Failed to find drop location!", "error")
                return
            end
            
            -- Remove the item if it's a phone
            if isPhone then
                TriggerServerEvent("sd-airdrop:server:ItemHandler", 'remove', item, 1)
            end
            
            -- Start cooldown
            TriggerServerEvent('sd-airdrop:server:startCooldown')
            
            -- Create drop zone and blip
            CreateDropZone(dropLocation)
            CreateDropBlip(dropLocation)
            TriggerServerEvent('dropCoords:server:setPoly', dropLocation)
            
            ShowNotification("Airdrop incoming! Check your map for the drop zone.", "success")
            
            -- Spawn plane
            local plane = SpawnPlane(dropLocation)
            if not plane then
                ShowNotification("Failed to spawn plane!", "error")
                return
            end
            
            -- Wait for plane to reach drop location
            CreateThread(function()
                local planeCoords = GetEntityCoords(plane)
                local distance = #(planeCoords - dropLocation)
                
                while distance > 50.0 and DoesEntityExist(plane) do
                    Wait(1000)
                    planeCoords = GetEntityCoords(plane)
                    distance = #(planeCoords - dropLocation)
                end
                
                if DoesEntityExist(plane) then
                    -- Spawn parachute
                    local parachute = SpawnParachute(dropLocation)
                    if parachute then
                        AnimateParachuteDrop(parachute, dropLocation)
                    end
                    
                    -- Wait for drop animation
                    Wait(Config.DropTime * 1000)
                    
                    -- Spawn crate
                    local crateItem, crateAmount = Config.GetRandomLoot()
                    TriggerServerEvent("sd-airdrop:crate:spawnCrate", dropLocation, crateItem, crateAmount)
                    
                    -- Clean up plane
                    if DoesEntityExist(plane) then
                        DeleteEntity(plane)
                    end
                    
                    -- Update blip to crate
                    if dropBlip then
                        RemoveBlip(dropBlip)
                        dropBlip = nil
                    end
                    CreateCrateBlip(dropLocation)
                end
            end)
        end)
    end)
end)

-- Crate interaction events
RegisterNetEvent("sd-airdrop:crate:applyNatives")
AddEventHandler("sd-airdrop:crate:applyNatives", function(netId)
    local crate = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(crate) then
        SetEntityAsMissionEntity(crate, true, true)
        FreezeEntityPosition(crate, true)
        SetEntityInvincible(crate, true)
    end
end)

RegisterNetEvent("sd-airdrop:crate:createQbTarget")
AddEventHandler("sd-airdrop:crate:createQbTarget", function(netId, crate, item, amount)
    currentCrate = crate
    currentNetId = netId
    
    if not DoesEntityExist(crate) then
        print("[sd-airdrop] Warning: Crate does not exist when creating target")
        return
    end
    
    exports['qb-target']:AddTargetEntity(crate, {
        options = {
            {
                type = "client",
                event = "sd-airdrop:crate:openCrate",
                icon = "fas fa-box-open",
                label = "Open Supply Crate",
                item = item,
                amount = amount,
                netId = netId
            },
        },
        distance = 2.0
    })
end)

RegisterNetEvent("sd-airdrop:crate:openCrate")
AddEventHandler("sd-airdrop:crate:openCrate", function(data)
    if not isInDropZone then
        ShowNotification("You must be in the drop zone to open the crate!", "error")
        return
    end
    
    local playerPed = PlayerPedId()
    local crateCoords = GetEntityCoords(currentCrate)
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - crateCoords)
    
    if distance > 3.0 then
        ShowNotification("You are too far from the crate!", "error")
        return
    end
    
    -- Animation
    RequestAnimDict("anim@gangops@facility@servers@bodysearch@")
    while not HasAnimDictLoaded("anim@gangops@facility@servers@bodysearch@") do
        Wait(100)
    end
    
    TaskPlayAnim(playerPed, "anim@gangops@facility@servers@bodysearch@", "player_search", 8.0, -8.0, 3000, 1, 0, false, false, false)
    
    QBCore.Functions.Progressbar("opening_crate", "Opening supply crate...", 3000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        ClearPedTasks(playerPed)
        TriggerServerEvent("sd-airdrop:server:ItemHandler", 'add', data.item, data.amount)
        TriggerServerEvent('sd-airdrop:crate:deleteCrate', data.netId)
        ShowNotification("You received " .. data.amount .. "x " .. data.item .. "!", "success")
    end, function() -- Cancel
        ClearPedTasks(playerPed)
        ShowNotification("Cancelled!", "error")
    end)
end)

-- Cleanup events
RegisterNetEvent('sd-airdrop:crate:clearcrate')
AddEventHandler('sd-airdrop:crate:clearcrate', function()
    if currentCrate and DoesEntityExist(currentCrate) then
        exports['qb-target']:RemoveTargetEntity(currentCrate)
        DeleteEntity(currentCrate)
    end
    
    if crateBlip then
        RemoveBlip(crateBlip)
        crateBlip = nil
    end
    
    if dropBlip then
        RemoveBlip(dropBlip)
        dropBlip = nil
    end
    
    RemoveDropZone()
    
    currentCrate = nil
    currentNetId = nil
end)

RegisterNetEvent('sd-airdrop:crate:destroyzone')
AddEventHandler('sd-airdrop:crate:destroyzone', function()
    RemoveDropZone()
end)

RegisterNetEvent('dropCoords:client:setPoly')
AddEventHandler('dropCoords:client:setPoly', function(dropCoords)
    CreateDropZone(dropCoords)
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if currentCrate and DoesEntityExist(currentCrate) then
            exports['qb-target']:RemoveTargetEntity(currentCrate)
        end
        
        if crateBlip then
            RemoveBlip(crateBlip)
        end
        
        if dropBlip then
            RemoveBlip(dropBlip)
        end
        
        RemoveDropZone()
    end
end)