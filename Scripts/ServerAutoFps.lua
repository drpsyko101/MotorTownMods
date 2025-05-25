require("UEHelpers")
require("Helpers")

-- Amount of poll per minute.
-- Change this value to increase/decrease median accuracy
local pollPerMin = 30
local serverFps = {} ---@type number[]

local function GetServerFps()
    local gameState = GetMotorTownGameState()
    if (gameState:IsValid()) then
        local fps = gameState.Net_HotState.FPS ---@cast fps number
        table.insert(serverFps, fps)
        if (#serverFps > pollPerMin) then
            table.remove(serverFps, 1)
        end
        table.sort(serverFps, function(a, b)
            return a > b
        end)
        local medianIdx = math.ceil(#serverFps / 2)
        local medianFps = serverFps[medianIdx]
        return medianFps
    end
    return -1
end

local npcAmount = 100
---Change the current traffic density
---@param amount number New density in %
local function AdjustTrafficDensity(amount)
    if amount ~= npcAmount then
        LogMsg("Changing traffic amount from " .. npcAmount .. "% to " .. amount .. "%")
        npcAmount = amount
    end
    local gameState = GetMotorTownGameState()
    if (gameState:IsValid() and gameState.AIVehicleSpawnSystem:IsValid()) then
        local settings = gameState.AIVehicleSpawnSystem.SpawnSettings
        local densities = {
            Small = { MinAmount = -1, MaxAmount = 250 },
            Special = { MinAmount = -1, MaxAmount = 5 },
            Truck = { MinAmount = -1, MaxAmount = 50 },
            Bus = { MinAmount = -1, MaxAmount = 50 },
            -- Police = { MinAmount = -1, MaxAmount = 1 },
            -- Tow_Ld = { MinAmount = 1, MaxAmount = 2 },
            -- Tow = { MinAmount = 3, MaxAmount = 6 },
            -- Tow_Heavy = { MinAmount = 1, MaxAmount = 2 },
            -- Rescue = { MinAmount = 3, MaxAmount = 4 },
            -- HeavyRescue = { MinAmount = 3, MaxAmount = 5 },
            -- VehicleDelivery = { MinAmount = 4, MaxAmount = 8 },
            -- VehicleDeliveryHeavy = { MinAmount = 5, MaxAmount = 8 },
            -- Getaway = { MinAmount = -1, MaxAmount = 1 },
        }
        for i = 1, #settings, 1 do
            local setting = settings[1] ---@cast setting FMTAIVehicleSpawnSetting
            local density = densities[setting.SettingKey]
            if density then
                setting.bUseNPCVehicleDensity = false
                setting.MaxCount = density.MaxAmount * amount / 100
            end
        end
    end
end

local function AutoAdjustServerCaps()
    local gameState = GetMotorTownGameState()
    if not gameState:IsValid() then
        LogMsg("invalid GameState")
        return false
    end

    local currentFps = GetServerFps()
    if (currentFps <= 0) then
        return
    elseif (currentFps < 30) then
        gameState.Net_ServerConfig.MaxVehiclePerPlayer = 5
        AdjustTrafficDensity(0)
    elseif (currentFps < 40) then
        gameState.Net_ServerConfig.MaxVehiclePerPlayer = 7
        AdjustTrafficDensity(30)
    else
        gameState.Net_ServerConfig.MaxVehiclePerPlayer = 10
        AdjustTrafficDensity(75)
    end
    return false
end

if os.getenv("MOD_ENABLE_AUTO_FPS") then
    LoopAsync(60 * 1000 / pollPerMin, AutoAdjustServerCaps)
end
