local UEHelpers = require("UEHelpers")

local function ReadPlayerLocations(s)
  local playerStates = UEHelpers:GetAllPlayerStates()
  local lastLocations = {}
  LogMsg(string.format("%i player state(s) found", #playerStates))
  for i = 1, #playerStates, 1 do
    local playerState = playerStates[i] ---@cast playerState AMotorTownPlayerState
    if playerState:IsValid() then
      local playerName = playerState:GetPlayerName()
      local location = playerState.Location
      LogMsg(string.format("PlayerPawn %s location: {X=%.3f, Y=%.3f, Z=%.3f}", playerName:ToString(),
        location.X,
        location.Y, location.Z))
      lastLocations[playerName] = location
    end
  end

  local res = '{"data":[]}'

  pcall(function()
    local json = require("cjson")
    res = json.encode(lastLocations)
  end)

  pcall(function()
    local Webserver = require("Webserver")
    Webserver.sendOKResponse(s, res, "application/json")
  end)
  return LogMsg(res)
end

pcall(function()
  local Webserver = require("Webserver")
  Webserver.registerHandler("/getallplayerlocations", "GET", ReadPlayerLocations)
end)

RegisterConsoleCommandHandler("getallplayerlocations", ReadPlayerLocations)
