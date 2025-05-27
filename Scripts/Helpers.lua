local UEHelpers = require("UEHelpers")

---Convert FVector to string
---@param vector FVector
function VectorToString(vector)
  return string.format('{"X":%.3f,"Y":%.3f,"Z":%.3f}', vector.X, vector.Y, vector.Z)
end

---Convert FRotator to string
---@param rotation FQuat
function RotatorToString(rotation)
  return string.format('{"W":%.3f,"X":%.3f,"Y":%.3f,"Z":%.3f}', rotation.W, rotation.X, rotation.Y, rotation.Z)
end

---Convert FTransform to string
---@param transform FTransform
function TransformToString(transform)
  local location = VectorToString(transform.Translation)
  local rotation = RotatorToString(transform.Rotation)
  local scale = VectorToString(transform.Scale3D)
  return string.format('{"Location":%s,"Rotation":%s,"Scale":%s}', location, rotation, scale)
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

---Convert FMTRoute to JSON serializable table
---@param route FMTRoute
function RouteToTable(route)
  local data = {}

  data.RouteName = route.RouteName:ToString()
  data.Waypoints = {}
  for i = 1, #route.Waypoints, 1 do
    table.insert(data.Waypoints, TransformToString(route.Waypoints[i]))
  end
  return data
end
