local UEHelpers = require("UEHelpers")
local json = require("JsonParser")

---Get all or selected player state(s)
---@param guid string? Filter by character guid
local function GetPlayerStates(guid)
  local gameState = GetMotorTownGameState()
  if not gameState:IsValid() then return '{"data":[]}' end

  local playerStates = gameState.PlayerArray
  
  LogMsg(string.format("%i player state(s) found", #playerStates), "DEBUG")
  local arr = {}
  for i = 1, #playerStates, 1 do
    local playerState = playerStates[i] ---@cast playerState AMotorTownPlayerState

    -- Skip invalid player states
    if not playerState:IsValid() then goto continue end

    -- Filter by guid if provided
    if guid and guid:upper() ~= GuidToString(playerState.CharacterGuid) then goto continue end

    local data = {}
    data.PlayerName = playerState:GetPlayerName():ToString()
    data.GridIndex = playerState.GridIndex
    data.bIsHost = playerState.bIsHost
    data.bIsAdmin = playerState.bIsAdmin
    data.CharacterGuid = GuidToString(playerState.CharacterGuid)
    data.BestLapTime = playerState.BestLapTime
    data.Levels = {}
    for i = 1, #playerState.Levels, 1 do
      table.insert(data.Levels, playerState.Levels[i])
    end
    
    data.OwnCompanyGuid = GuidToString(playerState.OwnCompanyGuid)
    data.JoinedCompanyGuid = GuidToString(playerState.JoinedCompanyGuid)
    data.CustomDestinationAbsoluteLocation = VectorToString(playerState.CustomDestinationAbsoluteLocation)

    data.OwnEventGuids = {}
    for j = 1, #playerState.OwnEventGuids, 1 do
      table.insert(data.OwnEventGuids, GuidToString(playerState.OwnEventGuids[j]))
    end

    data.JoinedEventGuids = {}
    for k = 1, #playerState.JoinedEventGuids, 1 do
      table.insert(data.JoinedEventGuids, GuidToString(playerState.JoinedEventGuids[k]))
    end

    data.Location = VectorToString(playerState.Location)
    data.VehicleKey = playerState.VehicleKey:ToString()

    table.insert(arr, data)

    ::continue::
  end
  return string.format('{"data":%s}', json.stringify(table))
end

RegisterConsoleCommandHandler("getplayerstates", function(Cmd, CommandParts, Ar)
  LogMsg(GetPlayerStates(CommandParts[1]))
  return true
end)

return {
  GetPlayerStates = GetPlayerStates
}
