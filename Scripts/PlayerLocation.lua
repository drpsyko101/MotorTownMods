local UEHelpers = require("UEHelpers")

local lastLocations = {}

local function ReadPlayerLocations()
  local playerStates = UEHelpers:GetAllPlayerStates()
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
end


RegisterKeyBind(Key.F1, { ModifierKey.CONTROL }, function()
  LogMsg("Getting player(s) location")
  ExecuteInGameThread(function()
    ReadPlayerLocations()
  end)
end)
