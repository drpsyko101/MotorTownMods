local UEHelpers = require("UEHelpers")

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
function RotatorToTable(rotation)
  return {
    W = rotation.W,
    X = rotation.X,
    Y = rotation.Y,
    Z = rotation.Z
  }
end

---Convert FTransform to JSON serializable table
---@param transform FTransform
function TransformToTable(transform)
  local location = VectorToTable(transform.Translation)
  local rotation = RotatorToTable(transform.Rotation)
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
