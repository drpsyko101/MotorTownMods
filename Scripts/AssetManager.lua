local UEHelpers = require("UEHelpers")
local json = require("JsonParser")
local socket = require("socket")

---Spawn an actor at the desired place
---@param assetPath string
---@param location FVector?
---@param rotation FRotator?
---@param tag string?
---@return boolean
---@return string? AssetTag
---@return AActor? SpawnedActor
local function SpawnActor(assetPath, location, rotation, tag)
  local world = UEHelpers.GetWorld()
  if world and world:IsValid() then
    local staticMeshActorClass = StaticFindObject("/Script/Engine.StaticMeshActor")
    ---@cast staticMeshActorClass UClass
    local staticMeshClass = StaticFindObject("/Script/Engine.StaticMesh")
    ---@cast staticMeshClass UClass
    local actor = CreateInvalidObject() ---@cast actor AActor
    local object = StaticFindObject(assetPath)
    local isProcessing = true

    local assetTag = tag
    ExecuteInGameThread(function()
      pcall(function()
        LoadAsset(assetPath)
        local assetClass = {}

        if object:IsA(staticMeshClass) then
          assetClass = staticMeshActorClass
        else
          assetClass = object
        end

        LogOutput("DEBUG", "Loaded and found asset %s", assetClass:GetFullName())
        if not assetClass:IsValid() then
          error("Invalid asset loaded: " .. assetPath)
        end

        ---@type AActor
        actor = world:SpawnActor(
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
      end)
      isProcessing = false
    end)
    while isProcessing do
      socket.sleep(0.01)
    end
    if actor:IsValid() then
      LogOutput("DEBUG", "Spawned actor %s", actor:GetFullName())

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
      LogOutput("DEBUG", "Spawned actor tagged: %s", assetTag)

      if actor:IsA(staticMeshActorClass) then
        ---@cast actor AStaticMeshActor
        ---@cast object UStaticMesh

        -- Set actor to movable
        actor:SetMobility(2)
        if actor.StaticMeshComponent:SetStaticMesh(object) then
          actor:SetReplicates(true)
        else
          error("Failed to set " .. object:GetFullName())
        end
      end
      return true, assetTag, actor
    end
  end
  return false
end

---Destroy actor given its tag.
---This function does not immediately destroy object(s) on completion.
---We're just marking the object for destruction in the latent GameThread.
---@param assetTag string
local function DestroyActor(assetTag)
  if assetTag == nil or type(assetTag) ~= "string" then
    error("Invalid asset tag provided")
  end

  local world = UEHelpers.GetWorld()
  local actors = {}
  UEHelpers.GetGameplayStatics():GetAllActorsWithTag(world, FName(assetTag), actors)

  LogOutput("DEBUG", "Found %i actor(s) for deletion", #actors)
  ExecuteInGameThread(function()
    for i = 1, #actors, 1 do
      local actor = actors[i]:get() ---@type AActor
      local actorName = actor:GetFullName()
      LogOutput("DEBUG", "Found actor with tag: %s for deletion", actorName)

      actor:K2_DestroyActor()
      LogOutput("DEBUG", "Destroyed actor: %s", actorName)
    end
  end)
end

---Offset a selected actor location
---@param offset { Translation: FVector?, Rotation: FRotator? }
local function AddAssetTransformOffset(offset)
  local actor = GetSelectedActor()

  if actor:IsValid() then
    local location = actor:K2_GetActorLocation()
    local rotation = actor:K2_GetActorRotation()
    if actor:K2_TeleportTo(
          {
            X = location.X + (offset.Translation and offset.Translation.X or 0),
            Y = location.Y + (offset.Translation and offset.Translation.Y or 0),
            Z = location.Z + (offset.Translation and offset.Translation.Z or 0)
          },
          {
            Roll = rotation.Roll + (offset.Rotation and offset.Rotation.Roll or 0),
            Pitch = rotation.Pitch + (offset.Rotation and offset.Rotation.Pitch or 0),
            Yaw = rotation.Yaw + (offset.Rotation and offset.Rotation.Yaw or 0)
          }
        ) then
      local newLoc = json.stringify(VectorToTable(actor:K2_GetActorLocation()))
      LogOutput("INFO", "Moved actor %s to %s", actor:GetFullName(), newLoc)
      return true
    end
  end
  return false
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
      -- Don't inherit camera pitch & roll
      rotation.Pitch = 0
      rotation.Roll = 0
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

-- Key bindings

local changeRate = 1.0
RegisterKeyBind(Key.PAGE_UP, { ModifierKey.CONTROL }, function()
  changeRate = changeRate * 10
  LogOutput("INFO", "Transform multiplier: %.1f", changeRate)
end)

RegisterKeyBind(Key.PAGE_DOWN, { ModifierKey.CONTROL }, function()
  changeRate = math.max(changeRate / 10, 0.1)
  LogOutput("INFO", "Transform multiplier: %.1f", changeRate)
end)

RegisterKeyBind(Key.LEFT_ARROW, { ModifierKey.CONTROL }, function()
  AddAssetTransformOffset { Translation = { X = -1 * changeRate, Y = 0, Z = 0 } }
end)

RegisterKeyBind(Key.RIGHT_ARROW, { ModifierKey.CONTROL }, function()
  AddAssetTransformOffset { Translation = { X = 1 * changeRate, Y = 0, Z = 0 } }
end)

RegisterKeyBind(Key.DOWN_ARROW, { ModifierKey.CONTROL }, function()
  AddAssetTransformOffset { Translation = { X = 0, Y = -1 * changeRate, Z = 0 } }
end)

RegisterKeyBind(Key.UP_ARROW, { ModifierKey.CONTROL }, function()
  AddAssetTransformOffset { Translation = { X = 0, Y = 1 * changeRate, Z = 0 } }
end)

RegisterKeyBind(Key.DOWN_ARROW, { ModifierKey.CONTROL, ModifierKey.SHIFT }, function()
  AddAssetTransformOffset { Translation = { X = 0, Y = 0, Z = -1 * changeRate } }
end)

RegisterKeyBind(Key.UP_ARROW, { ModifierKey.CONTROL, ModifierKey.SHIFT }, function()
  AddAssetTransformOffset { Translation = { X = 0, Y = 0, Z = 1 * changeRate } }
end)

RegisterKeyBind(Key.LEFT_ARROW, { ModifierKey.CONTROL, ModifierKey.ALT }, function()
  AddAssetTransformOffset { Rotation = { Roll = 0, Pitch = 0, Yaw = -1 * changeRate } }
end)

RegisterKeyBind(Key.RIGHT_ARROW, { ModifierKey.CONTROL, ModifierKey.ALT }, function()
  AddAssetTransformOffset { Rotation = { Roll = 0, Pitch = 0, Yaw = 1 * changeRate } }
end)

RegisterKeyBind(Key.DOWN_ARROW, { ModifierKey.CONTROL, ModifierKey.ALT }, function()
  AddAssetTransformOffset { Rotation = { Roll = 0, Pitch = -1 * changeRate, Yaw = 0 } }
end)

RegisterKeyBind(Key.UP_ARROW, { ModifierKey.CONTROL, ModifierKey.ALT }, function()
  AddAssetTransformOffset { Rotation = { Roll = 0, Pitch = 1 * changeRate, Yaw = 0 } }
end)

RegisterKeyBind(Key.DOWN_ARROW, { ModifierKey.CONTROL, ModifierKey.SHIFT, ModifierKey.ALT }, function()
  AddAssetTransformOffset { Rotation = { Roll = -1 * changeRate, Pitch = 0, Yaw = 0 } }
end)

RegisterKeyBind(Key.UP_ARROW, { ModifierKey.CONTROL, ModifierKey.SHIFT, ModifierKey.ALT }, function()
  AddAssetTransformOffset { Rotation = { Roll = 1 * changeRate, Pitch = 0, Yaw = 0 } }
end)

return {
  SpawnActor = SpawnActor,
  HandleSpawnActor = HandleSpawnActor,
  HandleDespawnActor = HandleDespawnActor
}
