require("Helpers")

local UEHelpers = require("UEHelpers")
local playerManager = require("PlayerManager")
local eventManager = require("EventManager")
local json = require("JsonParser")

local modName = "MotorTownMods"
local modLogLevel = 2

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
  if logLevel[lvl] > modLogLevel then return end
  print(string.format("[%s] %s: %s\n", modName, lvl, message))
end

local function LoadWebserver()
  local status, err = pcall(function()
    Webserver = require("Webserver")

    -- General server status
    Webserver.registerHandler("/status", "GET", function(session)
      Webserver.sendOKResponse(session, '{"status":"ok"}', "application/json")
    end)

    -- Player management
    Webserver.registerHandler("/players", "GET", function(session)
      Webserver.sendOKResponse(session, playerManager.GetPlayerStates(), "application/json")
    end)
    Webserver.registerHandler("/players/*", "GET", function(session)
      local playerGuid = session.pathComponents[2]
      Webserver.sendOKResponse(session, playerManager.GetPlayerStates(playerGuid), "application/json")
    end)

    -- Event management
    Webserver.registerHandler("/events", "GET", function(session)
      Webserver.sendOKResponse(session, eventManager.GetEvents(), "application/json")
    end)
    Webserver.registerHandler("/events/*", "GET", function(session)
      local eventGuid = session.pathComponents[2]
      Webserver.sendOKResponse(session, eventManager.GetEvents(eventGuid), "application/json")
    end)
    Webserver.registerHandler("/events/*", "POST", function(session)
      local eventGuid = session.pathComponents[2]
      local content = json.parse(session.content)
      local eventName = content.EventName or nil
      if eventName and eventManager.UpdateEventName(eventGuid, eventName) then
        Webserver.sendOKResponse(session, eventManager.GetEvents(eventGuid), "application/json")
      else
        Webserver.sendErrorResponse(session, 404, "Event not found")
      end
    end)

    local port = os.getenv("MOD_LUA_PORT") or "5001"
    Webserver.run("*", tonumber(port))
    return nil
  end)
  if err then
    LogMsg("Unexpected error has occured in Webserver", "ERROR")
    return true
  end
  return false
end

LoopAsync(5000, LoadWebserver)
LogMsg("Mod loaded")
