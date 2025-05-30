require("Helpers")

local statics = require("Statics")
local UEHelpers = require("UEHelpers")
local playerManager = require("PlayerManager")
local eventManager = require("EventManager")
local serverManager = require("ServerManager")
local propertyManager = require("PropertyManager")
local cargoManager = require("CargoManager")

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
    Webserver.registerHandler("/status", "GET", function(session)
      return '{"status":"ok"}'
    end)
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

    local port = os.getenv("MOD_LUA_PORT") or "5001"
    Webserver.run("*", tonumber(port))
    return nil
  end)
  if err then
    LogMsg("Unexpected error has occured in Webserver: " .. err, "ERROR")
    return true
  end
  return false
end

LoopAsync(5000, LoadWebserver)
LogMsg("Mod loaded")
