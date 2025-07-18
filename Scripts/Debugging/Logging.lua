local statics = require("Statics")

---@enum (key) LogLevel
local logLevel = {
    ERROR = 0,
    WARN = 1,
    INFO = 2,
    VERBOSE = 3,
    DEBUG = 4
}

---@deprecated Use LogOutput instead to avoid concat errors
---Print a message to the console
---@param message string
---@param severity LogLevel?
local function logMsg(message, severity)
    local lvl = severity or "INFO"
    if logLevel[lvl] > statics.ModLogLevel then return end
    print(string.format("[%s] %s: %s\n", statics.ModName, lvl, message))
end

---Print a message to the console
---Uses the `string.format()` under the hood to parse the message
---@param severity LogLevel
---@param message string|number
---@param ... any
local function logOutput(severity, message, ...)
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

return {
    logMsg = logMsg,
    logOutput = logOutput
}
