require("Helpers")

local statics = require("Statics")
local UEHelpers = require("UEHelpers")
local playerManager = require("PlayerManager")
local eventManager = require("EventManager")
local serverManager = require("ServerManager")
local propertyManager = require("PropertyManager")
local cargoManager = require("CargoManager")
local chatManager = require("ChatManager")
local vehicleManager = require("VehicleManager")
local assetManager = require("AssetManager")

---@enum (key) LogLevel
local logLevel = {
  ERROR = 0,
  WARN = 1,
  INFO = 2,
  DEBUG = 3
}

---Print a message to the console
---@param message string
---@param severity LogLevel?
function LogMsg(message, severity)
  local lvl = severity or "INFO"
  if logLevel[lvl] > statics.ModLogLevel then return end
  print(string.format("[%s] %s: %s\n", statics.ModName, lvl, message))
end

local function LoadWebserver()
  local status, err = pcall(function()
    Webserver = require("Webserver")

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
    Webserver.registerHandler("/players/*", "GET", playerManager.HandleGetSpecifcPlayerStates)

    -- Event management
    Webserver.registerHandler("/events", "GET", eventManager.HandleGetAllEvents)
    Webserver.registerHandler("/events", "POST", eventManager.HandleCreateNewEvent)
    Webserver.registerHandler("/events/*", "GET", eventManager.HandleGetSpecificEvents)
    Webserver.registerHandler("/events/*/state", "POST", eventManager.HandleChangeEventState)
    Webserver.registerHandler("/events/*", "POST", eventManager.HandleUpdateEvent)
    Webserver.registerHandler("/events/*", "DELETE", eventManager.HandleRemoveEvent)

    -- Properties management
    Webserver.registerHandler("/houses", "GET", propertyManager.HandleGetAllHouses)

    -- Cargo management
    Webserver.registerHandler("/delivery/points", "GET", cargoManager.HandleGetDeliveryPoints)
    Webserver.registerHandler("/delivery/points/*", "GET", cargoManager.HandleGetDeliveryPoints)

    -- Vehicle management
    Webserver.registerHandler("/vehicles", "GET", vehicleManager.HandleGetVehicles)
    Webserver.registerHandler("/vehicles/*/despawn", "POST", vehicleManager.HandleDespawnVehicle)
    Webserver.registerHandler("/vehicles/*", "GET", vehicleManager.HandleGetVehicles)

    -- Asset management
    Webserver.registerHandler("/assets/spawn", "POST", assetManager.HandleSpawnActor)
    Webserver.registerHandler("/assets/despawn", "POST", assetManager.HandleDespawnActor)

    Webserver.run("*")
    return nil
  end)
  if not status then
    LogMsg("Unexpected error has occured in Webserver: " .. err, "ERROR")
  end
end

ExecuteAsync(LoadWebserver)
LogMsg("Mod loaded")
