local UEHelper = require("UEHelpers")
local json = require("JsonParser")
local socket = require("socket")

---Convert house to JSON serializable table
---@param house AMTHouse
local function HouseToTable(house)
  local data = {}

  data.AreaSize = VectorToTable(house.AreaSize)
  data.FenceStep = house.FenceStep
  data.HousegKey = house.HousegKey:ToString()
  data.Net_OwnerUniqueNetId = house.Net_OwnerUniqueNetId:ToString()
  data.Net_OwnerCharacterGuid = GuidToString(house.Net_OwnerCharacterGuid)
  data.Net_OwnerName = house.Net_OwnerName:ToString()
  data.Net_RentLeftTimeSeconds = house.Net_RentLeftTimeSeconds
  data.ForSale = house.ForSale:IsValid()
  data.Teleport = nil
  data.Location = VectorToTable(house:K2_GetActorLocation())
  data.Rotation = RotatorToTable(house:K2_GetActorRotation())

  if house.Teleport:IsValid() then
    data.Teleport = VectorToTable(house.Teleport:K2_GetActorLocation())
  end

  return data
end

---Get all houses
---@return table[]
local function GetHouses()
  local gameState = GetMotorTownGameState()
  local arr = {}

  if gameState:IsValid() then
    gameState.Houses:ForEach(function(index, element)
      table.insert(arr, HouseToTable(element:get()))
    end)
  end

  return arr
end

---Create a house at specified location
---@param location FVector
---@param rotation FRotator
---@param houseParam { AreaSize: FVector, HouseKey: string, HouseGuid: string }
---@return boolean Status
---@return string? HouseGuid
local function SpawnHouse(location, rotation, houseParam)
  local world = UEHelper.GetWorld()
  local gameState = GetMotorTownGameState()
  local isProcessing = true
  local actor = CreateInvalidObject() ---@cast actor AActor

  if world:IsValid() and gameState:IsValid() then
    ExecuteInGameThread(function()
      pcall(function()
        local housePath = "/Game/Objects/Housing/House.House_C"
        LoadAsset(housePath)

        local houseClass = StaticFindObject(housePath)
        ---@cast houseClass UClass

        ---@type AActor
        actor = world:SpawnActor(
          houseClass,
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
      ---@cast actor AMTHouse

      actor.AreaSize = houseParam.AreaSize
      actor.HousegKey = FName(houseParam.HouseKey)
      actor.HouseGuid = StringToGuid(houseParam.HouseGuid)

      local guid = GuidToString(actor.HouseGuid)
      actor.Tags[#actor.Tags + 1] = FName(guid)

      LogMsg("Spawned a new house: " .. actor:GetFullName())
      gameState.Houses[#gameState.Houses + 1] = actor

      return true, guid
    end
  end
  return false
end

-- HTTP request handlers

---Handle request for all houses
---@type RequestPathHandler
local function HandleGetAllHouses(session)
  local houses = json.stringify {
    data = GetHouses()
  }
  return houses
end

---Handle request for spawning a new house for sale
---@type RequestPathHandler
local function HandleSpawnHouse(session)
  local data = json.parse(session.content)

  if data ~= nil and data.Location and data.Rotation and data.HouseParam then
    local status, guid = SpawnHouse(data.Location, data.Rotation, data.HouseParam)
    if status and guid then
      return json.stringify { data = { HouseGuid = guid } }, nil, 201
    end
  end

  return nil, nil, 400
end

return {
  HandleGetAllHouses = HandleGetAllHouses,
  HandleSpawnHouse = HandleSpawnHouse
}
