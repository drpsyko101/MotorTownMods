local UEHelpers = require("UEHelpers")
local modName = "MotorTownMods"

-- require("PlayerLocation")

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
  local status, err = pcall(function()
    Webserver = require("Webserver")
    Webserver.registerHandler("/status", "GET", function(session)
      Webserver.sendOKResponse(session, '{"status":"ok"}', "application/json")
    end)
    Webserver.run("*", 5001)
  end)
  if err then
    LogMsg("Failed to start webserver: error code " .. err.code, "ERROR")
  end
  return not status
end

LoopAsync(5000, LoadWebserver)
LogMsg("Mod loaded")
