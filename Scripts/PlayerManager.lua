local json = require("JsonParser")

---Get all or selected player state(s)
---@param uniqueId string? Filter by player state unique net ID
---@param filters string[]? Fields to be filtered
---@param depth integer? Recursive search depth
---@return table[]
local function GetPlayerStates(uniqueId, filters, depth)
  local gameState = GetMotorTownGameState()
  local arr = {}

  if not gameState:IsValid() then return arr end

  local playerStates = gameState.PlayerArray

  LogOutput("DEBUG", "%i player state(s) found", #playerStates)

  for i = 1, #gameState.PlayerArray, 1 do
    local playerState = gameState.PlayerArray[i]
    if playerState:IsValid() then
      ---@cast playerState AMotorTownPlayerState

      local playerId = GetUniqueNetIdAsString(playerState)
      -- Filter by uniqueId if provided
      if uniqueId and uniqueId ~= playerId then goto continue end

      local data = {}
      if filters then
        for _, value in ipairs(filters) do
          MergeTables(data, GetObjectAsTable(playerState, value, nil, depth))
        end
      else
        data = GetObjectAsTable(playerState, nil, "MotorTownPlayerState", depth)
        data.Name = playerState:GetPlayerName():ToString()
      end

      -- Always return unique ID
      data.UniqueID = playerId

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
  local pcClass = StaticFindObject("/Script/MotorTown.MotorTownPlayerController")
  ---@cast pcClass UClass

  if PC:IsValid() and PC:IsA(pcClass) then
    ---@cast PC AMotorTownPlayerController
    local actor = CreateInvalidObject()
    ---@cast actor AActor

    -- Account for drone usage since drone isn't a pawn
    if PC.Drone:IsValid() then
      actor = PC.Drone
    else
      local pawn = PC:K2_GetPawn()
      if pawn:IsValid() then
        actor = pawn
      end
    end

    if actor:IsValid() then
      local location = actor:K2_GetActorLocation()
      local rotation = actor:K2_GetActorRotation()
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

---Handle request for player states.
---See [documentation](../docs/LuaHttpServer/PlayerManagement.md)
---@type RequestPathHandler
local function HandleGetPlayerStates(session)
  local playerId = session.pathComponents[2]
  local filters = SplitString(session.queryComponents.filters)
  local depth = tonumber(session.queryComponents.depth)
  local res = GetPlayerStates(playerId, filters, depth)

  if playerId and #res == 0 then
    return json.stringify { message = string.format("Player with unique ID %s not found", playerId) }, nil, 404
  end

  return json.stringify { data = res }, nil, 200
end

---Handle request to teleport player
---@type RequestPathHandler
local function HandleTeleportPlayer(session)
  local playerId = session.pathComponents[2]
  local data = json.parse(session.content)

  if data and data.Location then
    ---@type FVector
    local location = { X = data.Location.X, Y = data.Location.Y, Z = data.Location.Z }
    ---@type FRotator
    local rotation = {
      Roll = data.Rotation and data.Rotation.Roll or 0.0,
      Pitch = data.Rotation and data.Rotation.Pitch or 0.0,
      Yaw = data.Rotation and data.Rotation.Roll or 0.0
    }

    if playerId then
      local PC = GetPlayerControllerFromUniqueId(playerId)
      if PC:IsValid() then
        local pawn = PC:K2_GetPawn()
        if pawn:IsValid() then
          if pawn:K2_TeleportTo(location, rotation) then
            local msg = string.format("Teleported player %s to %s", playerId, json.stringify(data.Location))
            return json.stringify { status = msg }, nil, 200
          end
        end
      end
      return json.stringify { error = string.format("Failed to teleport player %s", playerId) }, nil, 400
    end
    return json.stringify { error = string.format("Invalid player ID %s", playerId) }, nil, 400
  end
  return json.stringify { error = "Invalid payload" }, nil, 400
end

return {
  HandleGetPlayerStates = HandleGetPlayerStates,
  GetMyCurrentTransform = GetMyCurrentTransform,
  HandleTeleportPlayer = HandleTeleportPlayer,
}
