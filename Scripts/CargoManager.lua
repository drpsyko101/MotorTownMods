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
---@param limit number? Limit the number of results
local function GetDeliveryPoints(guid, fields, limit)
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
            MergeTables(data, GetObjectAsTable(deliveryPoint, value, "MTDeliveryPoint"))
          end
          data.DeliveryPointGuid = GuidToString(deliveryPoint.DeliveryPointGuid)
          table.insert(arr, data)
        else
          table.insert(arr, GetObjectAsTable(deliveryPoint, nil, "MTDeliveryPoint"))
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
      table.insert(data, GetObjectAsTable(value:get()))
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

return {
  HandleGetDeliveryPoints = HandleGetDeliveryPoints,
}
