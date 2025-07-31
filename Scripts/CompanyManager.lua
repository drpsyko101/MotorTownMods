local json = require("JsonParser")

---Get all companies or selected company by given GUID
---@param id string?
---@param filter string[]?
---@param limit integer?
local function GetCompanies(id, filter, limit)
  local gameState = GetMotorTownGameState()
  if gameState:IsValid() then
    local comp = gameState.Net_CompanySystem
    if comp:IsValid() then
      if filter then
        local data = {}
        for _, value in ipairs(filter) do
          MergeTables(data, GetObjectAsTable(gameState.Net_CompanySystem, value, "MTCompanySystem"))
        end
      end
      return GetObjectAsTable(gameState.Net_CompanySystem, nil, "MTCompanySystem")
    end
  end
  return {}
end

-- Handle HTTP requests

---Handle request to get all or specific company
---@type RequestPathHandler
local function HandleGetCompanies(session)
  local companyGuid = session.pathComponents[2]
  local filters = SplitString(session.queryComponents.filters)
  local limit = tonumber(session.queryComponents.limit)

  local company = GetCompanies(companyGuid, filters, limit)

  if companyGuid and #company == 0 then
    return json.stringify { message = string.format("Company with %s GUID not found", companyGuid) }, nil, 404
  end

  return json.stringify { data = company }
end

return {
  HandleGetCompanies = HandleGetCompanies
}
