local json = require("JsonParser")
local webhook = require("Webclient")

---Get all companies or selected company by given GUID
---@param id string?
---@param depth integer?
---@return table|table[]
local function GetCompanies(id, depth)
  local gameState = GetMotorTownGameState()
  if gameState:IsValid() then
    local comp = gameState.Net_CompanySystem
    if comp:IsValid() then
      local field = "Server_Companies"
      local companies = GetObjectAsTable(gameState.Net_CompanySystem, field, nil, depth)[field] or {}

      if id then
        for _, company in ipairs(companies) do
          if company.Guid == id then
            return company
          end
        end
      else
        return companies
      end
    end
  end
  return {}
end

---Get depots
---@param id string? Optional depot building GUID
---@param depth integer? Recursive search depth
---@return table|table[]
local function GetDepots(id, depth)
  local gameState = GetMotorTownGameState()
  if gameState:IsValid() then
    local comp = gameState.Net_CompanySystem
    if comp:IsValid() then
      local field = "Net_Depots"
      local depots = GetObjectAsTable(comp, field, nil, depth)[field] or {}

      if id then
        for _, depot in ipairs(depots) do
          if depot.BuildingGuid == id then
            return depot
          end
        end
      else
        return depots
      end
    end
  end
  return {}
end

---Get company bus route by company ID and route ID
---@param companyId string
---@param routeId string?
---@return table|table[]
local function GetCompanyBusRoute(companyId, routeId)
  local company = GetCompanies(companyId, 4)
  if next(company) == nil then
    return {}
  end

  local data = {}
  for _, route in ipairs(company.BusRoutes) do
    if routeId and route.Guid == routeId then
      return route
    end

    table.insert(data, route)
  end

  return data
end

local function GetCompanyTructRoute(companyId, routeId)
  local company = GetCompanies(companyId, 4)
  if next(company) == nil then
    return {}
  end

  local data = {}
  for _, route in ipairs(company.TruckRoutes) do
    if routeId and route.Guid == routeId then
      return route
    end

    table.insert(data, route)
  end

  return data
end

-- Register event callbacks

webhook.RegisterEventHook("ServerCreateCompany", function(context, CompanyName, bIsCorporation, Money)
  local PC = context:get() ---@type AMotorTownPlayerController
  local name = CompanyName:get() ---@type FString
  local isCorp = bIsCorporation:get() ---@type boolean
  local money = Money:get() ---@type integer

  LogOutput("DEBUG", "A new %s %s is created", bIsCorporation and "corporation" or "company", name:ToString())

  return {
    PlayerId = GetPlayerUniqueId(PC),
    CompanyName = name:ToString(),
    bIsCorporation = isCorp,
    Money = money,
  }
end)

webhook.RegisterEventHook("ServerCloseDownCompany", function(context, CompanyGuid)
  local PC = context:get() ---@type AMotorTownPlayerController
  local guid = GuidToString(CompanyGuid:get())

  LogOutput("DEBUG", "A company/corporation %s has closed down", guid)

  return {
    PlayerId = GetPlayerUniqueId(PC),
    CompanyGuid = guid,
  }
end)

webhook.RegisterEventHook("ServerRequestJoinCompany", function(context, CompanyGuid)
  local PC = context:get() ---@type AMotorTownPlayerController
  local guid = GuidToString(CompanyGuid:get())
  local playerId = GetPlayerUniqueId(PC)

  LogOutput("DEBUG", "Player %s requested to join company/corporation %s", playerId, guid)

  return {
    PlayerId = playerId,
    CompanyGuid = guid,
  }
end)

webhook.RegisterEventHook("ServerDenyCompanyJoinRequest", function(context, CompanyGuid, JoinRequest)
  local PC = context:get() ---@type AMotorTownPlayerController
  local guid = GuidToString(CompanyGuid:get())
  local req = JoinRequest:get() ---@type FMTCompanyJoinRequest

  LogOutput("DEBUG", "Player %s denied to join company %s", req.CharacterId.UniqueNetId:ToString(), guid)

  return {
    PlayerId = GetPlayerUniqueId(PC),
    CompanyGuid = guid,
    JoinRequest = {
      CharacterId = {
        CharacterGuid = GuidToString(req.CharacterId.CharacterGuid),
        UniqueNetId = req.CharacterId.UniqueNetId:ToString(),
      },
      CharacterName = req.CharacterName:ToString()
    }
  }
end)

-- Handle HTTP requests

---Handle request to get all or specific company
---@type RequestPathHandler
local function HandleGetCompanies(session)
  local companyGuid = session.pathComponents[2]
  local depth = tonumber(session.queryComponents.depth)

  local companies = GetCompanies(companyGuid, depth)

  if companyGuid and next(companies) == nil then
    return json.stringify { message = string.format("Company with %s GUID not found", companyGuid) }, nil, 404
  end

  return json.stringify { data = companies }
end

---Handle request to get all depots
---@type RequestPathHandler
local function HandleGetDepots(session)
  local depots = GetDepots()
  return json.stringify { data = depots }
end

---Handle get company depots request
---@type RequestPathHandler
local function HandleGetCompanyDepots(session)
  local guid = session.pathComponents[2]
  local buildingGuid = session.pathComponents[4]
  local depth = tonumber(session.queryComponents.depth)

  local depots = GetDepots(nil, depth)
  local data = {}
  for _, depot in ipairs(depots) do
    if depot.CompanyGuid == guid then
      if buildingGuid and depot.BuildingGuid == buildingGuid then
        return json.stringify { data = depot }
      end
      table.insert(data, depot)
    end
  end
  if buildingGuid and #data == 0 then
    return json.stringify { message = string.format("Depot with GUID %s not found", buildingGuid) }, nil, 404
  end
  return json.stringify { data = data }
end

---Handle request to get company vehicles
---@type RequestPathHandler
local function HandleGetCompanyVehicles(session)
  local companyGuid = session.pathComponents[2]
  local company = GetCompanies(companyGuid, 3)

  if #company == 0 then
    return json.stringify { error = string.format("Company with GUID %s not found", companyGuid) }, nil, 404
  end

  local vehicles = company.Vehicles or {} ---@type table[]
  return json.stringify { data = vehicles }
end

---Handle request to get company bus routes
---@type RequestPathHandler
local function HandleGetCompanyBusRoutes(session)
  local companyGuid = session.pathComponents[2]
  local routeId = session.pathComponents[4]
  local routes = GetCompanyBusRoute(companyGuid, routeId)

  if routeId and next(routes) == nil then
    local msg = string.format("Bus route with ID %s not found for company with GUID %s", routeId, companyGuid)
    return json.stringify { error = msg }, nil, 404
  end

  if #routes == 0 then
    local msg = string.format("No bus routes found for company with GUID %s", companyGuid)
    return json.stringify { error = msg }, nil, 404
  end

  return json.stringify { data = routes }
end

---Handle request to get company truck routes
---@type RequestPathHandler
local function HandleGetCompanyTruckRoutes(session)
  local companyGuid = session.pathComponents[2]
  local routeId = session.pathComponents[4]
  local routes = GetCompanyTructRoute(companyGuid, routeId)

  if routeId and next(routes) == nil then
    local msg = string.format("Truck route with ID %s not found for company with GUID %s", routeId, companyGuid)
    return json.stringify { error = msg }, nil, 404
  end

  if #routes == 0 then
    local msg = string.format("No truck routes found for company with GUID %s", companyGuid)
    return json.stringify { error = msg }, nil, 404
  end

  return json.stringify { data = routes }
end

return {
  HandleGetCompanies = HandleGetCompanies,
  HandleGetCompanyDepots = HandleGetCompanyDepots,
  HandleGetCompanyVehicles = HandleGetCompanyVehicles,
  HandleGetDepots = HandleGetDepots,
  HandleGetCompanyBusRoutes = HandleGetCompanyBusRoutes,
  HandleGetCompanyTruckRoutes = HandleGetCompanyTruckRoutes,
}
