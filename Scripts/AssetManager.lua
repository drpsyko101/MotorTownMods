local UEHelpers = require("UEHelpers")
local json = require("JsonParser")

---Spawn an actor at the desired place
---@param assetPath string
---@param location FVector?
---@param rotation FRotator?
local function SpawnActor(assetPath, location, rotation)
  local world = UEHelpers.GetWorld()

  if world and world:IsValid() then
    local staticMeshActorClass = StaticFindObject("/Script/Engine.StaticMeshActor")
    ---@cast staticMeshActorClass UClass
    local staticMeshClass = StaticFindObject("/Script/Engine.StaticMesh")
    ---@cast staticMeshClass UClass

    ExecuteInGameThread(function()
      LoadAsset(assetPath)
      local assetClass = {}
      local softAssetClass = StaticFindObject(assetPath)

      if softAssetClass:IsA(staticMeshClass) then
        assetClass = staticMeshActorClass
      else
        assetClass = softAssetClass
      end

      LogMsg("Loaded and found asset " .. assetClass:GetFullName(), "DEBUG")
      if not assetClass:IsValid() then
        error("Invalid asset loaded: " .. assetPath)
      end

      ---@type AStaticMeshActor
      local actor = world:SpawnActor(
        assetClass,
        {
          X = location and location.X or 0,
          Y = location and location.Y or 0,
          Z = location and location.Z or 0,
        },
        {
          Pitch = rotation and rotation.Pitch or 0,
          Roll = rotation and rotation.Roll or 0,
          Yaw = rotation and rotation.Yaw or 0
        }
      )
      if actor:IsValid() then
        LogMsg("Spawned actor " .. actor:GetFullName(), "DEBUG")

        if softAssetClass:IsA(staticMeshClass) then
          ---@cast actor AStaticMeshActor
          ---@cast softAssetClass UStaticMesh
          actor.StaticMeshComponent:SetStaticMesh(softAssetClass)
        end
      end
    end)
    return true
  end
  return false
end

-- Handle requests

---Handle spawn actor request
---@type RequestPathHandler
local function HandleSpawnActor(session)
  local content = json.parse(session.content)

  if content and content.AssetPath and content.Location then
    if SpawnActor(content.AssetPath, content.Location, content.Rotation) then
      return nil, nil, 204
    else
      error("Failed to spawn asset " .. content.AssetPath)
    end
  end
  return nil, nil, 400
end

-- Register console commands

-- Spawn actor based on given location and/or rotation
-- If no location given, line trace from camera hit location will be used instead.
-- If no rotation given, the camera world rotation will be used instead.
RegisterConsoleCommandHandler("spawnactor", function(Cmd, CommandParts, Ar)
  local assetPath = CommandParts[1]
  local location = nil
  local rotation = nil

  if CommandParts[2] then
    local parse = SplitString(CommandParts[2], ",")
    if parse and #parse == 3 then
      location = {
        X = parse[1],
        Y = parse[2],
        Z = parse[3]
      }
    end
  end

  if CommandParts[3] then
    local parse = SplitString(CommandParts[3] ",")
    if parse and #parse == 3 then
      rotation = {
        X = parse[1],
        Y = parse[2],
        Z = parse[3]
      }
    end
  end

  if not assetPath then
    error("No asset path provided")
  end

  if not location then
    local wasHit, hitResult = GetHitResultFromCenterLineTrace()
    if wasHit then
      location = hitResult.Location
    end
  end

  if not rotation then
    local PC = GetMyPlayerController()
    if PC:IsValid() then
      rotation = PC.PlayerCameraManager:GetCameraRotation()
      rotation.Pitch = 0
    end
  end

  SpawnActor(assetPath, location, rotation)
  return true
end)

return {
  HandleSpawnActor = HandleSpawnActor
}
