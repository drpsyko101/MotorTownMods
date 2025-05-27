local UEHelpers = require("UEHelpers")
local webhook = require("Webclient")
local json = require("JsonParser")

---Convert FMTEventPlayer to JSON serializable table
---@param player FMTEventPlayer
local function EventPlayerToTable(player)
  local data = {}

  data.BestLapTime = player.BestLapTime
  data.CharacterId = CharacterIdToTable(player.CharacterId)
  data.PlayerName = player.PlayerName:ToString()
  data.Rank = player.Rank
  data.SectionIndex = player.SectionIndex
  data.Laps = player.Laps
  data.bDisqualified = player.bDisqualified
  data.bFinished = player.bFinished
  data.bWrongVehicle = player.bWrongVehicle
  data.bWrongEngine = player.bWrongEngine
  data.LastSectionTotalTimeSeconds = player.LastSectionTotalTimeSeconds

  data.LapTimes = {}
  for i = 1, #player.LapTimes, 1 do
    table.insert(data.LapTimes, player.LapTimes[i])
  end

  data.BestLapTime = player.BestLapTime
  data.Reward_RacingExp = player.Reward_RacingExp
  data.Reward_Money = RewardToTable(player.Reward_Money)

  return data
end

---Convert FMTRaceEventSetup to JSON serializable table
---@param event FMTRaceEventSetup
local function RaceEventToTable(event)
  local data = {}
  data.EngineKeys = {}
  for i = 1, #event.EngineKeys do
    table.insert(data.EngineKeys, event.EngineKeys[i]:ToString())
  end

  data.VehicleKeys = {}
  for j = 1, #event.VehicleKeys do
    table.insert(data.VehicleKeys, event.VehicleKeys[j]:ToString())
  end

  data.NumLaps = event.NumLaps
  data.Route = RouteToTable(event.Route)

  return data
end

---Convert EMTEventType to string
---@param type EMTEventType
local function EventTypeToString(type)
  if type == 1 then return "Race" end
  return "None"
end

---Convert event state to string
---@param state EMTEventState
local function EventStateToString(state)
  if state == 1 then return "Ready" end
  if state == 2 then return "InProgress" end
  if state == 3 then return "Finished" end
  return "None"
end

---Convert a FMTEvent to JSON serializable table
---@param event FMTEvent
local function EventToTable(event)
  local data = {}
  data.EventGuid = GuidToString(event.EventGuid)
  data.EventName = event.EventName:ToString()
  data.EventType = EventTypeToString(event.EventType)
  data.OwnerCharacterId = CharacterIdToTable(event.OwnerCharacterId)

  data.Players = {}
  for j = 1, #event.Players, 1 do
    table.insert(data.Players, EventPlayerToTable(event.Players[j]))
  end

  data.RaceSetup = RaceEventToTable(event.RaceSetup)
  data.State = EventStateToString(event.State)
  data.bInCountdown = event.bInCountdown

  return data
end

---Get all active events
---@param eventGuid string? Return specific event matching this GUID
local function GetEvents(eventGuid)
  local gameState = GetMotorTownGameState()
  if not gameState:IsValid() then return '{"data":[]}' end

  local eventSystem = gameState.Net_EventSystem
  if not eventSystem:IsValid() then return '{"data":[]}' end

  local arr = {}
  for i = 1, #eventSystem.Net_Events, 1 do
    local event = eventSystem.Net_Events[i]

    if eventGuid and eventGuid ~= GuidToString(event.EventGuid) then goto continue end
    
    table.insert(arr, EventToTable(event))

    ::continue::
  end
  return string.format('{"data":%s}', json.stringify(table))
end

---Update an event name
---@param eventGuid string
---@param eventName string
local function UpdateEventName(eventGuid, eventName)
  local gameState = GetMotorTownGameState()
  if not gameState:IsValid() then return false end

  local eventSystem = gameState.Net_EventSystem
  if not eventSystem:IsValid() then return false end

  for i = 1, #eventSystem.Net_Events, 1 do
    local event = eventSystem.Net_Events[i]
    if GuidToString(event.EventGuid) == eventGuid then
      event.EventName = eventName
      return true
    end
  end
  return false
end

RegisterConsoleCommandHandler("getevents", function(Cmd, CommandParts, Ar)
  LogMsg(GetEvents())
  return true
end)

RegisterConsoleCommandHandler("updateeventname", function(Cmd, CommandParts, Ar)
  local eventGuid = table.remove(CommandParts, 1)
  local eventName = table.concat(CommandParts, " ")
  if UpdateEventName(eventGuid, eventName) then
    LogMsg(string.format("Updated event %s name to %s", eventGuid, eventName))
  end
  return true
end)

RegisterHook("/Script/MotorTown.MotorTownPlayerController:ServerAddEvent", function(self, eventParam)
  local event = eventParam:get() ---@type FMTEvent
  LogMsg("New event " .. GuidToString(event.EventGuid) .. " created", "DEBUG")
  local eventTable = EventToTable(event)
  webhook.CreateWebhookRequest('{"data":[' .. json.stringify(eventTable) .. ']}')
end)

RegisterHook("/Script/MotorTown.MotorTownPlayerController:ServerRemoveEvent", function(self, eventParam)
  local event = eventParam:get() ---@type FGuid
  local eventGuid = GuidToString(event)
  LogMsg("Event " .. eventGuid .. " removed", "DEBUG")
  webhook.CreateWebhookRequest('{"data":["' .. eventGuid .. '"]}')
end)

return {
  GetEvents = GetEvents,
  UpdateEventName = UpdateEventName
}
