local json = require("JsonParser")
local UEHelpers = require("UEHelpers")
local statics = require("Statics")

local maxVehiclePerPlayer = 10
local npcVehicleDensity = 1.0

local serverConfig = ReadFileAsString("../../../DedicatedServerConfig.json")
if serverConfig then
    local config = json.parse(serverConfig)
    if config then
        maxVehiclePerPlayer = config.MaxVehiclePerPlayer or maxVehiclePerPlayer
        npcVehicleDensity = config.NPCVehicleDensity or npcVehicleDensity
    end
end

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
        LogOutput("INFO", "Changing traffic amount from %.1f%% to %.1f%%", npcAmount, amount)
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
                setting.MaxCount = density.MaxAmount * amount
            end
        end
    end
end

---Automatically adjust server caps
---@param override boolean?
---@return boolean
local function AutoAdjustServerCaps(override)
    local gameState = GetMotorTownGameState()
    if not gameState:IsValid() then
        return false
    end

    local currentFps = 60
    if not override then
        currentFps = GetServerFps()
    end

    if (currentFps <= 0) then
        LogOutput("DEBUG", "Invalid FPS, not changing anything")
        return false
    elseif (currentFps < 30) then
        local newLimit = math.floor(maxVehiclePerPlayer / 2)
        LogOutput("DEBUG", "Server FPS lower than 30 FPS, setting maxVehiclePerPlayer to %i", newLimit)
        gameState.Net_ServerConfig.MaxVehiclePerPlayer = newLimit
        AdjustTrafficDensity(0)
    elseif (currentFps < 40) then
        local newLimit = math.floor(maxVehiclePerPlayer / 0.75)
        LogOutput("DEBUG", "Server FPS lower than 40 FPS, setting maxVehiclePerPlayer to %i", newLimit)
        gameState.Net_ServerConfig.MaxVehiclePerPlayer = newLimit
        AdjustTrafficDensity(math.floor(npcVehicleDensity / 2))
    else
        LogOutput("DEBUG", "Server FPS at 60 FPS or in override mode, setting maxVehiclePerPlayer to %i",
            maxVehiclePerPlayer)
        gameState.Net_ServerConfig.MaxVehiclePerPlayer = maxVehiclePerPlayer
        AdjustTrafficDensity(npcVehicleDensity)
    end
    return true
end

if os.getenv("MOD_AUTO_FPS_ENABLE") then
    LoopAsync(60 * 1000 / pollPerMin, function()
        AutoAdjustServerCaps()
        return false
    end)
end

-- Register console commands

RegisterConsoleCommandHandler("getserverstate", function(Cmd, CommandParts, Ar)
    LogOutput("INFO", json.stringify(GetServerState()))
    return true
end)

RegisterConsoleCommandHandler("setnpctraffic", function(Cmd, CommandParts, Ar)
    local density = tonumber(CommandParts[1]) or 1.0
    npcVehicleDensity = density
    AutoAdjustServerCaps(true)
    LogOutput("INFO", "Set NPC traffic density to %.1f", density * 100)
    return true
end)

-- HTTP request handlers

---Handle the get server state commands
---@type RequestPathHandler
local function HandleGetServerState(session)
    local serverStatus = json.stringify {
        data = GetServerState()
    }
    return serverStatus
end

---Handle the get zone state commands
---@type RequestPathHandler
local function HandleGetZoneState(session)
    local zoneName = session.pathComponents[3]
    if zoneName then
        local serverStatus = json.stringify {
            data = GetZoneState(zoneName)
        }
        return serverStatus
    end
    return nil, nil, 400
end

---Handle NPC traffic density update request
---@type RequestPathHandler
local function HandleUpdateNpcTraffic(session)
    local body = json.parse(session.content)
    if body then
        local density = tonumber(body.NPCVehicleDensity)
        if density then
            npcVehicleDensity = density
        end
        local maxV = tonumber(body.MaxVehiclePerPlayer)
        if maxV then
            maxVehiclePerPlayer = maxV
        end
        AutoAdjustServerCaps(true)
        return json.stringify { status = "ok" }
    end
    return nil, nil, 400
end

---Handle request to execute command on the server
---@type RequestPathHandler
local function HandleServerExecCommand(session)
    local data = json.parse(session.content)

    if data and data.Command then
        local world = UEHelpers.GetWorld()
        if world:IsValid() then
            local PC = data.PlayerId and GetPlayerControllerFromUniqueId(data.PlayerId) or nil
            UEHelpers.GetKismetSystemLibrary():ExecuteConsoleCommand(world, data.Command, PC)
            return json.stringify { status = "ok" }, nil, 201
        end
    end
    return json.stringify { error = "Invalid payload" }, nil, 400
end

---Handle get server status
---@type RequestPathHandler
local function HandleGetServerStatus(session)
    local gameState = GetMotorTownGameState()
    if not gameState:IsValid() then
        -- Game state is not created yet
        return json.stringify { status = "not ready" }, nil, 503
    end
    return json.stringify { status = "ok" }
end

---Handle get mod version
---@type RequestPathHandler
local function HandleGetModVersion(session)
    return json.stringify { version = statics.ModVersion }
end

return {
    HandleGetServerState = HandleGetServerState,
    HandleGetZoneState = HandleGetZoneState,
    HandleUpdateNpcTraffic = HandleUpdateNpcTraffic,
    HandleServerExecCommand = HandleServerExecCommand,
    HandleGetServerStatus = HandleGetServerStatus,
    HandleGetModVersion = HandleGetModVersion,
}
