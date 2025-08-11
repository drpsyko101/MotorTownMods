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

RegisterConsoleCommandHandler("addmoney", function(Cmd, CommandParts, Ar)
  local amount = tonumber(CommandParts[1]) or 0
  local PC = GetMyPlayerController()
  if PC:IsValid() then
    ---@cast PC AMotorTownPlayerController

    PC:ClientAddMoney(amount, "", FText("Money added"), false, "", "")
  end
  return true
end)

RegisterConsoleCommandHandler("teleporttodest", function(Cmd, CommandParts, Ar)
  local PC = GetMyPlayerController()
  if PC:IsValid() then
    ---@cast PC AMotorTownPlayerController
    local PS = PC.PlayerState
    if PS:IsValid() then
      ---@cast PS AMotorTownPlayerState
      local location = PS.CustomDestinationAbsoluteLocation
      if location ~= { X = 0, Y = 0, Z = 0 } then
        PC:ClientTeleportedCharacter({
          X = location.X,
          Y = location.Y,
          Z = location.Z
        })
      else
        LogOutput("ERROR", "No custom destination set")
      end
    end
  end
  return true
end)

-- HTTP request handlers

---Handle request for player states.
---See [documentation](../docs/LuaHttpServer/PlayerManagement.md)
---@type RequestPathHandler
local function HandleGetPlayerStates(session)
  local playerId = session.pathComponents[2]
  local filters = SplitString(session.queryComponents.filters, ",")
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
      Yaw = data.Rotation and data.Rotation.Yaw or 0.0
    }

    if playerId then
      local PC = GetPlayerControllerFromUniqueId(playerId)
      ---@cast PC AMotorTownPlayerController

      if PC:IsValid() then
        local pawn = PC:K2_GetPawn()
        if pawn:IsValid() then
          LogOutput("DEBUG", "pawn: %s", pawn:GetFullName())
          local charClass = StaticFindObject("/Script/MotorTown.MTCharacter")
          ---@cast charClass UClass
          local vehicleClass = StaticFindObject("/Script/MotorTown.MTVehicle")
          ---@cast vehicleClass UClass

          ExecuteInGameThreadSync(function()
            if pawn:IsA(charClass) then
              PC:ServerTeleportCharacter(location, false, false)
            elseif pawn:IsA(vehicleClass) then
              ---@cast pawn AMTVehicle
              PC:ServerResetVehicleAt(pawn, location, rotation, true)
            else
              error("Failed to teleport player")
            end
          end)

          local msg = string.format("Teleported player %s to %s", playerId, json.stringify(location))
          return json.stringify { status = msg }
        end
      end
      return json.stringify { error = string.format("Failed to teleport player %s", playerId) }, nil, 400
    end
    return json.stringify { error = string.format("Invalid player ID %s", playerId) }, nil, 400
  end
  return json.stringify { error = "Invalid payload" }, nil, 400
end

---Handle removing given amount from gameplay effect stack
---@type RequestPathHandler
local function HandleRemoveGameplayEffect(session)
  local playerId = session.pathComponents[2]
  local data = json.parse(session.content)
  local amount = math.floor(tonumber(data and data.Amount) or 1)

  if data and playerId then
    local PC = GetPlayerControllerFromUniqueId(playerId)
    if PC:IsValid() then
      local PS = PC.PlayerState

      if PS:IsValid() then
        ---@cast PS AMotorTownPlayerState

        if PS.Character:IsValid() then
          local comp = PS.Character.AbilityComponent

          if comp:RemoveActiveGameplayEffect({}, amount) then
            return json.stringify { message = "Successfully removed gameplay effect" }
          else
            return json.stringify { error = "Failed to remove active gameplay effect" }, nil, 400
          end
        end
      end
    end
  end

  return json.stringify { error = "invalid payload" }, nil, 400
end

---Handle request to add money to player
---@type RequestPathHandler
local function HandleAddMoney(session)
  local playerId = session.pathComponents[2]
  local data = json.parse(session.content)

  if data and playerId then
    local amount = math.floor(tonumber(data.Amount) or 0)
    local message = data.Message or ""
    local PC = GetPlayerControllerFromUniqueId(playerId)

    if PC:IsValid() then
      ---@cast PC AMotorTownPlayerController
      PC:ClientAddMoney(amount, "", FText(message), false, "", "")
      return json.stringify { message = string.format("Added %d money to player %s", amount, playerId) }
    end
  end

  return json.stringify { error = "Invalid payload" }, nil, 400
end

return {
  HandleGetPlayerStates = HandleGetPlayerStates,
  GetMyCurrentTransform = GetMyCurrentTransform,
  HandleTeleportPlayer = HandleTeleportPlayer,
  HandleRemoveGameplayEffect = HandleRemoveGameplayEffect,
  HandleAddMoney = HandleAddMoney,
}
