require("Helpers")

local statics = require("Statics")
local playerManager = require("PlayerManager")
local eventManager = require("EventManager")
local serverManager = require("ServerManager")
local cargoManager = require("CargoManager")
local chatManager = require("ChatManager")

---@enum (key) LogLevel
local logLevel = {
  ERROR = 0,
  WARN = 1,
  INFO = 2,
  DEBUG = 3
}

---@deprecated Use LogOutput instead to avoid concat errors
---Print a message to the console
---@param message string
---@param severity LogLevel?
function LogMsg(message, severity)
  local lvl = severity or "INFO"
  if logLevel[lvl] > statics.ModLogLevel then return end
  print(string.format("[%s] %s: %s\n", statics.ModName, lvl, message))
end

---Print a message to the console
---Uses the `string.format()` under the hood to parse the message
---@param severity LogLevel
---@param message string|number
---@param ... any
function LogOutput(severity, message, ...)
  local args = { ... }
  if logLevel[severity] <= statics.ModLogLevel then
    local status, err = pcall(function()
      local msg = string.format(message, table.unpack(args))
      local outMsg = string.format("[%s] %s: %s\n", statics.ModName, severity, msg)
      if logLevel[severity] == 0 then
        outMsg = outMsg .. debug.traceback() .. "\n"
      end
      print(outMsg)
    end)
    if not status then
      print(string.format("[%s] WARN: LogOutput error while parsing: %s: %s\n%s\n", statics.ModName, message, err,
      debug.traceback()))
    end
  end
end

local function LoadWebserver()
  local status, err = pcall(function()
    Webserver = require("Webserver")

    -- Local imports are placed here due to socket dependency

    local propertyManager = require("PropertyManager")
    local vehicleManager = require("VehicleManager")
    local assetManager = require("AssetManager")

    -- Note that the ordering of the path registration matters.
    -- Put more specific paths before more general ones

    -- General server status
    Webserver.registerHandler(
      "/status",
      "GET",
      function(session)
        local gameState = GetMotorTownGameState()
        if not gameState:IsValid() then
          -- Game state is not created yet
          return '{"status":"not ready"}', nil, 503
        end
        return '{"status":"ok"}'
      end,
      false
    )
    Webserver.registerHandler("/status/general", "GET", serverManager.HandleGetServerState)
    Webserver.registerHandler("/status/general/*", "GET", serverManager.HandleGetZoneState)
    Webserver.registerHandler("/status/traffic", "POST", serverManager.HandleUpdateNpcTraffic)

    -- Player management
    Webserver.registerHandler("/players", "GET", playerManager.HandleGetPlayerStates)
    Webserver.registerHandler("/players/*", "GET", playerManager.HandleGetPlayerStates)

    -- Event management
    Webserver.registerHandler("/events", "GET", eventManager.HandleGetEvents)
    Webserver.registerHandler("/events", "POST", eventManager.HandleCreateNewEvent)
    Webserver.registerHandler("/events/*", "GET", eventManager.HandleGetEvents)
    Webserver.registerHandler("/events/*/state", "POST", eventManager.HandleChangeEventState)
    Webserver.registerHandler("/events/*", "POST", eventManager.HandleUpdateEvent)
    Webserver.registerHandler("/events/*", "DELETE", eventManager.HandleRemoveEvent)

    -- Properties management
    Webserver.registerHandler("/houses", "GET", propertyManager.HandleGetAllHouses)
    Webserver.registerHandler("/houses/spawn", "POST", propertyManager.HandleSpawnHouse)

    -- Cargo management
    Webserver.registerHandler("/delivery/points", "GET", cargoManager.HandleGetDeliveryPoints)
    Webserver.registerHandler("/delivery/points/*", "GET", cargoManager.HandleGetDeliveryPoints)

    -- Vehicle management
    Webserver.registerHandler("/vehicles", "GET", vehicleManager.HandleGetVehicles)
    Webserver.registerHandler("/vehicles/*/despawn", "POST", vehicleManager.HandleDespawnVehicle)
    Webserver.registerHandler("/vehicles/*", "GET", vehicleManager.HandleGetVehicles)
    Webserver.registerHandler("/dealers/spawn", "POST", vehicleManager.HandleCreateVehicleDealerSpawnPoint)
    Webserver.registerHandler("/garages", "GET", vehicleManager.HandleGetGarages)
    Webserver.registerHandler("/garages/spawn", "POST", vehicleManager.HandleGetGarages)

    -- Asset management
    Webserver.registerHandler("/assets/spawn", "POST", assetManager.HandleSpawnActor)
    Webserver.registerHandler("/assets/despawn", "POST", assetManager.HandleDespawnActor)

    Webserver.run("*")
    return nil
  end)
  if not status then
    LogOutput("INFO", "Unexpected error has occured in Webserver: %s", err)
  end
end

LoadWebserver()
LogOutput("INFO", "Mod loaded")
