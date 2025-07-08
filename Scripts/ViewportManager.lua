---Get the in game HUD widget
---@return UInGameHUDWidget
local function GetHudWidget()
  local PC = GetMyPlayerController()
  if PC:IsValid() then
    local HUD = PC:GetHUD()
    local hudClass = StaticFindObject("/Script/MotorTown.MotorTownInGameHUD")
    ---@cast hudClass UClass

    if HUD:IsValid() and HUD:IsA(hudClass) then
      ---@cast HUD AMotorTownInGameHUD

      local widget = HUD.HUDWidget
      if widget and widget:IsValid() then
        return widget
      end
    end
  end
  return CreateInvalidObject() ---@type UInGameHUDWidget
end

local minimapHidden = false
RegisterConsoleCommandHandler("toggleminimap", function(Cmd, CommandParts, Ar)
  local widget = GetHudWidget()
  if widget:IsValid() then
    local activeWidget = widget.MinimapWidget
    if activeWidget:IsValid() then
      minimapHidden = not minimapHidden
      LogOutput("INFO", "Setting minimap visibility to %s", minimapHidden and "hidden" or "self-hit-test invisible")
      activeWidget:SetVisibility(minimapHidden and 2 or 4)
    end
  end
  return true
end)

local questHidden = false
RegisterConsoleCommandHandler("togglequest", function(Cmd, CommandParts, Ar)
  local widget = GetHudWidget()
  if widget:IsValid() then
    local activeWidget = widget.QuestFrame
    if activeWidget:IsValid() then
      questHidden = not questHidden
      LogOutput("INFO", "Setting quest visibility to %.1f", questHidden and 0 or 1)
      activeWidget:SetRenderOpacity(questHidden and 0 or 1)
    end
  end
  return true
end)

local drivingHidden = false
RegisterConsoleCommandHandler("toggledrivinghud", function(Cmd, CommandParts, Ar)
  local widget = GetHudWidget()
  if widget:IsValid() then
    local activeWidget = widget.DrivingHUD
    if activeWidget:IsValid() then
      drivingHidden = not drivingHidden
      LogOutput("INFO", "Setting driving HUD opacity to %.1f", drivingHidden and 0 or 1)
      activeWidget:SetRenderOpacity(drivingHidden and 0 or 1)
    end
  end
  return true
end)

local controlHidden = false
RegisterConsoleCommandHandler("togglecontrolhelper", function(Cmd, CommandParts, Ar)
  local widget = GetHudWidget()
  if widget:IsValid() then
    local activeWidgets = {
      widget.DrivingHUD.BlinkerRightControlWidget,
      widget.DrivingHUD.BlinkerLeftControlWidget,
      widget.DrivingHUD.LightWidget,
      widget.DrivingHUD.HazardWidget,
      widget.DrivingHUD.AutoPilotWidget,
      widget.DrivingHUD.SirenWidget,
      widget.DrivingHUD.DrivingModeWidget,
      widget.DrivingHUD.DiffLockModeWidget,
      widget.DrivingHUD.VirtualMirrorControlWidget
    }

    controlHidden = not controlHidden
    for index, value in ipairs(activeWidgets) do
      if value:IsValid() then
        LogOutput("INFO", "Setting control widget opacity to %.1f", controlHidden and 0 or 1)
        value:SetRenderOpacity(controlHidden and 0 or 1)
      end
    end
  end
  return true
end)

local systemMsgHidden = false
RegisterConsoleCommandHandler("togglesystemmessage", function(Cmd, CommandParts, Ar)
  local widget = GetHudWidget()
  if widget:IsValid() then
    local activeWidget = widget.DrivingHUD.SeatLayoutWidget
    if activeWidget:IsValid() then
      systemMsgHidden = not systemMsgHidden
      LogOutput("INFO", "Setting system message opacity to %.1f", systemMsgHidden and 0 or 1)
      activeWidget:SetRenderOpacity(systemMsgHidden and 0 or 1)
    end
  end
  return true
end)

return {
}
