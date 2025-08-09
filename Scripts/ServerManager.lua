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

---Get current server state
---@param zoneName string?
---@param depth integer?
---@return table
local function GetServerState(zoneName, depth)
    local gameState = GetMotorTownGameState()
    local data = {}
    if (gameState:IsValid()) then
        local field = "Net_HotState"
        data = GetObjectAsTable(gameState, field, nil, depth)[field] or {}
        if zoneName and data.ZoneStates then
            for _, value in ipairs(data.ZoneStates) do
                if value.ZoneKey == zoneName then
                    return value
                end
            end
            return {}
        end
    end
    return data
end

-- We don't know the initial npcAmount since `FMTDediConfig` isn't exposed
---@type integer?
local npcAmount = nil
-- These are the default density value for each type of vehicles
---@type table<string, {MinAmount: integer, MaxAmount: integer}>
local densities = {
    Small = { MinAmount = -1, MaxAmount = 250 },
    Special = { MinAmount = -1, MaxAmount = 5 },
    Truck = { MinAmount = -1, MaxAmount = 50 },
    Bus = { MinAmount = -1, MaxAmount = 50 },
    Police = { MinAmount = -1, MaxAmount = 1 },
    Tow_Ld = { MinAmount = 1, MaxAmount = 2 },
    Tow = { MinAmount = 3, MaxAmount = 6 },
    Tow_Heavy = { MinAmount = 1, MaxAmount = 2 },
    Rescue = { MinAmount = 3, MaxAmount = 4 },
    HeavyRescue = { MinAmount = 3, MaxAmount = 5 },
    VehicleDelivery = { MinAmount = 4, MaxAmount = 8 },
    VehicleDeliveryHeavy = { MinAmount = 5, MaxAmount = 8 },
    Getaway = { MinAmount = -1, MaxAmount = 1 },
}
---Change the current traffic density
---@param vehicleTypes string[] Vehicle types to modify
---@param amount number New density in %
local function AdjustTrafficDensity(vehicleTypes, amount)
    if amount ~= npcAmount then
        if npcAmount then
            LogOutput("INFO", "Changing traffic amount from %.1f%% to %.1f%%", npcAmount, amount)
        else
            LogOutput("INFO", "Changing traffic amount to %.1f%%", amount)
        end
        npcAmount = amount
    end
    local gameState = GetMotorTownGameState()
    if (gameState:IsValid() and gameState.AIVehicleSpawnSystem:IsValid()) then
        local settings = gameState.AIVehicleSpawnSystem.SpawnSettings
        local hasAll = ListContains(vehicleTypes, "all")
        for i = 1, #settings do
            local type = settings[i].SettingKey:ToString()

            local density = densities[type]
            if density and (ListContains(vehicleTypes, type) or hasAll) then
                settings[i].bUseNPCVehicleDensity = false
                settings[i].bUseNPCVehicleDensity = false
                local newAmount = math.floor(density.MaxAmount * amount)
                settings[i].MaxCount = newAmount

                -- If max amount drops below min, adjust min
                if newAmount < settings[i].MinCount then
                    settings[i].MinCount = newAmount
                end

                -- restore min value if more than threshold
                if newAmount > density.MinAmount then
                    settings[i].MinCount = density.MinAmount
                end
            end
        end
    end
end

-- Register console commands

RegisterConsoleCommandHandler("getserverstate", function(Cmd, CommandParts, Ar)
    local data = GetServerState()
    LogOutput("INFO", "%s: %s", Cmd, json.stringify(data))
    return true
end)

RegisterConsoleCommandHandler("setnpctraffic", function(Cmd, CommandParts, Ar)
    local types = SplitString(CommandParts[1]) or { "Small", "Special", "Truck", "Bus" }
    local density = tonumber(CommandParts[2]) or 1.0
    AdjustTrafficDensity(types, density)
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
    local depth = tonumber(session.queryComponents.depth)

    if zoneName then
        return json.stringify { data = GetServerState(zoneName, depth) }
    end
    return nil, nil, 400
end

---Handle get current traffic setting request
---@type RequestPathHandler
local function HandleGetNpcTraffic(session)
    local gameState = GetMotorTownGameState()
    if gameState:IsValid() then
        return json.stringify { data = GetObjectAsTable(gameState.AIVehicleSpawnSystem) }
    end
    return nil, nil, 400
end

---Handle NPC traffic density update request
---@type RequestPathHandler
local function HandleUpdateNpcTraffic(session)
    local body = json.parse(session.content)
    if body then
        local density = tonumber(body.NPCVehicleDensity)
        ---@type string[]
        local vehicleTypes = body.VehicleTypes or { "Small", "Special", "Truck", "Bus" }
        if density then
            AdjustTrafficDensity(vehicleTypes, density)
            return json.stringify { status = "ok" }
        end
    end
    return nil, nil, 400
end

---Handle request to set a new player maximum spawnable vehicles
---@type RequestPathHandler
local function HandleSetPlayerMaxVehicles(session)
    local body = json.parse(session.content)
    if body then
        local limit = tonumber(body.MaxVehiclePerPlayer)
        if limit then
            local gameState = GetMotorTownGameState()
            if gameState:IsValid() then
                gameState.Net_ServerConfig.MaxVehiclePerPlayer = limit
                return json.stringify { status = "ok" }, nil, 200
            end
        end
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

---Handle request to change server settings
---@type RequestPathHandler
local function HandleSetServerSettings(session)
    local data = json.parse(session.content)
    if data then
        local gameState = GetMotorTownGameState()
        if gameState:IsValid() then
            local liveConfig = gameState.Net_ServerConfig

            -- Adjust max player vehicle spawn limit
            local limit = tonumber(data.MaxVehiclePerPlayer)
            if limit then
                liveConfig.MaxVehiclePerPlayer = limit
            end

            -- Set to allow use of modded vehicles
            if data.bAllowModdedVehicle and type(data.bAllowModdedVehicle) == "boolean" then
                liveConfig.bAllowModdedVehicle = data.bAllowModdedVehicle
            end

            -- Adjust max house rental duration
            local rentalDays = tonumber(data.MaxHousingPlotRentalDays)
            if rentalDays then
                liveConfig.MaxHousingPlotRentalDays = rentalDays
            end

            -- Set the max plot a player can have at a given time
            local rentalPlots = tonumber(data.MaxHousingPlotRentalPerPlayer)
            if rentalPlots then
                liveConfig.MaxHousingPlotRentalPerPlayer = rentalPlots
            end

            -- Change server message for newly logged in player
            if data.ServerMessage and type(data.ServerMessage) == "string" then
                liveConfig.ServerMessage = data.ServerMessage
            end

            -- Set the rental rate per days
            local rentalRate = tonumber(data.HousingPlotRentalPriceRatio)
            if rentalRate then
                liveConfig.HousingPlotRentalPriceRatio = rentalRate
            end

            -- Allow AI driver in company
            if data.bAllowCompanyAIDriver and type(data.bAllowCompanyAIDriver) == "boolean" then
                liveConfig.bAllowCompanyAIDriver = data.bAllowCompanyAIDriver
            end

            -- return current server config
            local field = "Net_ServerConfig"
            local config = GetObjectAsTable(gameState, field)[field] or {}
            return json.stringify { data = config }
        end
    end
    return json.stringify { error = "Invalid payload" }, nil, 400
end

return {
    HandleGetServerState = HandleGetServerState,
    HandleGetZoneState = HandleGetZoneState,
    HandleGetNpcTraffic = HandleGetNpcTraffic,
    HandleUpdateNpcTraffic = HandleUpdateNpcTraffic,
    HandleServerExecCommand = HandleServerExecCommand,
    HandleGetServerStatus = HandleGetServerStatus,
    HandleSetServerSettings = HandleSetServerSettings,
}
