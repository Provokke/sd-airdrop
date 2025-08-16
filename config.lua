Config = {}

-- Core Settings
Config.CoreName = 'qb-core' -- Name of your QB-Core resource
Config.Debug = false -- Enable debug mode for polyzone visualization

-- Police Settings
Config.MinCops = 2 -- Minimum number of police required online
Config.PoliceJobs = {'police', 'bcso', 'sasp'} -- Police job names

-- Cooldown Settings
Config.Cooldown = 30 -- Cooldown time in minutes between airdrops

-- Drop Zone Settings
Config.DropZoneRadius = 100.0 -- Radius of the drop zone in meters

-- Aircraft Settings
Config.PlaneModel = 'titan' -- Model name of the plane
Config.PlaneSpeed = 50.0 -- Speed of the plane
Config.PlaneHeight = 200.0 -- Height of the plane above ground
Config.PlaneSpawnDistance = 1000.0 -- Distance from drop location to spawn plane

-- Parachute Settings
Config.ParachuteModel = 'p_parachute1_s' -- Model name of the parachute
Config.DropTime = 15 -- Time in seconds for the crate to drop

-- Crate Settings
Config.CrateModel = 'prop_box_wood02a_pu' -- Model name of the supply crate

-- Drop Locations
Config.DropLocations = {
    vector3(2558.46, 382.04, 108.62), -- Vinewood Hills
    vector3(-1037.64, -2737.73, 20.17), -- Airport
    vector3(1729.21, 3310.47, 41.22), -- Sandy Shores
    vector3(-585.46, 5252.84, 70.47), -- Paleto Bay
    vector3(2441.81, 4968.61, 51.70), -- Mount Chiliad
    vector3(-1308.42, -394.56, 36.70), -- Del Perro
    vector3(1964.63, 3740.83, 32.34), -- Sandy Shores Airfield
    vector3(-3240.43, 1008.42, 12.83), -- Chumash
    vector3(1686.20, 4829.31, 42.05), -- Grapeseed
    vector3(-1982.29, 630.22, 122.54), -- Richman
    vector3(2126.86, 4784.87, 40.97), -- Grand Senora Desert
    vector3(-1119.21, 2698.62, 18.55), -- Zancudo River
    vector3(1392.68, 3606.52, 38.94), -- Grand Senora Desert
    vector3(-2554.43, 2334.09, 33.08), -- Great Ocean Highway
    vector3(1770.12, 2570.21, 45.73), -- Prison Area
}

-- Loot Tables
Config.LootTables = {
    ['goldenphone'] = {
        {item = 'goldbar', amount = {min = 5, max = 15}, chance = 30},
        {item = 'diamond', amount = {min = 3, max = 8}, chance = 25},
        {item = 'rolex', amount = {min = 2, max = 5}, chance = 20},
        {item = 'weapon_pistol', amount = {min = 1, max = 1}, chance = 15},
        {item = 'weapon_smg', amount = {min = 1, max = 1}, chance = 10},
    },
    ['redphone'] = {
        {item = 'weapon_assaultrifle', amount = {min = 1, max = 1}, chance = 25},
        {item = 'weapon_carbinerifle', amount = {min = 1, max = 1}, chance = 20},
        {item = 'weapon_advancedrifle', amount = {min = 1, max = 1}, chance = 15},
        {item = 'rifle_ammo', amount = {min = 100, max = 250}, chance = 20},
        {item = 'armor', amount = {min = 5, max = 10}, chance = 20},
    },
    ['greenphone'] = {
        {item = 'weed_brick', amount = {min = 10, max = 25}, chance = 30},
        {item = 'coke_brick', amount = {min = 5, max = 15}, chance = 25},
        {item = 'meth', amount = {min = 15, max = 30}, chance = 20},
        {item = 'xtcbaggy', amount = {min = 20, max = 40}, chance = 15},
        {item = 'crack_baggy', amount = {min = 25, max = 50}, chance = 10},
    }
}

-- Function to get random loot based on phone type
function Config.GetRandomLoot(phoneType)
    if not phoneType then
        phoneType = 'goldenphone' -- Default fallback
    end
    
    local lootTable = Config.LootTables[phoneType]
    if not lootTable then
        print('[sd-airdrop] Warning: No loot table found for phone type: ' .. tostring(phoneType))
        lootTable = Config.LootTables['goldenphone'] -- Fallback to golden phone loot
    end
    
    local totalChance = 0
    for _, loot in pairs(lootTable) do
        totalChance = totalChance + loot.chance
    end
    
    local randomChance = math.random(1, totalChance)
    local currentChance = 0
    
    for _, loot in pairs(lootTable) do
        currentChance = currentChance + loot.chance
        if randomChance <= currentChance then
            local amount = math.random(loot.amount.min, loot.amount.max)
            return loot.item, amount
        end
    end
    
    -- Fallback if something goes wrong
    local fallbackLoot = lootTable[1]
    local fallbackAmount = math.random(fallbackLoot.amount.min, fallbackLoot.amount.max)
    return fallbackLoot.item, fallbackAmount
end