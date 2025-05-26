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

---Convert FMTCharacterId to strings
---@param characterId FMTCharacterId
function CharacterIdToString(characterId)
  local guid = GuidToString(characterId.CharacterGuid)
  local netId = characterId.UniqueNetId:ToString()
  return string.format('{"CharacterGuid":"%s","UniqueNetId":"%s"}', guid, netId)
end

---Convert FMTShadowedInt64 to string
---@param reward FMTShadowedInt64
function RewardToString(reward)
  return string.format('{"BaseValue":%d,"ShadowedValue":%d}', reward.BaseValue, reward.ShadowedValue)
end

---Convert simple object type to JSON encoded string
---@param data table<string, any>
function SimpleJsonSerializer(data)
  local res = {}
  for key, value in pairs(data) do
    local _val = ""
    if type(value) == "number" or type(value) == "boolean" then
      _val = tostring(value)
    elseif (string.sub(value, 1, 1) == "{" and string.sub(value, -1, -1) == "}") or (string.sub(value, 1, 1) == "[" and string.sub(value, -1, -1) == "]") then
      _val = value
    else
      _val = string.format('"%s"', value)
    end

    table.insert(res, string.format('"%s":%s', key, _val))
  end
  return string.format("{%s}", table.concat(res, ","))
end

---Convert FMTRoute to string
---@param route FMTRoute
function RouteToJson(route)
  local data = {}

  data.RouteName = route.RouteName:ToString()

  local arr = {}
  for i = 1, #route.Waypoints, 1 do
    table.insert(arr, TransformToString(route.Waypoints[i]))
  end
  data.Waypoints = string.format("[%s]", table.concat(arr, ","))
  return SimpleJsonSerializer(data)
end
