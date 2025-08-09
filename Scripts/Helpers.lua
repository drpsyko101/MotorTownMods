local UEHelpers = require("UEHelpers")

local myPlayerControllerCache = CreateInvalidObject() ---@cast myPlayerControllerCache APlayerController
---Get my own PlayerController
---@return APlayerController
function GetMyPlayerController()
  if myPlayerControllerCache:IsValid() then
    return myPlayerControllerCache
  end

  local gameInstance = UEHelpers.GetGameInstance()
  if gameInstance:IsValid() and gameInstance.LocalPlayers and #gameInstance.LocalPlayers > 0 then
    local localPlayer = gameInstance.LocalPlayers[1]
    if localPlayer:IsValid() then
      myPlayerControllerCache = localPlayer.PlayerController
    end
  else
    local playerController = UEHelpers.GetPlayerController()
    if playerController:IsValid() then
      myPlayerControllerCache = playerController
    end
  end
  return myPlayerControllerCache
end

-- Importing functions to the global namespace of this mod just so that we don't have to retype 'UEHelpers.' over and over again.
local GetKismetSystemLibrary = UEHelpers.GetKismetSystemLibrary
local GetKismetMathLibrary = UEHelpers.GetKismetMathLibrary

local IsInitialized = false

local function Init()
  if not GetKismetSystemLibrary():IsValid() then error("KismetSystemLibrary not valid\n") end

  if not GetKismetMathLibrary():IsValid() then error("KismetMathLibrary not valid\n") end

  IsInitialized = true
end

Init()

---Get actor from hit result
---@param HitResult FHitResult
---@return AActor
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
  if selectedActor:IsValid() then return selectedActor end

  local wasHit, hitResult = GetHitResultFromCenterLineTrace()
  if wasHit then
    selectedActor = GetActorFromHitResult(hitResult)
    LogOutput("INFO", "Selected actor: %s", selectedActor:GetFullName())
  end
  return selectedActor
end

---Get a hit result from the camera center line trace
---@return boolean
---@return FHitResult
function GetHitResultFromCenterLineTrace()
  if not IsInitialized then return false, {} end

  local playerController = GetMyPlayerController()
  local playerPawn = playerController.Pawn
  local cameraManager = playerController.PlayerCameraManager
  local startVector = cameraManager:GetCameraLocation()
  local addValue = GetKismetMathLibrary():Multiply_VectorInt(
    GetKismetMathLibrary():GetForwardVector(cameraManager:GetCameraRotation()), 50000.0)
  local endVector = GetKismetMathLibrary():Add_VectorVector(startVector, addValue)
  local traceColor = {
    ["R"] = 0,
    ["G"] = 0,
    ["B"] = 0,
    ["A"] = 0,
  }
  local traceHitColor = traceColor
  local drawDebugTrace_Type_None = 0
  local traceTypeQuery_TraceTypeQuery1 = 0
  local actorsToIgnore = {
  }
  local hitResult = {}
  local wasHit = GetKismetSystemLibrary():LineTraceSingle(
    playerPawn,
    startVector,
    endVector,
    traceTypeQuery_TraceTypeQuery1,
    false,
    actorsToIgnore,
    drawDebugTrace_Type_None,
    hitResult,
    true,
    traceColor,
    traceHitColor,
    0.0
  )
  return wasHit, hitResult
end

local function DeselectActor()
  selectedActor = CreateInvalidObject()
  LogOutput("INFO", "Selected actor: none")
end

RegisterKeyBind(Key.F, { ModifierKey.CONTROL, ModifierKey.SHIFT }, GetSelectedActor)
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
---@param rotation FRotator
function RotatorToTable(rotation)
  return {
    Pitch = rotation.Pitch,
    Yaw = rotation.Yaw,
    Roll = rotation.Roll
  }
end

---Convert FGuid to string
---@param guid FGuid
function GuidToString(guid)
  if type(guid) == "table" then return "0000" end

  local rawGuid = { guid.A, guid.B, guid.C, guid.D }
  local strGuid = ""
  for index, value in ipairs(rawGuid) do
    -- string.format doesn't support negative hexadecimal conversion
    -- So we overflow it until it becomes positive
    if value < 0 then
      rawGuid[index] = rawGuid[index] + 0x100000000
    end
    strGuid = string.format("%s%08X", strGuid, rawGuid[index])
  end
  return strGuid
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

---Get net player state unique net ID as string
---@param playerState APlayerState
---@return string?
function GetUniqueNetIdAsString(playerState)
  if playerState:IsValid() then
    local status, output = pcall(function()
      -- Attempt to call the function registerd in C++
      ---@diagnostic disable-next-line: undefined-global
      return ExportStructAsText(playerState, "UniqueID")
    end)
    if status then
      return output
    end
  end
  return nil
end

---Get the player controller given the unique net ID
---@param uniqueId string Player state unique net ID
function GetPlayerControllerFromUniqueId(uniqueId)
  local gameState = GetMotorTownGameState()
  if gameState:IsValid() then
    for i = 1, #gameState.PlayerArray, 1 do
      local PS = gameState.PlayerArray[i]
      ---@cast PS AMotorTownPlayerState

      if PS:IsValid() then
        local id = GetUniqueNetIdAsString(PS)
        if id == uniqueId then
          return PS:GetPlayerController()
        end
      end
    end
  end
  return CreateInvalidObject() ---@type APlayerController
end

---@deprecated Use `GetPlayerControllerFromUniqueId` to prevent dupes
---Get the player controller given the GUID
---@param guid string
function GetPlayerControllerFromGuid(guid)
  local gameState = GetMotorTownGameState()
  if gameState:IsValid() then
    for i = 1, #gameState.PlayerArray, 1 do
      local PS = gameState.PlayerArray[i]
      ---@cast PS AMotorTownPlayerState
      if PS:IsValid() and GuidToString(PS.CharacterGuid) == guid then
        return PS:GetPlayerController()
      end
    end
  end
  return CreateInvalidObject() ---@type APlayerController
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

    -- Split input string into 4 parts, 8 characters long hexadecimal
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

---Split string by the separator.
---Returns `nil` if input is `nil` or empty.
---@param inputstr string Input string
---@param sep string? Separator character(s). Defaults to a whitespace.
---@return string[]?
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

---@deprecated Use `GetPlayerUniqueId` to prevent dupes
---Get a player controller guid
---@param playerController APlayerController
function GetPlayerGuid(playerController)
  if not playerController:IsValid() then return nil end

  local playerState = playerController.PlayerState
  ---@cast playerState AMotorTownPlayerState

  if not playerState:IsValid() then return nil end

  return GuidToString(playerState.CharacterGuid)
end

---Get player unique net ID
---@param playerController APlayerController
function GetPlayerUniqueId(playerController)
  if playerController:IsValid() then
    local PS = playerController.PlayerState
    if PS:IsValid() then
      local id = GetUniqueNetIdAsString(PS)
      return id
    end
  end
  return nil
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

---Attempt to load a module, otherwise returns nil.
---This method does not automatically resolve the module completion.
---You may need to set the `@type` manually.
---@param moduleName string
function RequireSafe(moduleName)
  local hasModule, module = pcall(require, moduleName)
  if hasModule then
    return module
  end
  return nil
end

---Merge two tables together, overwriting base table values with the appended table values recursively
---@param base table
---@param append table
---@return table
function MergeTables(base, append)
  for k, v in pairs(append) do
    if type(v) == "table" then
      if type(base[k] or false) == "table" then
        MergeTables(base[k] or {}, append[k] or {})
      else
        base[k] = v
      end
    else
      base[k] = v
    end
  end
  return base
end

---Get object as JSON serializable table
---@param object UObject
---@param field string? Optional field to serialize, if not specified, all variables are returned. This will search for all property in chain, overriding `className` parameter.
---@param className string? Filter variables to a specific simple class name like `MotorTownGameState`. Ignored when `field` parameter is set.
---@param depth integer? Recursive depth limit
---@return table
function GetObjectAsTable(object, field, className, depth)
  ---@diagnostic disable-next-line: undefined-global
  local status, output = pcall(GetObjectVariables, object, field, className, depth)
  if status then return output end
  LogOutput("WARN", "Failed to get object as table: %s", output)
  return {}
end

---Get struct as JSON serializable tables
---@param struct any
---@param depth integer? Recursive search depth
---@return table
function GetStructAsTable(struct, depth)
  ---@diagnostic disable-next-line: undefined-global
  local status, output = pcall(GetStructVariables, struct, depth)
  if status then return output end
  LogOutput("WARN", "Failed to get struct as table: %s", output)
  return {}
end

---CHeck if table contains value
---@param table table
---@param value any
function ListContains(table, value)
  if type(table) == "table" then
    if #table > 0 then
      for i, v in ipairs(table) do
        if v == value then
          return true
        end
      end
    end
  end
  return false
end

local socket = RequireSafe("socket") ---@type Socket?
---Halts CPU operation for the given duration
---@param ms integer Duration to sleep in miliseconds
function Sleep(ms)
  if ms ~= 0 then
    if socket then
      socket.sleep(ms / 1000)
    else
      ---@diagnostic disable-next-line:undefined-global
      local status = pcall(NativeSleep, ms)
      if not status then
        LogOutput("WARN", "Failed to use native sleep")
      end
    end
  end
end

---Execute given function in the GameThread
---@param exec fun()
function ExecuteInGameThreadSync(exec)
  local isProcessing = true
  ExecuteInGameThread(function()
    exec()
    isProcessing = false
  end)

  while isProcessing do
    Sleep(1)
  end
end
