local webhook = require("Webclient")
local json = require("JsonParser")
local assetManager = require("AssetManager")
local timer = require("Debugging/Timer")

local vehicleDealerSoftPath = "/Script/MotorTown.MTDealerVehicleSpawnPoint"
local garageSoftPath = "/Game/Objects/GarageActorBP.GarageActorBP_C"

---Get all or selected vehicle state(s)
---@param id number? Get specific vehicle with ID
---@param fields string[]? Filter the result based on the table key(s)
---@param limit number? Limit the output amount
---@param isControlled boolean? Filter vehicles that are operated by a player
---@param depth integer? Recursive search depth
local function GetVehicles(id, fields, limit, isControlled, depth)
  local gameState = GetMotorTownGameState()
  local arr = {} ---@type table[]

  if not gameState:IsValid() then return arr end

  for i = 1, #gameState.Vehicles, 1 do
    local vehicle = gameState.Vehicles[i]
    -- Filter by id
    if id and id ~= vehicle.Net_VehicleId then
      goto continue
    end

    if isControlled and not vehicle.Net_MovementOwnerPC:IsValid() then
      goto continue
    end

    if fields then
      local data = {}
      for index, value in ipairs(fields) do
        MergeTables(data, GetObjectAsTable(vehicle, value, nil, depth))
      end
      -- Always returns the vehicle ID
      data.Net_VehicleId = vehicle.Net_VehicleId

      table.insert(arr, data)
    else
      table.insert(arr, GetObjectAsTable(vehicle, nil, "/Script/MotorTown.MTVehicle", depth))
    end

    -- Limit result if set
    if limit and #arr >= limit then
      return arr
    end

    ::continue::
  end
  return arr
end

---Despawn selected vehicle
---@param id number Vehicle ID
---@param uniqueId string? Player unique net ID
local function DespawnVehicleById(id, uniqueId)
  local gameState = GetMotorTownGameState()

  if not gameState:IsValid() then return false end

  local vehicle = CreateInvalidObject()
  ---@cast vehicle AMTVehicle
  for i = 1, #gameState.Vehicles, 1 do
    if gameState.Vehicles[i].Net_VehicleId == id then
      vehicle = gameState.Vehicles[i]
      break
    end
  end

  if not vehicle:IsValid() then return false end

  for i = 1, #gameState.PlayerArray, 1 do
    local playerState = gameState.PlayerArray[i]
    ---@cast playerState AMotorTownPlayerState

    if uniqueId and uniqueId == GetUniqueNetIdAsString(playerState) then
      local PC = playerState:GetPlayerController()
      ---@cast PC AMotorTownPlayerController

      if PC:IsValid() and playerState.bIsAdmin then
        if playerState.bIsHost then
          ExecuteInGameThread(function()
            PC:ServerDespawnVehicle(vehicle, 0)
          end)
          return true
        else
          return webhook.CreateServerRequest(
            "/vehicle/" .. id .. "/despawn",
            json.stringify {
              PlayerGuid = uniqueId
            }
          )
        end
      end
    end
  end
  return false
end

---Spawn vehicle dealer plot at given location
---@param location FVector Location to spawn
---@param rotation FRotator? Plot world rotation
---@param vehicleClass string? Vehicle blueprint class path
---@param vehicleParam table? Optional vehicle parameter
---@return boolean Success
---@return string? AssetTag Generated asset tag
local function SpawnVehicleDealer(location, rotation, vehicleClass, vehicleParam)
  local status, assetTag, actor = assetManager.SpawnActor(vehicleDealerSoftPath, location, rotation)

  if status and actor and actor:IsValid() then
    ---@cast actor AMTDealerVehicleSpawnPoint

    if vehicleParam then
      actor.VehicleParams[1] = {
        Customizations = vehicleParam.Customizations or {},
        Parts = vehicleParam.Parts or {},
        VehicleKey = FName(vehicleParam.VehicleKey or "")
      }
    end
    return true, assetTag
  end
  return false
end

---Get all garages
---@return table[]
local function GetGarages()
  local data = {}
  local gameState = GetMotorTownGameState()

  if gameState:IsValid() then
    for i = 1, #gameState.Garages do
      local garage = gameState.Garages[i]
      local output = GetObjectAsTable(garage, nil, "MTGarageActor")
      output.Location = VectorToTable(garage:K2_GetActorLocation())
      output.Rotation = RotatorToTable(garage:K2_GetActorRotation())
      table.insert(data, output)
    end
  end

  return data
end

---Spawn garage at the given location and rotation
---@param location FVector
---@param rotation FRotator
local function SpawnGarage(location, rotation)
  local status, assetTag, actor = assetManager.SpawnActor(garageSoftPath, location, rotation)
  local garageClass = StaticFindObject("/Script/MotorTown.MTGarageActor")
  ---@cast garageClass UClass

  if status and actor and actor:IsValid() and actor:IsA(garageClass) then
    return true, assetTag
  end
  return false
end

-- Console commands

RegisterConsoleCommandHandler("getvehicles", function(Cmd, CommandParts, Ar)
  local limit = tonumber(CommandParts[1])
  local filters = SplitString(CommandParts[2])
  local data = GetVehicles(nil, filters, limit)
  LogOutput("DEBUG", "%s: %s", Cmd, json.stringify(data))
  return true
end)

RegisterConsoleCommandHandler("despawnvehicle", function()
  local actor = GetSelectedActor()

  if not actor:IsValid() then
    LogOutput("ERROR", "No actor selected")
    return false
  end

  local vehicleClass = StaticFindObject("/Script/MotorTown.MTVehicle")
  ---@cast vehicleClass UClass

  if not vehicleClass:IsValid() then
    LogOutput("ERROR", "Vehicle class not found")
    return false
  end

  if not actor:IsA(vehicleClass) then
    LogOutput("ERROR", "Selected actor is not a vehicle")
    return false
  end

  if not actor:IsActorBeingDestroyed() then
    ---@cast actor AMTVehicle

    local vehicleName = actor:GetFullName()
    if DespawnVehicleById(actor.Net_VehicleId, GetPlayerUniqueId(GetMyPlayerController())) then
      LogOutput("INFO", "Despawned vehicle: %s", vehicleName)
    end
  end
  return true
end)

RegisterConsoleCommandHandler("setvehicleparam", function(Cmd, CommandParts, Ar)
  if not pcall(function()
        local fields = SplitString(table.remove(CommandParts, 1), ".")
        local value = CommandParts[1]

        if not fields then
          LogOutput("ERROR", "No fields value given.")
          return true
        end

        if value == nil then
          LogOutput("ERROR", "No valid value given.")
          return true
        end

        local PC = GetMyPlayerController()
        if PC:IsValid() then
          local pawn = PC:K2_GetPawn()
          local vehicleClass = StaticFindObject("/Script/MotorTown.MTVehicle")
          ---@cast vehicleClass UClass

          if pawn:IsValid() and pawn:IsA(vehicleClass) then
            RecursiveSetValue(pawn, fields, value)
          end
        end
      end) then
    LogOutput("WARN", "Failed to change %s field for pawn", CommandParts[2])
  end

  return true
end)

-- HTTP request handler

---Handle the get vehicles commands
---@type RequestPathHandler
local function HandleGetVehicles(session)
  local id = tonumber(session.pathComponents[2]) or nil
  local fields = SplitString(session.queryComponents.filters, ",")
  local limit = tonumber(session.queryComponents.limit)
  local isPlayerControlled = session.queryComponents.isPlayerControlled == "true" or false
  local depth = tonumber(session.queryComponents.depth)

  local getTime, data = timer.benchmark(GetVehicles, id, fields, limit, isPlayerControlled, depth)
  LogOutput("DEBUG", "GetVehicles time: %fs", getTime)

  if id and #data == 0 then
    return json.stringify { message = string.format("Vehicle with ID %s not found", id) }, nil, 404
  end

  local stringifyTime, res = timer.benchmark(json.stringify, { data = data })
  LogOutput("DEBUG", "GetVehicles stringify time: %fs", stringifyTime)
  return res, nil, 200
end

---Handle vehicle despawn request
---@type RequestPathHandler
local function HandleDespawnVehicle(session)
  local id = tonumber(session.pathComponents[2])
  local content = json.parse(session.content)
  local playerGuid = nil

  if content then
    playerGuid = content.PlayerGuid
  end

  if not id then
    return json.stringify { message = "Invalid vehicle ID" }, nil, 400
  end

  if DespawnVehicleById(id, playerGuid) then
    return nil, nil, 204
  else
    return json.stringify { message = "Failed to despawn vehicle" }, nil, 400
  end
end

---Handle vehicle dealer spawn point
---@type RequestPathHandler
local function HandleCreateVehicleDealerSpawnPoint(session)
  local data = json.parse(session.content)
  if data then
    local status, tag = SpawnVehicleDealer(
      {
        X = data.Location.X,
        Y = data.Location.Y,
        Z = data.Location.Z
      },
      {
        Pitch = data.Rotation and data.Rotation.Pitch or 0,
        Roll = data.Rotation and data.Rotation.Roll or 0,
        Yaw = data.Rotation and data.Rotation.Yaw or 0
      },
      data.VehicleClass,
      data.VehicleParam
    )
    if status then
      return json.stringify { data = { tag = tag } }, nil, 201
    end
  end
  return nil, nil, 400
end

---Handle the get garages request
---@type RequestPathHandler
local function HandleGetGarages(session)
  local res = json.stringify {
    data = GetGarages()
  }
  return res, nil, 200
end

---Handle garage spawn request
---@type RequestPathHandler
local function HandleSpawnGarage(session)
  local data = json.parse(session.content)
  if data and data.Location then
    local status, tag = SpawnGarage(
      {
        X = data.Location.X,
        Y = data.Location.Y,
        Z = data.Location.Z
      },
      {
        Pitch = data.Rotation and data.Rotation.Pitch or 0,
        Roll = data.Rotation and data.Rotation.Roll or 0,
        Yaw = data.Rotation and data.Rotation.Yaw or 0
      }
    )
    if status then
      return json.stringify { data = { tag = tag } }, nil, 201
    end
  end
  return nil, nil, 400
end

---Handle request to change a vehicle parameter
---@type RequestPathHandler
local function HandleSetVehicleParameter(session)
  local id = tonumber(session.pathComponents[2])
  local data = json.parse(session.content)

  if data and data.Field and data.Value then
    local vehicle = CreateInvalidObject() ---@cast vehicle AMTVehicle
    if id and id > 0 then -- Prevent modifying the AI/loaner vehicles
      local gameState = GetMotorTownGameState()
      if gameState:IsValid() then
        for i = 1, #gameState.Vehicles do
          local _vehicle = gameState.Vehicles[i]
          if _vehicle:IsValid() and _vehicle.Net_VehicleId == id then
            vehicle = _vehicle
            break;
          end
        end
      end
    elseif data.PlayerId then
      local PC = GetPlayerControllerFromUniqueId(data.PlayerId)
      if PC:IsValid() then
        local pawn = PC:K2_GetPawn()
        local vehicleClass = StaticFindObject("/Script/MotorTown.MTVehicle")
        ---@cast vehicleClass UClass

        if pawn:IsValid() and pawn:IsA(vehicleClass) then
          vehicle = pawn
        end
      end
    end

    if vehicle:IsValid() then
      local fields = SplitString(data.Field, ".") or {}
      RecursiveSetValue(vehicle, fields, data.Value)
      return json.stringify { Status = "ok" }, nil, 200
    end
    return json.stringify { error = "Unable to find specified vehicle" }, nil, 404
  end
  return json.stringify { error = "Invalid payload provided" }, nil, 400
end

return {
  HandleGetVehicles = HandleGetVehicles,
  HandleDespawnVehicle = HandleDespawnVehicle,
  HandleCreateVehicleDealerSpawnPoint = HandleCreateVehicleDealerSpawnPoint,
  HandleGetGarages = HandleGetGarages,
  HandleSpawnGarage = HandleSpawnGarage,
  HandleSetVehicleParameter = HandleSetVehicleParameter,
}
