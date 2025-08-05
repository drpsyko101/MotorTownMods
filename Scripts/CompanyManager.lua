local json = require("JsonParser")
local webhook = require("Webclient")

---Get all companies or selected company by given GUID
---@param id string?
---@param depth integer?
local function GetCompanies(id, depth)
  local gameState = GetMotorTownGameState()
  if gameState:IsValid() then
    local comp = gameState.Net_CompanySystem
    if comp:IsValid() then
      local companies = GetObjectAsTable(gameState.Net_CompanySystem, "Server_Companies", "MTCompanySystem", depth)

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

  local company = GetCompanies(guid)

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

  local company = GetCompanies(companyGuid, depth)

  if companyGuid and #company == 0 then
    return json.stringify { message = string.format("Company with %s GUID not found", companyGuid) }, nil, 404
  end

  return json.stringify { data = company }
end

---Handle get company depots request
---@type RequestPathHandler
local function HandleGetCompanyDepots(session)
  local guid = session.pathComponents[2]
  local buildingGuid = session.pathComponents[4]
  local depth = tonumber(session.queryComponents.depth)

  local gameState = GetMotorTownGameState()
  if gameState:IsValid() then
    local comp = gameState.Net_CompanySystem
    if comp:IsValid() then
      local depots = GetObjectAsTable(comp, "Net_Depots", nil, depth)
      local data = {}

      for _, depot in ipairs(depots) do
        if depot.CompanyGuid == guid then
          if buildingGuid and buildingGuid == depot.BuildingGuid then
            return json.stringify { data = depot }
          end

          table.insert(data, depot)
        end
      end

      if buildingGuid then
        local msg = string.format("Building %s for company %s not found", buildingGuid, guid)
        return json.stringify { error = msg }, nil, 404
      end

      return json.stringify { data = data }
    end
  end
  error("Invalid game state/company system")
end

return {
  HandleGetCompanies = HandleGetCompanies,
  HandleGetCompanyDepots = HandleGetCompanyDepots,
}
