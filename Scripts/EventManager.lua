require("UEHelpers")

---Convert FMTEventPlayer to string
---@param player FMTEventPlayer
local function EventPlayerToString(player)
  local data = {}

  data.BestLapTime = player.BestLapTime
  data.CharacterId = CharacterIdToString(player.CharacterId)
  data.PlayerName = player.PlayerName:ToString()
  data.Rank = player.Rank
  data.SectionIndex = player.SectionIndex
  data.Laps = player.Laps
  data.bDisqualified = player.bDisqualified
  data.bFinished = player.bFinished
  data.bWrongVehicle = player.bWrongVehicle
  data.bWrongEngine = player.bWrongEngine
  data.LastSectionTotalTimeSeconds = player.LastSectionTotalTimeSeconds
  data.LapTimes = string.format("[%s]", table.concat(player.LapTimes, ","))
  data.BestLapTime = player.BestLapTime
  data.Reward_RacingExp = player.Reward_RacingExp
  data.Reward_Money = RewardToString(player.Reward_Money)

  return SimpleJsonSerializer(data)
end

---Convert FMTRaceEventSetup to string
---@param event FMTRaceEventSetup
local function RaceEventToString(event)
  local data = {}
  local eKeys = {}
  for i = 1, #event.EngineKeys do
    table.insert(eKeys, string.format('"%s"', eKeys, event.EngineKeys[i]:ToString()))
  end
  data.EngineKeys = string.format("[%s]", table.concat(eKeys, ","))

  local vKeys = {}
  for j = 1, #event.VehicleKeys do
    table.insert(vKeys, string.format('"%s"', vKeys, event.VehicleKeys[j]:ToString()))
  end
  data.VehicleKeys = string.format("[%s]", table.concat(vKeys, ","))

  data.NumLaps = event.NumLaps
  data.Route = RouteToJson(event.Route)

  return SimpleJsonSerializer(data)
end

---Get all active events
local function GetEvents()
  local gameState = GetMotorTownGameState()
  if not gameState:IsValid() then return '{"data":[]}' end

  local eventSystem = gameState.Net_EventSystem
  if not eventSystem:IsValid() then return '{"data":[]}' end

  local arr = {}
  for i = 1, #eventSystem.Net_Events, 1 do
    local event = eventSystem.Net_Events[i]
    local data = {}
    data.EventGuid = GuidToString(event.EventGuid)
    data.EventName = event.EventName:ToString()
    data.EventType = event.EventType
    data.OwnerCharacterId = CharacterIdToString(event.OwnerCharacterId)

    local players = {}
    for j = 1, #event.Players, 1 do
      table.insert(players, EventPlayerToString(event.Players[j]))
    end
    data.Players = string.format("[%s]", table.concat(players, ","))

    data.RaceSetup = RaceEventToString(event.RaceSetup)
    data.State = event.State
    data.bInCountdown = event.bInCountdown

    table.insert(arr, SimpleJsonSerializer(data))
  end
  return string.format('{"data":[%s]}', table.concat(arr, ","))
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

return {
  GetEvents = GetEvents,
  UpdateEventName = UpdateEventName
}
