local json = require("JsonParser")
local webhook = require("Webclient")

---Announce a message to the whole server
---@param message string
---@param playerId string?
---@param pinned boolean?
local function AnnounceServerMessage(message, playerId, pinned)
  local PC = CreateInvalidObject()
  if playerId then
    PC = GetPlayerControllerFromUniqueId(playerId)
  else
    local gameState = GetMotorTownGameState()
    if gameState:IsValid() then
      for i = 1, #gameState.PlayerArray do
        local PS = gameState.PlayerArray[i]

        if PS:IsValid() then
          ---@cast PS AMotorTownPlayerState

          if PS.bIsAdmin then
            PC = PS:GetPlayerController()
          end
        end
      end
    end
  end

  if PC:IsValid() then
    ---@cast PC AMotorTownPlayerController

    ExecuteInGameThread(function()
      if pinned then
        PC:ServerAnnouncePinned(message)
      else
        PC:ServerAnnounce(message)
      end
    end)
    local id = GetPlayerUniqueId(PC)
    return true, id
  elseif pinned then
    local gameState = GetMotorTownGameState()
    if gameState:IsValid() then
      gameState.Net_ServerConfig.PinnedAnnounce = message
      return true
    end
  end
  return false
end

-- Handle HTTP requests

---Handle announce request
---@type RequestPathHandler
local function HandleAnnounceMessage(session)
  local data = json.parse(session.content)

  if data and type(data) == "table" then
    if data.message then
      if type(data.message) == "string" then
        local status, id = AnnounceServerMessage(data.message, data.playerId, data.isPinned)
        if status then
          return json.stringify { status = "ok", playerId = id }
        end
        return json.stringify { message = "Failed to send message" }, nil, 400
      else
        return json.stringify { message = "Invalid message field specified" }, nil, 400
      end
    else
      return json.stringify { message = "No message field specified" }, nil, 400
    end
  end
  return json.stringify { message = "Invalid request content" }, nil, 400
end

-- Register webhook

webhook.RegisterEventHook(
  "ServerSendChat",
  function(context, message, category)
    local PC = context:get() ---@cast PC APlayerController

    if not PC:IsValid() then return end

    local PS = PC.PlayerState ---@cast PS AMotorTownPlayerState

    if not PS:IsValid() then return end

    return {
      Sender = GetPlayerUniqueId(PC),
      Message = message:get():ToString(),
      Category = category:get()
    }
  end
)

return {
  HandleAnnounceMessage = HandleAnnounceMessage
}
