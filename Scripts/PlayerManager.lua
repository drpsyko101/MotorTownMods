local UEHelpers = require("UEHelpers")
local json = require("JsonParser")

---Get all or selected player state(s)
---@param guid string? Filter by character guid
---@return table[]
local function GetPlayerStates(guid)
  local gameState = GetMotorTownGameState()
  local arr = {}

  if not gameState:IsValid() then return arr end

  local playerStates = gameState.PlayerArray

  LogMsg(string.format("%i player state(s) found", #playerStates), "DEBUG")

  playerStates:ForEach(function(index, element)
    local playerState = element:get() ---@type AMotorTownPlayerState

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

    table.insert(arr, data)

    ::continue::
  end)
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
  LogMsg(playerStates)
  return true
end)

RegisterConsoleCommandHandler("getplayertransform", function(Cmd, CommandParts, Ar)
  local location, rotation = GetMyCurrentTransform()
  LogMsg("Actor transform: " .. json.stringify({ Location = location, Rotation = rotation }))
  return true
end)

-- HTTP request handlers

---Handle request for player states
---@param session ClientTable
local function HandleGetPlayerStates(session)
  local playerStates = json.stringify {
    data = GetPlayerStates()
  }
  return playerStates
end

---Handle request for player states
---@param session ClientTable
local function HandleGetSpecifcPlayerStates(session)
  local playerGuid = session.pathComponents[2]
  local playerStates = json.stringify {
    data = GetPlayerStates(playerGuid)
  }
  return playerStates
end

return {
  HandleGetPlayerStates = HandleGetPlayerStates,
  HandleGetSpecifcPlayerStates = HandleGetSpecifcPlayerStates,
  GetMyCurrentTransform = GetMyCurrentTransform
}
