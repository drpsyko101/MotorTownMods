local UEHelpers = require("UEHelpers")

local lastLocations = {}

local function ReadPlayerLocations()
  local gameStateBase = UEHelpers:GetGameStateBase()
  local allPlayerStates = gameStateBase.PlayerArray
  LogMsg(string.format("%i player state(s) found", #allPlayerStates))
  for i = 1, #allPlayerStates, 1 do
    local playerState = allPlayerStates[i]
    if playerState:IsValid() and playerState.PawnPrivate:IsValid() then
      local playerName = playerState:GetPlayerName()
      local playerController = playerState:GetPlayerController()
      local pawn = playerController.Pawn
      if pawn:IsValid() then
        local location = pawn:K2_GetActorLocation()
        LogMsg(string.format("Player %s location: {X=%.3f, Y=%.3f, Z=%.3f}", playerName:ToString(),
          location.X,
          location.Y, location.Z))
        lastLocations[playerName] = location
      end
    end
  end
end


RegisterKeyBind(Key.F1, { ModifierKey.CONTROL }, function()
  LogMsg("Getting player(s) location")
  ExecuteInGameThread(function()
    ReadPlayerLocations()
  end)
end)
