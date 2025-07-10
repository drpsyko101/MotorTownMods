local config = require("ModConfig")

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

---Set the mini map visibility
---@param isVisible boolean
local function SetMiniMapVisibility(isVisible)
  LogOutput("DEBUG", "Getting hud widget")
  local widget = GetHudWidget()
  if widget:IsValid() then
    if widget.MinimapWidget:IsValid() then
      LogOutput("DEBUG", "Setting %s visibility to %q", widget.MinimapWidget:GetFullName(), isVisible)
      widget.MinimapWidget:SetVisibility(isVisible and 4 or 2)
      config.SetModConfig("showMiniMap", isVisible)
    end
  end
end

---Set the blueprint mod scale
---@param scale number
local function SetBlueprintModScale(scale)
  LogOutput("DEBUG", "Getting my player controller")
  local PC = GetMyPlayerController()
  if PC:IsValid() then
    LogOutput("DEBUG", "Getting my mod option")
    local modOptionClass = StaticFindObject("/Game/Mods/MT/ModOptions.ModOptions_C")
    ---@cast modOptionClass UClass
    local comp = PC:GetComponentByClass(modOptionClass)
    if comp:IsValid() then
      LogOutput("DEBUG", "Setting new UI scale to 2.0")
      comp:UpdateUIScale(scale)
      config.SetModConfig("uiTitle", scale)
    end
  end
end

---Set quest panel visibility
---@param isVisible boolean
local function SetQuestVisibility(isVisible)
  local widget = GetHudWidget()
  SetWidgetOpacity(widget.QuestFrame, isVisible and 1 or 0)
  config.SetModConfig("showQuest", isVisible)
end

---Set driving HUD visibility
---@param isVisible boolean
local function SetDrivingHudVisibility(isVisible)
  local widget = GetHudWidget()
  SetWidgetOpacity(widget.DrivingHUD, isVisible and 1 or 0)
  config.SetModConfig("showDrivingHud", isVisible)
end

---Set control helper visibility
---@param isVisible boolean
local function SetControlHelperVisibility(isVisible)
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

    for index, value in ipairs(activeWidgets) do
      SetWidgetOpacity(value, isVisible and 1 or 0)
    end
    config.SetModConfig("showControls", isVisible)
  end
end

---Set hot bar visibility
---@param isVisible boolean
local function SetHotbarVisibility(isVisible)
  local widget = GetHudWidget()
  if widget:IsValid() then
    SetWidgetOpacity(widget.QuickbarWidget, isVisible and 1 or 0)
    config.SetModConfig("showHotbar", isVisible)
  end
end

---Set player list visibility
---@param isVisible boolean
local function SetPlayerListVisibility(isVisible)
  local widget = GetHudWidget()
  if widget:IsValid() then
    SetWidgetOpacity(widget.PlayerList, isVisible and 1 or 0)
    config.SetModConfig("showPlayerList", isVisible)
  end
end

-- Console commands

RegisterConsoleCommandHandler("toggleminimap", function(Cmd, CommandParts, Ar)
  local isVisible = config.GetModConfig("showMiniMap")
  if type(isVisible) == "boolean" then
    SetMiniMapVisibility(not isVisible)
  end
  return true
end)

local questHidden = false
RegisterConsoleCommandHandler("togglequest", function(Cmd, CommandParts, Ar)
  local isVisible = config.GetModConfig("showQuest")
  if type(isVisible) == "boolean" then
    SetQuestVisibility(not isVisible)
  end
  return true
end)

local drivingHidden = false
RegisterConsoleCommandHandler("toggledrivinghud", function(Cmd, CommandParts, Ar)
  local isVisible = config.GetModConfig("showDrivingHud")
  if type(isVisible) == "boolean" then
    SetDrivingHudVisibility(not isVisible)
  end
  return true
end)

local controlHidden = false
RegisterConsoleCommandHandler("togglecontrolhelper", function(Cmd, CommandParts, Ar)
  local isVisible = config.GetModConfig("showControls")
  if type(isVisible) == "boolean" then
    SetControlHelperVisibility(not isVisible)
  end
  return true
end)

local hotBarHidden = false
RegisterConsoleCommandHandler("togglehotbar", function(Cmd, CommandParts, Ar)
  local isVisible = config.GetModConfig("showHotbar")
  if type(isVisible) == "boolean" then
    SetHotbarVisibility(not isVisible)
  end
  return true
end)

local playerListHidden = false
RegisterConsoleCommandHandler("toggleplayerlist", function(Cmd, CommandParts, Ar)
  local isVisible = config.GetModConfig("showPlayerList")
  if type(isVisible) == "boolean" then
    SetPlayerListVisibility(isVisible)
  end
  return true
end)

RegisterConsoleCommandHandler("setmoduiscale", function(Cmd, CommandParts, Ar)
  local newScale = CommandParts[1] and tonumber(CommandParts[1])
  if newScale then
    SetBlueprintModScale(newScale)
  end
  return true
end)

-- Register event hooks

-- Restore all previously set widget settings
RegisterHook("/Script/MotorTown.MotorTownPlayerController:ServerFirstTickResponse", function(self, ...)
  LogOutput("INFO", "MotorTownPlayerController:ServerFirstTickResponse")

  LogOutput("DEBUG", "Received widget update request")
  local showMiniMap = config.GetModConfig("showMiniMap")
  if type(showMiniMap) == "boolean" then
    SetMiniMapVisibility(showMiniMap)
  end

  local showQuest = config.GetModConfig("showQuest")
  if type(showQuest) == "boolean" then
    SetQuestVisibility(showQuest)
  end

  local showDriving = config.GetModConfig("showDrivingHud")
  if type(showDriving) == "boolean" then
    SetDrivingHudVisibility(showDriving)
  end

  local showControl = config.GetModConfig("showControls")
  if type(showControl) == "boolean" then
    SetControlHelperVisibility(showControl)
  end

  local showHotbar = config.GetModConfig("showHotbar")
  if type(showHotbar) == "boolean" then
    SetHotbarVisibility(not showHotbar)
  end

  local showPlayerList = config.GetModConfig("showPlayerList")
  if type(showPlayerList) == "boolean" then
    SetPlayerListVisibility(showPlayerList)
  end

  local scale = config.GetModConfig("uiScale")
  if type(scale) == "number" then
    SetBlueprintModScale(scale)
  end
end)
