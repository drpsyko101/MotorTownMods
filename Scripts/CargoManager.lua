local json = require("JsonParser")
local webhook = require("Webclient")

local _deliverySystem = CreateInvalidObject()
---Get Motor Town delivery system
local function GetDeliverySystem()
  local gameState = GetMotorTownGameState()
  if gameState:IsValid() and gameState.Net_DeliverySystem:IsValid() then
    local gameStateClass = StaticFindObject("/Script/MotorTown.MTDeliverySystem")
    ---@cast gameStateClass UClass
    if gameState.Net_DeliverySystem:IsA(gameStateClass) then
      _deliverySystem = gameState.Net_DeliverySystem
    end
  end
  return _deliverySystem ---@type AMTDeliverySystem
end

---Get delivery points
---@param guid string? Filter by delivery guid
---@param fields string[]? Filter by fields
---@param limit integer? Limit the number of results
---@param depth integer? Recursive search depth
local function GetDeliveryPoints(guid, fields, limit, depth)
  local deliverySystem = GetDeliverySystem()
  local arr = {} ---@type table[]

  if deliverySystem:IsValid() then
    for i = 1, #deliverySystem.DeliveryPoints, 1 do
      local deliveryPoint = deliverySystem.DeliveryPoints[i]
      if deliveryPoint:IsValid() then
        -- Filter by guid
        if guid and guid:upper() ~= GuidToString(deliveryPoint.DeliveryPointGuid) then
          goto continue
        end

        if fields then
          local data = {}
          for _, value in ipairs(fields) do
            MergeTables(data, GetObjectAsTable(deliveryPoint, value, nil, depth))
          end
          -- Always include delivery point GUID in the result
          data.DeliveryPointGuid = GuidToString(deliveryPoint.DeliveryPointGuid)
          table.insert(arr, data)
        else
          table.insert(arr, GetObjectAsTable(deliveryPoint, nil, "MTDeliveryPoint", depth))
        end

        -- Limit result if set
        if limit and #arr >= limit then
          return arr
        end

        ::continue::
      end
    end
  end
  return arr
end

---Get currently active deliveries
---@param id integer?
---@param depth integer?
local function GetDeliveries(id, depth)
  depth = depth or 2
  local data = {}
  local gameState = GetMotorTownGameState()
  if gameState:IsValid() and gameState.Net_DeliverySystem:IsValid() then
    data = GetObjectAsTable(gameState.Net_DeliverySystem, "Deliveries", nil, depth)
    if id then
      for _, delivery in ipairs(data) do
        ---@cast delivery FMTDelivery
        if id == delivery.ID then
          return delivery
        end
      end
    end
  end
  return data
end

-- Register event hooks

webhook.RegisterEventHook(
  "ServerAcceptDelivery",
  function(context, DeliveryId)
    return {
      PlayerId = GetPlayerUniqueId(context:get()),
      DeliveryId = DeliveryId:get()
    }
  end
)

webhook.RegisterEventHook(
  "ServerCargoArrived",
  function(context, Cargos)
    local playerId = GetPlayerUniqueId(context:get())
    local data = {}
    Cargos:get():ForEach(function(key, value)
      table.insert(data, GetObjectAsTable(value:get(), nil, "MTCargo"))
    end)
    return {
      PlayerId = playerId,
      Cargos = data
    }
  end
)

-- HTTP request handlers

---Handle GetDeliveryPoints request
---@type RequestPathHandler
local function HandleGetDeliveryPoints(session)
  local guid = session.pathComponents[3]
  local limit = nil ---@type number?

  if session.queryComponents.limit then
    limit = tonumber(session.queryComponents.limit)
  end

  local rawFilters = session.queryComponents.filters
  local filters = SplitString(rawFilters, ",")

  local data = GetDeliveryPoints(guid, filters, limit)
  if guid and #data == 0 then
    return json.stringify { message = string.format("Delivery point %s not found", guid) }, nil, 404
  end
  return json.stringify {
    data = data
  }
end

---Handle request for getting deliveries
---@type RequestPathHandler
local function HandleGetDeliveries(session)
  local id = tonumber(session.pathComponents[2])
  local depth = tonumber(session.queryComponents.depth)

  return json.stringify { data = GetDeliveries(id, depth) }
end

return {
  HandleGetDeliveryPoints = HandleGetDeliveryPoints,
  HandleGetDeliveries = HandleGetDeliveries,
}
