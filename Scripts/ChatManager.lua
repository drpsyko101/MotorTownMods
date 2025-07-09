local json = require("JsonParser")
local webhook = require("Webclient")

-- Register webhook

local serverSendChat = "/Script/MotorTown.MotorTownPlayerController:ServerSendChat"
RegisterHook(
  serverSendChat,
  function(context, message, category)
    local PC = context:get() ---@cast PC APlayerController

    if not PC:IsValid() then return end

    local PS = PC.PlayerState ---@cast PS AMotorTownPlayerState

    if not PS:IsValid() then return end

    local data = {
      Sender = GuidToString(PS.CharacterGuid),
      Message = message:get():ToString(),
      Category = category:get()
    }

    LogOutput("DEBUG", json.stringify(data))
    webhook.CreateEventWebhook(serverSendChat, data)
  end
)
