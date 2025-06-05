local UEHelpers = require("UEHelpers")
local json = require("JsonParser")

---Spawn an actor at the desired place
---@param assetPath string
---@param location FVector?
---@param rotation FRotator?
---@param tag string?
---@return boolean
---@return string? AssetTag
local function SpawnActor(assetPath, location, rotation, tag)
  local world = UEHelpers.GetWorld()

  if world and world:IsValid() then
    local staticMeshActorClass = StaticFindObject("/Script/Engine.StaticMeshActor")
    ---@cast staticMeshActorClass UClass
    local staticMeshClass = StaticFindObject("/Script/Engine.StaticMesh")
    ---@cast staticMeshClass UClass

    local assetTag = nil
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

      ---@type AActor
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

        assetTag = tag
        if not assetTag then
          local str = SplitString(actor:GetFullName())

          if str and str[2] then
            assetTag = str[2]
          else
            error("Invalid asset tag")
          end
        end

        -- Apply actor tag for easy retrieval later
        actor.Tags[#actor.Tags + 1] = FName(assetTag)
        LogMsg("Spawned actor tagged: " .. assetTag, "DEBUG")

        if softAssetClass:IsA(staticMeshClass) then
          ---@cast actor AStaticMeshActor
          ---@cast softAssetClass UStaticMesh
          actor.StaticMeshComponent:SetStaticMesh(softAssetClass)
        end
      end
    end)
    return true, assetTag
  end
  return false
end

---Destroy actor given its tag
---@param assetTag string
local function DestroyActor(assetTag)
  if assetTag == nil or type(assetTag) ~= "string" then
    error("Invalid asset tag provided")
  end

  local world = UEHelpers.GetWorld()
  local actors = {}
  UEHelpers.GetGameplayStatics():GetAllActorsWithTag(world, FName(assetTag), actors)

  LogMsg("Found " .. #actors .. " actor(s) for deletion", "DEBUG")
  for i = 1, #actors, 1 do
    local actor = actors[i]:get() ---@type AActor
    local actorName = actor:GetFullName()
    LogMsg("Found actor with tag: " .. actorName .. " for deletion", "DEBUG")

    ExecuteInGameThread(function()
      actor:K2_DestroyActor()
    end)
    LogMsg("Destroyed actor: " .. actorName, "DEBUG")
  end
end

-- Handle requests

---Handle spawn actor request
---@type RequestPathHandler
local function HandleSpawnActor(session)
  local content = json.parse(session.content)

  if content ~= nil and type(content) == "table" then
    if #content > 0 then
      local assetTags = {}
      for index, value in ipairs(content) do
        if value and value.AssetPath and value.Location then
          local spawned, tag = SpawnActor(value.AssetPath, value.Location, value.Rotation, value.tag)
          if spawned then
            table.insert(assetTags, tag)
          else
            error("Failed to spawn asset " .. value.AssetPath)
          end
        end
      end
      return json.stringify { data = assetTags }
    else
      if content and content.AssetPath and content.Location then
        local spawned, tag = SpawnActor(content.AssetPath, content.Location, content.Rotation, content.tag)
        if spawned then
          return json.stringify { data = { tag } }
        else
          error("Failed to spawn asset " .. content.AssetPath)
        end
      end
    end
  end
  return nil, nil, 400
end

---Handle despawn actor request based on tag
---@type RequestPathHandler
local function HandleDespawnActor(session)
  local content = json.parse(session.content)

  if content ~= nil and type(content) == "table" then
    if #content.Tags > 0 then
      for index, value in ipairs(content.Tags) do
        DestroyActor(value)
      end
    else
      DestroyActor(content.Tag)
    end
    return nil, nil, 204
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
  local tag = CommandParts[4]

  if CommandParts[2] then
    local parse = SplitString(CommandParts[2], ",")
    if parse and #parse == 3 then
      location = {
        X = tonumber(parse[1]) or 0,
        Y = tonumber(parse[2]) or 0,
        Z = tonumber(parse[3]) or 0
      }
    end
  end

  if CommandParts[3] then
    local parse = SplitString(CommandParts[3] ",")
    if parse and #parse == 3 then
      rotation = {
        Roll = tonumber(parse[1]) or 0,
        Pitch = tonumber(parse[2]) or 0,
        Yaw = tonumber(parse[3]) or 0
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

  SpawnActor(assetPath, location, rotation, tag)
  return true
end)

RegisterConsoleCommandHandler("destroyactor", function(Cmd, CommandParts, Ar)
  local actorPath = CommandParts[1]

  if not actorPath then
    error("No actor path given")
  end

  DestroyActor(actorPath)
  return true
end)

return {
  HandleSpawnActor = HandleSpawnActor,
  HandleDespawnActor = HandleDespawnActor
}
