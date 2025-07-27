local config = require("ModConfig")
local json = require("JsonParser")

local hotbarInitialPos = { X = 0.0, Y = 0.0 } ---@type FVector2D

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

---Get hot bar canvas slot
---@return UCanvasPanelSlot
local function GetHotBarCanvasSlot()
  local widget = GetHudWidget()
  if widget:IsValid() then
    local slot = widget.QuickbarWidget.Slot
    local canvasSlotClass = StaticFindObject("/Script/UMG.CanvasPanelSlot")
    ---@cast canvasSlotClass UClass

    if slot:IsValid() and slot:IsA(canvasSlotClass) then
      ---@cast slot UCanvasPanelSlot
      return slot
    end
  end
  return CreateInvalidObject() ---@type UCanvasPanelSlot
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

    for _, value in ipairs(inGameWidgets) do
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
---@param uniqueId string|string[]|nil The correspond player state unique net ID. Will broadcast to all players if `nil`.
local function ShowMessagePopup(message, uniqueId)
  local playerControllers = {} ---@type APlayerController[]
  if uniqueId then
    if type(uniqueId) == "string" then
      table.insert(playerControllers, GetPlayerControllerFromUniqueId(uniqueId))
    elseif type(uniqueId) == "table" then
      for _, value in ipairs(uniqueId) do
        table.insert(playerControllers, GetPlayerControllerFromUniqueId(value))
      end
    end
  else
    local gameState = GetMotorTownGameState()
    if gameState:IsValid() then
      gameState.PlayerArray:ForEach(function(index, element)
        local PS = element:get() ---@type APlayerState
        table.insert(playerControllers, PS:GetPlayerController())
      end)
    end
  end

  ExecuteInGameThread(function()
    for _, value in ipairs(playerControllers) do
      if value:IsValid() then
        ---@cast value AMotorTownPlayerController

        value:ClientShowPopupMessage(FText(message))
      end
    end
  end)
end

---Set hot bar position
---@param position HotBarLocation
local function SetHotBarPosition(position)
  local slot = GetHotBarCanvasSlot()
  if slot:IsValid() then
    if position == "default" then
      slot:SetAnchors { Minimum = { X = 1.0, Y = 1.0 }, Maximum = { X = 1.0, Y = 1.0 } }
      slot:SetAlignment { X = 1.0, Y = 1.0 }
      slot:SetPosition(hotbarInitialPos)
      config.SetModConfig("hotbarLocation", position)
      return true
    elseif position == "center" then
      slot:SetAnchors { Minimum = { X = 0.5, Y = 1.0 }, Maximum = { X = 0.5, Y = 1.0 } }
      slot:SetAlignment { X = 0.5, Y = 1.0 }
      slot:SetPosition { X = 0.0, Y = hotbarInitialPos.Y }
      config.SetModConfig("hotbarLocation", position)
      return true
    end
  end
  return false
end

-- Handle HTTP requests

---Handle request to show message to player(s)
---@type RequestPathHandler
local function HandleShowPopupMessage(session)
  local content = json.parse(session.content)
  if content and type(content) == "table" then
    if content.message then
      ShowMessagePopup(content.message, content.playerId)
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

RegisterConsoleCommandHandler("sethotbarposition", function(Cmd, CommandParts, Ar)
  local pos = CommandParts[1] ---@type HotBarLocation|nil
  if pos then
    SetHotBarPosition(pos)
  end
  return true
end)

-- Register event hooks

-- Restore all previously set widget settings
RegisterHook("/Script/MotorTown.MotorTownPlayerController:ClientFirstTickResponse", function(self, ...)
  LogOutput("DEBUG", "Received widget update request")
  for key, value in pairs(registerKeys) do
    SetWidgetVisibility(value)
  end

  -- Get the hotbar initial canvas position
  local slot = GetHotBarCanvasSlot()
  if slot:IsValid() then
    hotbarInitialPos = slot:GetPosition()
  end

  local pos = config.GetModConfig("hotbarLocation")
  SetHotBarPosition(pos)
end)

return {
  HandleShowPopupMessage = HandleShowPopupMessage
}
