require("Helpers")

local statics = require("Statics")
local UEHelpers = require("UEHelpers")
local playerManager = require("PlayerManager")
local eventManager = require("EventManager")
local serverManager = require("ServerManager")
local json = require("JsonParser")

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

    -- General server status
    Webserver.registerHandler("/status", "GET", function(session)
      session:sendOKResponse('{"status":"ok"}')
    end)
    Webserver.registerHandler("/status/general", "GET", serverManager.HandleGetServerState)
    Webserver.registerHandler("/status/general/*", "GET", serverManager.HandleGetZoneState)

    -- Player management
    Webserver.registerHandler("/players", "GET", playerManager.HandleGetPlayerStates)
    Webserver.registerHandler("/players/*", "GET", playerManager.HandleGetSpecifcPlayerStates)

    -- Event management
    Webserver.registerHandler("/events", "GET", eventManager.HandleGetAllEvents)
    Webserver.registerHandler("/events/*", "GET", eventManager.HandleGetSpecificEvents)
    Webserver.registerHandler("/events/*", "POST", eventManager.HandleUpdateEventName)

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
