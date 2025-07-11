local config = require("ModConfig")
local json = require("JsonParser")

---Get the in game HUD widget
---@return UInGameHUDWidget
local function GetHudWidget()
  LogOutput("DEBUG", "Getting player controller")
  local PC = GetMyPlayerController()
  if PC:IsValid() then
    local HUD = PC:GetHUD()
    local hudClass = StaticFindObject("/Script/MotorTown.MotorTownInGameHUD")
    ---@cast hudClass UClass

    LogOutput("DEBUG", "Getting HUD")
    if HUD:IsValid() and HUD:IsA(hudClass) then
      ---@cast HUD AMotorTownInGameHUD

      LogOutput("DEBUG", "Getting HUD widget")
      local widget = HUD.HUDWidget
      if widget and widget:IsValid() then
        return widget
      end
    end
  end
  return CreateInvalidObject() ---@type UInGameHUDWidget
end

---Set widget opacity
---@param widget UUserWidget
---@param opacity number
local function SetWidgetOpacity(widget, opacity)
  if widget:IsValid() then
    LogOutput("DEBUG", "Setting %s visibility to %.1f", widget:GetFullName(), opacity)
    widget:SetRenderOpacity(opacity)
  end
end

---Set the widget visibility based on the mod configurations
---@param widget ModConfigKey Set widget correspond to the enum value
---@param inverse boolean? Set true to invert the mod config value
local function SetWidgetVisibility(widget, inverse)
  LogOutput("DEBUG", "Getting hud widget")
  local isVisible = config.GetModConfig(widget)
  local hudWidget = GetHudWidget()
  if hudWidget:IsValid() and type(isVisible) == "boolean" then
    local inGameWidgets = {} ---@type UUserWidget[]
    if inverse then
      isVisible = not isVisible
    end
    local useOpacity = true

    if widget == "showMiniMap" then
      table.insert(inGameWidgets, hudWidget.MinimapWidget)
      useOpacity = false
    elseif widget == "showQuest" then
      table.insert(inGameWidgets, hudWidget.QuestFrame)
    elseif widget == "showDrivingHud" then
      table.insert(inGameWidgets, hudWidget.DrivingHUD)
    elseif widget == "showControls" then
      table.insert(inGameWidgets, hudWidget.DrivingHUD.BlinkerRightControlWidget)
      table.insert(inGameWidgets, hudWidget.DrivingHUD.BlinkerLeftControlWidget)
      table.insert(inGameWidgets, hudWidget.DrivingHUD.LightWidget)
      table.insert(inGameWidgets, hudWidget.DrivingHUD.HazardWidget)
      table.insert(inGameWidgets, hudWidget.DrivingHUD.AutoPilotWidget)
      table.insert(inGameWidgets, hudWidget.DrivingHUD.SirenWidget)
      table.insert(inGameWidgets, hudWidget.DrivingHUD.DrivingModeWidget)
      table.insert(inGameWidgets, hudWidget.DrivingHUD.DiffLockModeWidget)
      table.insert(inGameWidgets, hudWidget.DrivingHUD.VirtualMirrorControlWidget)
    elseif widget == "showHotbar" then
      table.insert(inGameWidgets, hudWidget.QuickbarWidget)
    elseif widget == "showPlayerList" then
      table.insert(inGameWidgets, hudWidget.PlayerList)
    end

    for index, value in ipairs(inGameWidgets) do
      if value:IsValid() then
        LogOutput("DEBUG", "Setting %s visibility to %q", value:GetFullName(), isVisible)
        if useOpacity then
          SetWidgetOpacity(value, isVisible and 1 or 0)
        else
          value:SetVisibility(isVisible and 4 or 2)
        end
        config.SetModConfig(widget, isVisible)
      end
    end
  end
end

---Show a popup with the specified message
---@param message string Message to show to the player
---@param playerGuid? string The correspond player GUID. Will broadcast to all players if nil.
local function ShowMessagePopup(message, playerGuid)
  local playerControllers = {} ---@type APlayerController[]
  if playerGuid then
    table.insert(playerControllers, GetPlayerControllerFromGuid(playerGuid))
  else
    local gameState = GetMotorTownGameState()
    if gameState:IsValid() then
      gameState.PlayerArray:ForEach(function(index, element)
        local PS = element:get() ---@type APlayerState
        table.insert(playerControllers, PS:GetPlayerController())
      end)
    end
  end

  for index, value in ipairs(playerControllers) do
    if value:IsValid() then
      ---@cast value AMotorTownPlayerController

      local hud = value:GetHUD()
      if hud:IsValid() then
        ---@cast hud AMTHUD

        hud:ShowMessagePopup(FText(message))
      end
    end
  end
end

-- Handle HTTP requests

---Handle request to show message to player(s)
---@type RequestPathHandler
local function HandleShowPopupMessage(session)
  local content = json.parse(session.content)
  if content and type(content) == "table" then
    if content.message then
      ShowMessagePopup(content.message, content.playerGuid)
      return nil, nil, 204
    end
    return json.stringify { message = "No message provided" }, nil, 400
  end
  return nil, nil, 400
end

-- Console commands

---@type table<string, ModConfigKey>
local registerKeys = {
  toggleminimap = "showMiniMap",
  togglequest = "showQuest",
  toggledrivinghud = "showDrivingHud",
  togglecontrolhelper = "showControls",
  togglehotbar = "showHotbar",
  toggleplayerlist = "showPlayerList",
}
for key, value in pairs(registerKeys) do
  RegisterConsoleCommandHandler(key, function(Cmd, CommandParts, Ar)
    SetWidgetVisibility(value, true)
    return true
  end)
end

-- Register event hooks

-- Restore all previously set widget settings
RegisterHook("/Script/MotorTown.MotorTownPlayerController:ClientFirstTickResponse", function(self, ...)
  LogOutput("DEBUG", "Received widget update request")
  for key, value in pairs(registerKeys) do
    SetWidgetVisibility(value)
  end
end)

return {
  HandleShowPopupMessage = HandleShowPopupMessage
}
