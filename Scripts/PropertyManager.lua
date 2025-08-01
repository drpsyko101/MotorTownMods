local json = require("JsonParser")
local assetManager = require("AssetManager")

---Get all houses
---@param guid string? Filter by house GUID
---@param filters string[]? Fields to filter with
---@param depth integer? Recursive search depth
---@return table[]
local function GetHouses(guid, filters, depth)
  local gameState = GetMotorTownGameState()
  local arr = {}

  if gameState:IsValid() then
    for i = 1, #gameState.Houses do
      local house = gameState.Houses[i]
      local data = {}

      if guid and guid:upper() == GuidToString(house.HouseGuid) then
        goto continue
      end

      if filters then
        for _, value in ipairs(filters) do
          MergeTables(data, GetObjectAsTable(house, value, nil, depth))
        end
        -- Always include house GUID in the result
        data.HouseGuid = GuidToString(house.HouseGuid)
      else
        data = GetObjectAsTable(house, nil, "MTHouse", depth)
      end

      table.insert(arr, data)

      :: continue ::
    end
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
  local housePath = "/Game/Objects/Housing/House.House_C"
  local gameState = GetMotorTownGameState()
  local status, assetTag, actor = assetManager.SpawnActor(housePath, location, rotation)

  if status and actor and actor:IsValid() and gameState:IsValid() then
    ---@cast actor AMTHouse

    actor.AreaSize = houseParam.AreaSize
    actor.HousegKey = FName(houseParam.HouseKey)
    actor.HouseGuid = StringToGuid(houseParam.HouseGuid)

    local guid = GuidToString(actor.HouseGuid)
    actor.Tags[#actor.Tags + 1] = FName(guid)

    LogOutput("INFO", "Spawned a new house: %s", actor:GetFullName())

    return true, guid
  end
  return false
end

-- HTTP request handlers

---Handle request for all houses
---@type RequestPathHandler
local function HandleGetHouses(session)
  local guid = session.pathComponents[2]

  local houses = GetHouses(guid)
  return json.stringify { data = houses }
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
  HandleGetHouses = HandleGetHouses,
  HandleSpawnHouse = HandleSpawnHouse
}
