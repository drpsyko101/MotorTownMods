local json = require("JsonParser")

---Get characters as JSON serializable table
---@param limit integer? Limit the amount of return data
---@param filters string[]? Filter return fields
---@param depth integer? Recursive search depth
local function GetCharacters(limit, filters, depth)
  local data = {}
  local gameState = GetMotorTownGameState()
  if gameState:IsValid() then
    for i = 1, #gameState.Characters do
      local character = gameState.Characters[i]

      if character:IsValid() then
        if filters then
          local innerData = {}
          for _, value in ipairs(filters) do
            table.insert(innerData, GetObjectAsTable(gameState.Characters[i], value, nil, depth))
          end
          table.insert(data, innerData)
        else
          table.insert(data, GetObjectAsTable(gameState.Characters[i], nil, "MTCharacter", depth))
        end

        if limit and #data >= limit then
          break
        end
      end
    end
  end
  return data
end

-- Register console commands

RegisterConsoleCommandHandler("getcharacters", function(Cmd, CommandParts, Ar)
  local limit = tonumber(CommandParts[1])
  local filters = SplitString(CommandParts[2])
  local data = GetCharacters(limit, filters)
  LogOutput("DEBUG", "%s: %s", Cmd, json.stringify(data))
  return true
end)

-- Handle HTTP requests

---Get all characters currently in-game
---@type RequestPathHandler
local function HandleGetCharacters(session)
  local limit = tonumber(session.queryComponents.limit) or nil
  local filters = SplitString(session.queryComponents.filters, ",")
  local depth = tonumber(session.queryComponents.depth)

  local data = GetCharacters(limit, filters, depth)
  return json.stringify { data = data }
end

return {
  HandleGetCharacters = HandleGetCharacters
}
