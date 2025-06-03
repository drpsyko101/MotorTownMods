local UEHelpers = require("UEHelpers")

-- Importing functions to the global namespace of this mod just so that we don't have to retype 'UEHelpers.' over and over again.
local GetKismetSystemLibrary = UEHelpers.GetKismetSystemLibrary
local GetKismetMathLibrary = UEHelpers.GetKismetMathLibrary
local GetPlayerController = UEHelpers.GetPlayerController

local IsInitialized = false

local function Init()
  if not GetKismetSystemLibrary():IsValid() then error("KismetSystemLibrary not valid\n") end

  if not GetKismetMathLibrary():IsValid() then error("KismetMathLibrary not valid\n") end

  IsInitialized = true
end

Init()

local function GetActorFromHitResult(HitResult)
  if UnrealVersion:IsBelow(5, 0) then
    return HitResult.Actor:Get()
  elseif UnrealVersion:IsBelow(5, 4) then
    return HitResult.HitObjectHandle.Actor:Get()
  else
    return HitResult.HitObjectHandle.ReferenceObject:Get()
  end
end

local selectedActor = CreateInvalidObject()
---@cast selectedActor AActor

---Get selected actor
---@return AActor
function GetSelectedActor()
  return selectedActor
end

---Get actor from line trace
local function GetObjectFromLineTrace()
  if not IsInitialized then return selectedActor end

  local PlayerController = GetPlayerController()
  local PlayerPawn = PlayerController.Pawn
  local CameraManager = PlayerController.PlayerCameraManager
  local StartVector = CameraManager:GetCameraLocation()
  local AddValue = GetKismetMathLibrary():Multiply_VectorInt(
    GetKismetMathLibrary():GetForwardVector(CameraManager:GetCameraRotation()), 50000.0)
  local EndVector = GetKismetMathLibrary():Add_VectorVector(StartVector, AddValue)
  local TraceColor = {
    ["R"] = 0,
    ["G"] = 0,
    ["B"] = 0,
    ["A"] = 0,
  }
  local TraceHitColor = TraceColor
  local EDrawDebugTrace_Type_None = 0
  local ETraceTypeQuery_TraceTypeQuery1 = 0
  local ActorsToIgnore = {
  }
  local HitResult = {}
  local WasHit = GetKismetSystemLibrary():LineTraceSingle(
    PlayerPawn,
    StartVector,
    EndVector,
    ETraceTypeQuery_TraceTypeQuery1,
    false,
    ActorsToIgnore,
    EDrawDebugTrace_Type_None,
    HitResult,
    true,
    TraceColor,
    TraceHitColor,
    0.0
  )

  if WasHit then
    selectedActor = GetActorFromHitResult(HitResult)
    LogMsg("Selected actor: " .. selectedActor:GetFullName())
    return
  end
  selectedActor = CreateInvalidObject()
end

local function DeselectActor()
  selectedActor = CreateInvalidObject()
  LogMsg("Selected actor: none")
end

RegisterKeyBind(Key.F, { ModifierKey.CONTROL, ModifierKey.SHIFT }, GetObjectFromLineTrace)
RegisterKeyBind(Key.D, { ModifierKey.CONTROL, ModifierKey.SHIFT }, DeselectActor)
RegisterConsoleCommandHandler("deselectactor", function(Cmd, CommandParts, Ar)
  DeselectActor()
  return true
end)

---Convert FVector to JSON serializable table
---@param vector FVector
function VectorToTable(vector)
  return {
    X = vector.X,
    Y = vector.Y,
    Z = vector.Z
  }
end

---Convert FRotator to JSON serializable table
---@param rotation FQuat
function QuatToTable(rotation)
  return {
    W = rotation.W,
    X = rotation.X,
    Y = rotation.Y,
    Z = rotation.Z
  }
end

---Convert FRotator to JSON serializable table
---@param rotation FRotator
function RotatorToTable(rotation)
  return {
    Pitch = rotation.Pitch,
    Yaw = rotation.Yaw,
    Roll = rotation.Roll
  }
end

---Convert FTransform to JSON serializable table
---@param transform FTransform
function TransformToTable(transform)
  local location = VectorToTable(transform.Translation)
  local rotation = QuatToTable(transform.Rotation)
  local scale = VectorToTable(transform.Scale3D)
  return {
    Location = location,
    Rotation = rotation,
    Scale3D = scale
  }
end

---Convert FGuid to string
---@param guid FGuid
function GuidToString(guid)
  if type(guid) == "table" then return "0000" end

  local rawGuid = { guid.A, guid.B, guid.C, guid.D }
  local strGuid = ""
  for index, value in ipairs(rawGuid) do
    if value < 0 then
      rawGuid[index] = rawGuid[index] + 0x100000000
    end
    strGuid = string.format("%s%x", strGuid, rawGuid[index])
  end
  return strGuid:upper()
end

local MotorTownGameState = CreateInvalidObject()
---Get Motor Town GameState object
---@return AMotorTownGameState
function GetMotorTownGameState()
  if not MotorTownGameState:IsValid() then
    local gameState = UEHelpers:GetGameStateBase()
    local gameStateClass = StaticFindObject("/Script/MotorTown.MotorTownGameState")
    ---@cast gameStateClass UClass
    if gameState:IsValid() and gameState:IsA(gameStateClass) then
      MotorTownGameState = gameState
    end
  end
  return MotorTownGameState ---@type AMotorTownGameState
end

---Convert FMTCharacterId to JSON serializable table
---@param characterId FMTCharacterId
function CharacterIdToTable(characterId)
  return {
    CharacterGuid = GuidToString(characterId.CharacterGuid),
    UniqueNetId = characterId.UniqueNetId:ToString(),
  }
end

---Convert FMTShadowedInt64 to JSON serializable table
---@param reward FMTShadowedInt64
function RewardToTable(reward)
  return {
    BaseValue = reward.BaseValue,
    ShadowedValue = reward.ShadowedValue
  }
end

---@class Route
---@field RouteName string
---@field Waypoints TArray<FTransform>
local Route = {}

---Convert FMTRoute to JSON serializable table
---@param route FMTRoute
function RouteToTable(route)
  local data = {}

  data.RouteName = route.RouteName:ToString()
  data.Waypoints = {}
  route.Waypoints:ForEach(function(index, element)
    table.insert(data.Waypoints, TransformToTable(element:get()))
  end)
  return data
end

---Read file as strings
---@param path string
---@return string|nil
function ReadFileAsString(path)
  local file = io.open(path, "rb")
  if file then
    local content = file:read("*all")
    file:close()
    return content
  end
  return nil
end

---Convert string to FGuid. If no input is provided, a random Guid will be generated.
---@param input string?
---@return FGuid
function StringToGuid(input)
  local s = {}

  if input then
    if #input ~= 32 then
      error(input .. " is not a valid Guid")
    end

    for i = 1, #input, 8 do
      local a = input:sub(i, i + 8 - 1)
      table.insert(s, tonumber(a, 16))
    end
  else
    return {
      A = math.random(1000000000, 9999999999),
      B = math.random(1000000000, 9999999999),
      C = math.random(1000000000, 9999999999),
      D = math.random(1000000000, 9999999999)
    }
  end
  if #s == 4 then
    return {
      A = s[1],
      B = s[2],
      C = s[3],
      D = s[4]
    }
  end
  error(input .. " is not a valid Guid")
end

---Convert FGameplayTag to string
---@param gameplayTag FGameplayTag
function GameplayTagToString(gameplayTag)
  return gameplayTag.TagName:ToString()
end

---Convert FGameplayTagContainer to string
---@param gameplayTag FGameplayTagContainer
function GameplayTagContainerToString(gameplayTag)
  local arr = {}
  gameplayTag.GameplayTags:ForEach(function(index, element)
    table.insert(arr, element:get().TagName:ToString())
  end)
  return arr
end

---Convert FGameplayTagQuery to JSON serializable table
---@param query FGameplayTagQuery
function GameplayTagQueryToTable(query)
  local data = {}

  data.AutoDescription = query.AutoDescription:ToString()

  data.QueryTokenStream = {} ---@type number[]
  query.QueryTokenStream:ForEach(function(index, element)
    table.insert(data.QueryTokenStream, element:get())
  end)

  data.TagDictionary = {} ---@type string[]
  query.TagDictionary:ForEach(function(index, element)
    table.insert(data.TagDictionary, GameplayTagToString(element:get()))
  end)

  data.TokenStreamVersion = query.TokenStreamVersion
  data.UserDescription = query.UserDescription:ToString()

  return data
end

---Split string
---@param inputstr string
---@param sep string?
---@return string[]|nil
function SplitString(inputstr, sep)
  if inputstr == nil then return nil end
  -- if sep is null, set it as space
  if sep == nil then
    sep = '%s'
  end
  -- define an array
  local t = {}
  -- split string based on sep
  for str in string.gmatch(inputstr, '([^' .. sep .. ']+)')
  do
    -- insert the substring in table
    table.insert(t, str)
  end
  -- return the array
  return t
end

---Get a player controller guid
---@param playerController APlayerController
function GetPlayerGuid(playerController)
  if not playerController:IsValid() then return nil end

  local playerState = playerController.PlayerState
  ---@cast playerState AMotorTownPlayerState

  if not playerState:IsValid() then return nil end

  return GuidToString(playerState.CharacterGuid)
end

---Convert FColor to JSON serializable table
---@param color FColor
function ColorToTable(color)
  return {
    R = color.R,
    G = color.G,
    B = color.B,
    A = color.A
  }
end

---Converts FVector2D to JSON serializable table
---@param vector FVector2D
function Vector2DToTable(vector)
  return {
    X = vector.X,
    Y = vector.Y
  }
end

---Convert FMTSettingValue to JSON serializable table
---@param setting FMTSettingValue
function SettingValueToTable(setting)
  return {
    ValueType = setting.ValueType,
    FloatValue = setting.FloatValue,
    Int64Value = setting.Int64Value,
    BoolValue = setting.BoolValue,
    StringValue = setting.StringValue:ToString(),
    EnumValue = setting.EnumValue,
  }
end

---Convert FMTItemInventory to JSON serializable table
---@param item FMTItemInventory
function ItemInventoryToTable(item)
  local data = {}

  data.Slots = {}
  item.Slots:ForEach(function(index, element)
    table.insert(data.Slots, {
      Key = element:get().Key:ToString(),
      NumStack = element:get().NumStack
    })
  end)

  return data
end

---Deep set table value
---@param input table
---@param fields string[]
---@param value any
function RecursiveSetValue(input, fields, value)
  local field = table.remove(fields, 1)
  if input[field] ~= nil then
    if #fields == 0 then
      input[field] = value
    else
      RecursiveSetValue(input[field], fields, value)
    end
  else
    error("Invalid field value given")
  end
end
