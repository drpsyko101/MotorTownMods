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
  player.LapTimes:ForEach(function(index, element)
    table.insert(data.LapTimes, element:get())
  end)

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
  event.Players:ForEach(function(index, element)
    table.insert(data.Players, EventPlayerToTable(element:get()))
  end)

  data.RaceSetup = RaceEventToTable(event.RaceSetup)
  data.State = EventStateToString(event.State)
  data.bInCountdown = event.bInCountdown

  return data
end

local EventSystem = CreateInvalidObject()
---comment Get Motor Town event system
---@return AMTEventSystem
local function GetEventSystem()
  local gameState = GetMotorTownGameState()
  if gameState:IsValid() and gameState.Net_EventSystem:IsValid() then
    local gameStateClass = StaticFindObject("/Script/MotorTown.MTEventSystem")
    ---@cast gameStateClass UClass
    if gameState.Net_EventSystem:IsA(gameStateClass) then
      EventSystem = gameState.Net_EventSystem
    end
  end
  return EventSystem ---@type AMTEventSystem
end

---Get all active events in a JSON serializable table
---@param eventGuid string? Return specific event matching this GUID
---@return table[]
local function GetEvents(eventGuid)
  local eventSystem = GetEventSystem()
  local arr = {}

  if not eventSystem:IsValid() then return arr end

  eventSystem.Net_Events:ForEach(function(index, element)
    local event = element:get() ---@type FMTEvent

    if eventGuid and eventGuid ~= GuidToString(event.EventGuid) then goto continue end

    table.insert(arr, EventToTable(event))

    ::continue::
  end)
  return arr
end

---@class RouteTable
---@field RouteName string
---@field Waypoints FTransform[]
local RouteTable = {}

---@class EventTable
---@field EventName string
---@field EventGuid string?
---@field EventType number
---@field OwnerCharacterId { UniqueNetId: string, CharacterGuid: string }
---@field RaceSetup { Route: RouteTable, NumLaps: number, VehicleKeys: string[], EngineKeys: string[] }
local EventTable = {}

---Create a new event
---@param event EventTable
---@return boolean status
---@return string? guid
local function CreateNewEvent(event)
  local eventSystem = GetEventSystem()

  if eventSystem:IsValid() then
    -- Add a new event without any TArray
    local guid = StringToGuid(event.EventGuid)
    eventSystem.Net_Events[#eventSystem.Net_Events + 1] = {
      EventName = event.EventName,
      EventGuid = guid,
      EventType = event.EventType,
      OwnerCharacterId = {
        CharacterGuid = { A = 0, B = 0, C = 0, D = 0 },
        UniqueNetId = ""
      },
      Players = {},
      bInCountdown = false,
      RaceSetup = {
        NumLaps = event.RaceSetup.NumLaps,
        EngineKeys = {},
        VehicleKeys = {},
        Route = {
          RouteName = "",
          Waypoints = {}
        }
      },
      State = 1
    }

    eventSystem.Net_Events[#eventSystem.Net_Events].RaceSetup.Route.RouteName = event.RaceSetup.Route.RouteName

    -- Add back TArray individually
    eventSystem.Net_Events[#eventSystem.Net_Events].RaceSetup.Route.Waypoints:Empty()
    for index, value in ipairs(event.RaceSetup.Route.Waypoints) do
      eventSystem.Net_Events[#eventSystem.Net_Events].RaceSetup.Route.Waypoints[index] = value
    end

    eventSystem.Net_Events[#eventSystem.Net_Events].RaceSetup.EngineKeys:Empty()
    for index, value in ipairs(event.RaceSetup.EngineKeys) do
      eventSystem.Net_Events[#eventSystem.Net_Events].RaceSetup.EngineKeys[index] = FName(value)
    end

    eventSystem.Net_Events[#eventSystem.Net_Events].RaceSetup.VehicleKeys:Empty()
    for index, value in ipairs(event.RaceSetup.VehicleKeys) do
      eventSystem.Net_Events[#eventSystem.Net_Events].RaceSetup.VehicleKeys[index] = FName(value)
    end

    return true, GuidToString(eventSystem.Net_Events[#eventSystem.Net_Events].EventGuid)
  end
  return false, nil
end

---Update an event name
---@param eventGuid string
---@param eventName string
local function UpdateEventName(eventGuid, eventName)
  local eventSystem = GetEventSystem()

  if eventSystem:IsValid() then
    for i = 1, #eventSystem.Net_Events, 1 do
      if GuidToString(eventSystem.Net_Events[i].EventGuid) == eventGuid then
        eventSystem.Net_Events[i].EventName = eventName
        return true
      end
    end
    return false
  end
end

---Update an event race setup
---@param eventGuid string
---@param raceSetup { Route: Route, NumLaps: number, VehicleKeys: string[], EngineKeys: string[] }
---@return boolean
local function UpdateEventRaceSetup(eventGuid, raceSetup)
  local eventSystem = GetEventSystem()

  if eventSystem:IsValid() then
    for i = 1, #eventSystem.Net_Events, 1 do
      if GuidToString(eventSystem.Net_Events[i].EventGuid) == eventGuid then
        eventSystem.Net_Events[i].RaceSetup.NumLaps = raceSetup.NumLaps

        eventSystem.Net_Events[i].RaceSetup.EngineKeys:Empty()
        for index, value in ipairs(raceSetup.EngineKeys) do
          eventSystem.Net_Events[i].RaceSetup.EngineKeys[index - 1] = FName(value)
        end

        eventSystem.Net_Events[i].RaceSetup.VehicleKeys:Empty()
        for index, value in ipairs(raceSetup.VehicleKeys) do
          eventSystem.Net_Events[i].RaceSetup.VehicleKeys[index - 1] = FName(value)
        end

        eventSystem.Net_Events[i].RaceSetup.Route.RouteName = raceSetup.Route.RouteName

        eventSystem.Net_Events[i].RaceSetup.Route.Waypoints:Empty()
        for index, value in ipairs(raceSetup.Route.Waypoints) do
          eventSystem.Net_Events[i].RaceSetup.Route.Waypoints[index - 1] = value
        end
        return true
      end
    end
  end

  return false
end

---Change an event status
---@param eventGuid string
---@param state number
local function ChangeEventState(eventGuid, state)
  local gameState = GetMotorTownGameState()

  if gameState:IsValid() then
    if gameState.Net_EventSystem:IsValid() and #gameState.PlayerArray > 0 then
      local PC = gameState.PlayerArray[1]:GetPlayerController()
      ---@cast PC AMotorTownPlayerController

      if not PC:IsValid() then return false end

      for i = 1, #gameState.Net_EventSystem.Net_Events, 1 do
        local event = gameState.Net_EventSystem.Net_Events[i]

        if GuidToString(event.EventGuid) == eventGuid then
          -- Race won't start if there are no players or waypoints
          if #event.Players == 0 or #event.RaceSetup.Route.Waypoints == 0 then
            return false
          end

          -- RPC call doesn't support StructProperty, so were using table instead
          PC:ServerChangeEventState(
            {
              A = event.EventGuid.A,
              B = event.EventGuid.B,
              C = event.EventGuid.C,
              D = event.EventGuid.D
            },
            state
          )
          return true
        end
      end
    end
  end
  return false
end

---Remove an event
---@param eventGuid string
local function RemoveEvent(eventGuid)
  local gameState = GetMotorTownGameState()

  if gameState:IsValid() then
    if gameState.Net_EventSystem:IsValid() and #gameState.PlayerArray > 0 then
      local PC = gameState.PlayerArray[1]:GetPlayerController()
      ---@cast PC AMotorTownPlayerController

      if not PC:IsValid() then return false end

      for i = 1, #gameState.Net_EventSystem.Net_Events, 1 do
        local event = gameState.Net_EventSystem.Net_Events[i]

        if GuidToString(event.EventGuid) == eventGuid then
          -- RPC call doesn't support StructProperty, so were using table instead
          PC:ServerRemoveEvent(
            {
              A = event.EventGuid.A,
              B = event.EventGuid.B,
              C = event.EventGuid.C,
              D = event.EventGuid.D
            }
          )
          return true
        end
      end
    end
  end
  return false
end

-- Console command registration

RegisterConsoleCommandHandler("getevents", function(Cmd, CommandParts, Ar)
  LogMsg(json.stringify(GetEvents()))
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

-- Register event hooks

local serverAddEvent = "/Script/MotorTown.MotorTownPlayerController:ServerAddEvent"
RegisterHook(
  serverAddEvent,
  function(self, eventParam)
    local event = eventParam:get() ---@type FMTEvent

    LogMsg("New event " .. GuidToString(event.EventGuid) .. " created", "DEBUG")

    local eventTable = EventToTable(event)
    local res = json.stringify {
      hook = serverAddEvent,
      data = eventTable
    }
    webhook.CreateWebhookRequest(res)
  end
)

local serverEventState = "/Script/MotorTown.MotorTownPlayerController:ServerChangeEventState"
RegisterHook(
  serverEventState,
  function(self, eventParam, stateParam)
    local guid = eventParam:get() ---@type FGuid
    local eventState = stateParam:get() ---@type EMTEventState
    local eventGuid = EventStateToString(eventState)

    LogMsg("Event " .. guid .. " state changed to " .. eventGuid .. "", "DEBUG")

    local event = GetEvents(eventGuid)

    if #event == 0 then return end

    local eventTable = EventToTable(event[1])
    local res = json.stringify {
      hook = serverEventState,
      data = eventTable
    }
    webhook.CreateWebhookRequest(res)
  end
)

local serverRemoveEvent = "/Script/MotorTown.MotorTownPlayerController:ServerRemoveEvent"
RegisterHook(
  serverRemoveEvent,
  function(self, eventParam)
    local event = eventParam:get() ---@type FGuid
    local eventGuid = GuidToString(event)
    LogMsg("Event " .. eventGuid .. " removed", "DEBUG")
    local res = json.stringify {
      hook = serverRemoveEvent,
      data = {
        EventGuid = eventGuid
      }
    }
    webhook.CreateWebhookRequest(res)
  end
)

local passRaceSection = "/Script/MotorTown.MotorTownPlayerController:ServerPassedRaceSection"
RegisterHook(
  passRaceSection,
  function(self, eventGuid, sectionIndex, totalTimeSeconds, laptimeSeconds)
    local PC = self:get() ---@cast PC APlayerController

    if not PC:IsValid() then return end

    local PS = PC.PlayerState ---@cast PS AMotorTownPlayerState

    if not PS:IsValid() then return end

    local res = json.stringify {
      hook = passRaceSection,
      data = {
        SenderGuid = GuidToString(PS.CharacterGuid),
        EventGuid = GuidToString(eventGuid:get()),
        SectionIndex = sectionIndex:get(),
        TotalTimeSeconds = totalTimeSeconds:get(),
        LaptimeSeconds = laptimeSeconds:get()
      }
    }
    LogMsg(res, "DEBUG")
    webhook.CreateWebhookRequest(res)
  end
)

-- HTTP request handlers

---Handle request for all events
---@type RequestPathHandler
local function HandleGetAllEvents(session)
  local events = json.stringify {
    data = GetEvents()
  }
  return events
end

---Handle request for all events
---@type RequestPathHandler
local function HandleGetSpecificEvents(session)
  local eventGuid = session.pathComponents[2]
  local events = json.stringify {
    data = GetEvents(eventGuid)
  }
  return events
end

---Handle request for a new event
---@type RequestPathHandler
local function HandleCreateNewEvent(session)
  local content = json.parse(session.content)

  if content then
    ---@cast content EventTable
    local status, guid = CreateNewEvent(content)
    if status then
      LogMsg("Created new event " .. guid, "DEBUG")
      local events = json.stringify {
        data = GetEvents(guid)
      }
      return events, nil, 201
    end
  end

  return nil, nil, 400
end

---Handle request for changing an event state
---@type RequestPathHandler
local function HandleChangeEventState(session)
  local eventGuid = session.pathComponents[2]
  local content = json.parse(session.content)

  if type(content) == "table" and content.State then
    if ChangeEventState(eventGuid, content.State) then
      return nil, nil, 204
    end
  end

  return nil, nil, 400
end

---Handle request for all events
---@type RequestPathHandler
local function HandleUpdateEvent(session)
  local eventGuid = session.pathComponents[2]
  local content = json.parse(session.content)

  if content then
    local eventName = content.EventName or nil
    local eventSetup = content.EventSetup or nil

    if eventName then
      if not UpdateEventName(eventGuid, eventName) then
        return nil, nil, 400
      end
    end

    if eventSetup then
      if not UpdateEventRaceSetup(eventGuid, eventSetup) then
        return nil, nil, 400
      end
    end

    local events = json.stringify {
      data = GetEvents(eventGuid)
    }
    return events
  end
  return nil, nil, 400
end

---Handle request for event removal
---@type RequestPathHandler
local function HandleRemoveEvent(session)
  local eventGuid = session.pathComponents[2]

  if RemoveEvent(eventGuid) then
    return nil, nil, 204
  end
  return nil, nil, 400
end

return {
  GetEvents = GetEvents,
  HandleGetAllEvents = HandleGetAllEvents,
  HandleGetSpecificEvents = HandleGetSpecificEvents,
  HandleUpdateEvent = HandleUpdateEvent,
  HandleCreateNewEvent = HandleCreateNewEvent,
  HandleChangeEventState = HandleChangeEventState,
  HandleRemoveEvent = HandleRemoveEvent
}
