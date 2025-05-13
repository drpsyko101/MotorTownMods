local UEHelpers = require("UEHelpers")
local modName = "MotorTownMods"

Webserver = nil ---@class Webserver

require("PlayerLocation")
require("ServerAutoFps")

---Print a message to the console
---@param message string
---@param severity string?
function LogMsg(message, severity)
  if severity then
    severity = severity:upper()
  else
    severity = "INFO"
  end
  print(string.format("[%s] %s: %s\n", modName, severity, message))
end

local function LoadWebserver()
  Webserver = require("Webserver")
  Webserver.run("*", 8080)
end

pcall(LoadWebserver)
LogMsg("Mod loaded")
