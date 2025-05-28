local UEHelpers = require("UEHelpers")
local json = require("JsonParser")

require("Helpers")

-- Amount of poll per minute.
-- Change this value to increase/decrease median accuracy
local pollPerMin = 30
local serverFps = {} ---@type number[]

---Convert FMTZoneState to JSON serializable table
---@param zone FMTZoneState
local function ZoneToTable(zone)
    local data = {}

    data.BusTransportRate = zone.BusTransportRate
    data.FoodSupplyRate = zone.FoodSupplyRate
    data.GarbageCollectRate = zone.GarbageCollectRate
    data.PolicePatrolRate = zone.PolicePatrolRate
    data.NumResidents = zone.NumResidents
    data.ZoneKey = zone.ZoneKey:ToString()

    return data
end

---Get current server state
---@return table
local function GetServerState(zoneName)
    local gameState = GetMotorTownGameState()
    local data = {}
    if (gameState:IsValid()) then
        local state = gameState.Net_HotState

        data.FPS = state.FPS
        data.BusTransportRate = state.BusTransportRate
        data.FoodSupplyRate = state.FoodSupplyRate
        data.GarbageCollectRate = state.GarbageCollectRate
        data.NumResidents = state.NumResidents
        data.PolicePatrolRate = state.PolicePatrolRate
        data.ServerPlatformTimeSeconds = state.ServerPlatformTimeSeconds

        local zones = {}
        state.ZoneStates:ForEach(function(index, element)
            local zone = element:get() ---@type FMTZoneState
            table.insert(zones, ZoneToTable(zone))
        end)
        data.ZoneStates = zones
    end
    return data
end

---Get the specified zone state
---@param zoneName string Return only for the specified zone state
---@return table
local function GetZoneState(zoneName)
    local gameState = GetMotorTownGameState()
    if (gameState:IsValid()) then
        local state = gameState.Net_HotState

        for i = 1, #state.ZoneStates, 1 do
            if state.ZoneStates[i].ZoneKey:ToString() == zoneName then
                return ZoneToTable(state.ZoneStates[i])
            end
        end
    end
    return {}
end

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
        LogMsg("invalid GameState", "ERROR")
        return false
    end

    local targetTraffic = tonumber(os.getenv("MOD_AUTO_FPS_TRAFFIC")) or 75
    local targetPlayerVehicle = tonumber(os.getenv("MOD_AUTO_FPS_PLAYER")) or 10

    local currentFps = GetServerFps()
    if (currentFps <= 0) then
        return
    elseif (currentFps < 30) then
        gameState.Net_ServerConfig.MaxVehiclePerPlayer = math.floor(targetPlayerVehicle / 2)
        AdjustTrafficDensity(0)
    elseif (currentFps < 40) then
        gameState.Net_ServerConfig.MaxVehiclePerPlayer = math.floor(targetPlayerVehicle * 0.75)
        AdjustTrafficDensity(math.floor(targetTraffic / 2))
    else
        gameState.Net_ServerConfig.MaxVehiclePerPlayer = targetPlayerVehicle
        AdjustTrafficDensity(targetTraffic)
    end
    return false
end

if os.getenv("MOD_AUTO_FPS_ENABLE") then
    LoopAsync(60 * 1000 / pollPerMin, AutoAdjustServerCaps)
end

RegisterConsoleCommandHandler("getserverstate", function(Cmd, CommandParts, Ar)
    LogMsg(json.stringify(GetServerState()))
    return true
end)

---Handle the getserverstate commands
---@param session ClientTable
local function HandleGetServerState(session)
    local serverStatus = json.stringify {
        data = GetServerState()
    }
    session:sendOKResponse(serverStatus)
end

---Handle the getserverstate commands
---@param session ClientTable
local function HandleGetZoneState(session)
    local zoneName = session.pathComponents[3]
    local serverStatus = json.stringify {
        data = GetZoneState(zoneName)
    }
    session:sendOKResponse(serverStatus)
end

return {
    HandleGetServerState = HandleGetServerState,
    HandleGetZoneState = HandleGetZoneState
}
