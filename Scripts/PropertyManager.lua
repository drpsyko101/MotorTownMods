local json = require("JsonParser")

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

-- HTTP request handlers

---Handle request for all houses
---@type RequestPathHandler
local function HandleGetAllHouses(session)
  local houses = json.stringify {
    data = GetHouses()
  }
  return houses
end

return {
  HandleGetAllHouses = HandleGetAllHouses
}
