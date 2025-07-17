require("Helpers")
local statics = require("Statics")
local json = require("JsonParser")
local outputLogLevel = tonumber(os.getenv("MOD_SERVER_LOG_LEVEL")) or 2

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
  if logLevel[lvl] > outputLogLevel then return end
  print(string.format("[%s] %s: %s\n", statics.ModName, lvl, message))
end

---Print a message to the console
---Uses the `string.format()` under the hood to parse the message
---@param severity LogLevel
---@param message string|number
---@param ... any
function LogOutput(severity, message, ...)
  local args = { ... }
  if logLevel[severity] <= outputLogLevel then
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

local playerManager = require("PlayerManager")
local eventManager = require("EventManager")
local serverManager = require("ServerManager")
local cargoManager = require("CargoManager")
local chatManager = require("ChatManager")
local widgetManager = require("ViewportManager")

local function LoadWebserver()
  local status, err = pcall(function()
    local server = require("Webserver")

    -- Local imports are placed here due to socket dependency

    local propertyManager = require("PropertyManager")
    local vehicleManager = require("VehicleManager")
    local assetManager = require("AssetManager")

    -- Note that the ordering of the path registration matters.
    -- Put more specific paths before more general ones

    -- General server status
    server.registerHandler(
      "/status",
      "GET",
      function(session)
        local gameState = GetMotorTownGameState()
        if not gameState:IsValid() then
          -- Game state is not created yet
          return json.stringify { status = "not ready" }, nil, 503
        end
        return json.stringify { status = "ok" }
      end,
      false
    )
    server.registerHandler("/status/general", "GET", serverManager.HandleGetServerState)
    server.registerHandler("/status/general/*", "GET", serverManager.HandleGetZoneState)
    server.registerHandler("/status/traffic", "POST", serverManager.HandleUpdateNpcTraffic)

    -- Player management
    server.registerHandler("/players", "GET", playerManager.HandleGetPlayerStates)
    server.registerHandler("/players/*", "GET", playerManager.HandleGetPlayerStates)

    -- Event management
    server.registerHandler("/events", "GET", eventManager.HandleGetEvents)
    server.registerHandler("/events", "POST", eventManager.HandleCreateNewEvent)
    server.registerHandler("/events/*", "GET", eventManager.HandleGetEvents)
    server.registerHandler("/events/*/state", "POST", eventManager.HandleChangeEventState)
    server.registerHandler("/events/*", "POST", eventManager.HandleUpdateEvent)
    server.registerHandler("/events/*", "DELETE", eventManager.HandleRemoveEvent)

    -- Properties management
    server.registerHandler("/houses", "GET", propertyManager.HandleGetAllHouses)
    server.registerHandler("/houses/spawn", "POST", propertyManager.HandleSpawnHouse)

    -- Cargo management
    server.registerHandler("/delivery/points", "GET", cargoManager.HandleGetDeliveryPoints)
    server.registerHandler("/delivery/points/*", "GET", cargoManager.HandleGetDeliveryPoints)

    -- Vehicle management
    server.registerHandler("/vehicles", "GET", vehicleManager.HandleGetVehicles)
    server.registerHandler("/vehicles/*/despawn", "POST", vehicleManager.HandleDespawnVehicle)
    server.registerHandler("/vehicles/*", "GET", vehicleManager.HandleGetVehicles)
    server.registerHandler("/dealers/spawn", "POST", vehicleManager.HandleCreateVehicleDealerSpawnPoint)
    server.registerHandler("/garages", "GET", vehicleManager.HandleGetGarages)
    server.registerHandler("/garages/spawn", "POST", vehicleManager.HandleGetGarages)

    -- Asset management
    server.registerHandler("/assets/spawn", "POST", assetManager.HandleSpawnActor)
    server.registerHandler("/assets/despawn", "POST", assetManager.HandleDespawnActor)

    -- UI management
    server.registerHandler("/messages/popup", "POST", widgetManager.HandleShowPopupMessage)

    server.run("*")
    return nil
  end)
  if not status then
    LogOutput("INFO", "Unexpected error has occured in Webserver: %s", err)
  end
end

LoadWebserver()
LogOutput("INFO", "Mod loaded")
