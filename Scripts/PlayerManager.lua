local UEHelpers = require("UEHelpers")

local function GetPlayerStates()
  local playerStates = UEHelpers:GetAllPlayerStates()
  LogMsg(string.format("%i player state(s) found", #playerStates), "DEBUG")
  local arr = {}
  for i = 1, #playerStates, 1 do
    local data = {}
    local playerState = playerStates[i] ---@cast playerState AMotorTownPlayerState
    if playerState:IsValid() then
      data.PlayerName = playerState:GetPlayerName():ToString()
      data.GridIndex = playerState.GridIndex
      data.bIsHost = playerState.bIsHost
      data.bIsAdmin = playerState.bIsAdmin
      data.CharacterGuid = GuidToString(playerState.CharacterGuid)
      data.BestLapTime = playerState.BestLapTime
      data.Levels = string.format('[%s]', table.concat(playerState.Levels, ","))
      data.OwnCompanyGuid = GuidToString(playerState.OwnCompanyGuid)
      data.JoinedCompanyGuid = GuidToString(playerState.JoinedCompanyGuid)
      data.CustomDestinationAbsoluteLocation = VectorToString(playerState.CustomDestinationAbsoluteLocation)

      local ownedEventGuids = {}
      for j = 1, #playerState.OwnEventGuids, 1 do
        table.insert(ownedEventGuids, GuidToString(playerState.OwnEventGuids[j]))
      end
      data.OwnEventGuids = string.format("[%s]", table.concat(ownedEventGuids, ","))

      local joinedEventGuids = {}
      for k = 1, #playerState.JoinedEventGuids, 1 do
        table.insert(joinedEventGuids, GuidToString(playerState.JoinedEventGuids[k]))
      end
      data.JoinedEventGuids = string.format("[%s]", table.concat(joinedEventGuids, ","))

      data.Location = VectorToString(playerState.Location)
      data.VehicleKey = playerState.VehicleKey:ToString()
    end

    local playerArr = {}
    for key, value in pairs(data) do
      local _val = ""
      if type(value) == "number" or type(value) == "boolean" then
        _val = tostring(value)
      elseif (string.sub(value, 1, 1) == "{" and string.sub(value, -1, -1) == "}") or (string.sub(value, 1, 1) == "[" and string.sub(value, -1, -1) == "]") then
        _val = value
      else
        _val = string.format('"%s"', value)
      end

      table.insert(playerArr, string.format('"%s":%s', key, _val))
    end
    table.insert(arr, string.format("{%s}", table.concat(playerArr, ",")))
  end
  return string.format('{"data":[%s]}', table.concat(arr, ","))
end

RegisterConsoleCommandHandler("getplayerstates", function(Cmd, CommandParts, Ar)
  LogMsg(GetPlayerStates())
  return true
end)

return {
  GetPlayerStates = GetPlayerStates
}
