local UEHelpers = require("UEHelpers")

local modName = "MotorTownMods"

require("PlayerLocation")

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

LogMsg("Mod loaded")
