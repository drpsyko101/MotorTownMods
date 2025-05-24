require("Helpers")

local UEHelpers = require("UEHelpers")
local playerManager = require("PlayerManager")

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

    Webserver.registerHandler("/status", "GET", function(session)
      Webserver.sendOKResponse(session, '{"status":"ok"}', "application/json")
    end)

    Webserver.registerHandler("/players", "GET", function(session)
      Webserver.sendOKResponse(session, playerManager.GetPlayerStates(), "application/json")
    end)

    local port = os.getenv("LUA_MOD_PORT") or "5001"
    Webserver.run("*", tonumber(port))
    return nil
  end)
  if err then
    LogMsg("Failed to start webserver", "ERROR")
  end
  return false
end

LoopAsync(5000, LoadWebserver)
LogMsg("Mod loaded")
