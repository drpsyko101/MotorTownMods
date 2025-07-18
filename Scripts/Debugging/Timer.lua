local statics = require("Statics")
local socket = RequireSafe("socket") ---@type Socket?

local enableTImer = statics.ModLogLevel > 2

---@class DebugTimer
---@field initTime number
---@field timers number[]
---@field label string?
local debugTimer = {}
debugTimer.__index = debugTimer

---Create a new timer instance
---@param label string?
local function new(label)
  local obj = setmetatable({}, debugTimer)
  obj.initTime = 0
  obj.label = label or "debugTimer"
  obj.timers = {}
  if enableTImer then
    if socket then
      obj.initTime = socket.gettime()
    else
      obj.initTime = os.clock()
    end
    table.insert(obj.timers, obj.initTime)
  end
  return obj
end

---Get delta time in seconds
---@param checkpoint boolean? Reset the timer for another subsequent delta time
function debugTimer.getDelta(self, checkpoint)
  if enableTImer then
    local delta = 0
    local currentTime = 0
    if socket then
      currentTime = socket.gettime()
      delta = currentTime - self.initTime
    else
      currentTime = os.clock()
      delta = os.difftime(currentTime, self.initTime)
    end
    table.insert(self.timers, currentTime)
    LogOutput("DEBUG", "%s[%i]: %fs", self.label, #self.timers - 1, delta)

    if checkpoint then
      if socket then
        self.initTime = socket.gettime()
      else
        self.initTime = os.clock()
      end
    end
  end
end

---Benchmark a function execution time
---@param func function
---@param ... any
local function benchmark(func, ...)
  local delta = 0
  if enableTImer then
    local initTime = 0
    if socket then
      initTime = socket.gettime()
    else
      initTime = os.clock()
    end
    local results = { func(...) }
    if socket then
      delta = socket.gettime() - initTime
    else
      delta = os.difftime(os.clock(), initTime)
    end
    return delta, table.unpack(results)
  else
    return delta, func(...)
  end
end

return {
  new = new,
  benchmark = benchmark
}
