local json = require("JsonParser")

---Convert player state to JSON serializable table
---@param playerState AMotorTownPlayerState
local function PlayerStateToTable(playerState)
  local data = {}

  if playerState:IsValid() then
    data.UniqueID = GetUniqueNetIdAsString(playerState)

    data.PlayerName = playerState:GetPlayerName():ToString()
    data.GridIndex = playerState.GridIndex
    data.bIsHost = playerState.bIsHost
    data.bIsAdmin = playerState.bIsAdmin
    data.CharacterGuid = GuidToString(playerState.CharacterGuid)
    data.BestLapTime = playerState.BestLapTime

    data.Levels = {}
    playerState.Layers:ForEach(function(index, element)
      table.insert(data.Levels, element:get())
    end)

    data.OwnCompanyGuid = GuidToString(playerState.OwnCompanyGuid)
    data.JoinedCompanyGuid = GuidToString(playerState.JoinedCompanyGuid)
    data.CustomDestinationAbsoluteLocation = VectorToTable(playerState.CustomDestinationAbsoluteLocation)

    data.OwnEventGuids = {}
    playerState.OwnEventGuids:ForEach(function(index, element)
      table.insert(data.OwnEventGuids, GuidToString(element:get()))
    end)

    data.JoinedEventGuids = {}
    playerState.JoinedEventGuids:ForEach(function(index, element)
      table.insert(data.JoinedEventGuids, GuidToString(element:get()))
    end)

    data.Location = VectorToTable(playerState.Location)
    data.VehicleKey = playerState.VehicleKey:ToString()
  end

  return data
end

---Get all or selected player state(s)
---@param uniqueId string? Filter by player state unique net ID
---@return table[]
local function GetPlayerStates(uniqueId)
  local gameState = GetMotorTownGameState()
  local arr = {}

  if not gameState:IsValid() then return arr end

  local playerStates = gameState.PlayerArray

  LogOutput("DEBUG", "%i player state(s) found", #playerStates)

  for i = 1, #gameState.PlayerArray, 1 do
    local playerState = gameState.PlayerArray[i]
    if playerState:IsValid() then
      ---@cast playerState AMotorTownPlayerState

      local data = PlayerStateToTable(playerState)

      -- Filter by uniqueId if provided
      if uniqueId and uniqueId ~= data.UniqueID then goto continue end

      table.insert(arr, data)

      ::continue::
    end
  end
  return arr
end

---Get my current pawn transform
---@return FVector? location
---@return FRotator? rotation
local function GetMyCurrentTransform()
  local PC = GetMyPlayerController()
  if PC:IsValid() then
    local pawn = PC:K2_GetPawn()
    if pawn:IsValid() then
      local location = pawn:K2_GetActorLocation()
      local rotation = pawn:K2_GetActorRotation()
      return location, rotation
    end
  end
  return nil, nil
end

-- Console commands

RegisterConsoleCommandHandler("getplayers", function(Cmd, CommandParts, Ar)
  local playerStates = json.stringify(GetPlayerStates(CommandParts[1]))
  LogOutput("INFO", playerStates)
  return true
end)

RegisterConsoleCommandHandler("getplayertransform", function(Cmd, CommandParts, Ar)
  local location, rotation = GetMyCurrentTransform()
  LogOutput("INFO", "Actor transform: %s", json.stringify({ Location = location, Rotation = rotation }))
  return true
end)

-- HTTP request handlers

---Handle request for player states
---@param session ClientTable
local function HandleGetPlayerStates(session)
  local playerId = session.pathComponents[2]
  local res = GetPlayerStates(playerId)
  if playerId and #res == 0 then
    return json.stringify { message = string.format("Player with unique ID %s not found", playerId) }, nil, 404
  end

  return json.stringify { data = res }, nil, 200
end

return {
  HandleGetPlayerStates = HandleGetPlayerStates,
  GetMyCurrentTransform = GetMyCurrentTransform,
  PlayerStateToTable = PlayerStateToTable
}
