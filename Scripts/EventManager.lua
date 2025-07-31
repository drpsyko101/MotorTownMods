local UEHelpers = require("UEHelpers")
local webhook = require("Webclient")
local json = require("JsonParser")
local socket = RequireSafe("socket") ---@type Socket?

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

---Convert a FMTEvent to JSON serializable table
---@param event FMTEvent
local function EventToTable(event)
  local data = {}
  data.EventGuid = GuidToString(event.EventGuid)
  data.EventName = event.EventName:ToString()
  data.EventType = event.EventType
  data.OwnerCharacterId = CharacterIdToTable(event.OwnerCharacterId)

  data.Players = {}
  event.Players:ForEach(function(index, element)
    table.insert(data.Players, EventPlayerToTable(element:get()))
  end)

  data.RaceSetup = RaceEventToTable(event.RaceSetup)
  data.State = event.State
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
---@field OwnerCharacterId { UniqueNetId: string, CharacterGuid: string? }?
---@field RaceSetup { Route: RouteTable, NumLaps: integer, VehicleKeys: string[], EngineKeys: string[] }
local EventTable = {}

---Create a new event
---@param event EventTable
---@return string? guid
local function CreateNewEvent(event)
  local guid = StringToGuid(event.EventGuid)
  local characterGuid = event.OwnerCharacterId and StringToGuid(event.OwnerCharacterId.CharacterGuid) or
      { A = 0, B = 0, C = 0, D = 0 }
  ---@type FMTEvent
  local newEvent = {
    ---@diagnostic disable-next-line:assign-type-mismatch
    EventName = event.EventName,
    EventGuid = guid,
    EventType = 1,
    OwnerCharacterId = {
      CharacterGuid = characterGuid,
      ---@diagnostic disable-next-line:assign-type-mismatch
      UniqueNetId = event.OwnerCharacterId and event.OwnerCharacterId.UniqueNetId or ""
    },
    Players = {},
    bInCountdown = false,
    RaceSetup = {
      NumLaps = 0,
      EngineKeys = {},
      VehicleKeys = {},
      Route = {
        ---@diagnostic disable-next-line:assign-type-mismatch
        RouteName = "",
        Waypoints = {}
      }
    },
    State = 0
  }
  if event.OwnerCharacterId then
    local PC = GetPlayerControllerFromUniqueId(event.OwnerCharacterId.UniqueNetId)
    if PC:IsValid() then
      ---@cast PC AMotorTownPlayerController

      -- Fill in missing character ID
      if not event.OwnerCharacterId.CharacterGuid then
        local PS = PC.PlayerState
        ---@cast PS AMotorTownPlayerState
        if PS:IsValid() then
          -- Deserialize FGuid since it cannot be set as-is
          local newOwnerCharId = GuidToString(PS.CharacterGuid)
          newEvent.OwnerCharacterId.CharacterGuid = StringToGuid(newOwnerCharId)
        end
      end

      -- Execute new event creation in game thread synchronously
      local isProcessing = true
      ExecuteInGameThread(function()
        PC:ServerAddEvent(newEvent)
        isProcessing = false
      end)

      while isProcessing do
        if socket then
          socket.sleep(0.01)
        else
          Sleep(10)
        end
      end
    else
      error("Invalid playerId provided")
    end
  end

  local eventSystem = GetEventSystem()

  if eventSystem:IsValid() then
    local eventIndex = #eventSystem.Net_Events + 1
    if event.OwnerCharacterId then
      for i = 1, #eventSystem.Net_Events do
        eventIndex = i
        if guid == eventSystem.Net_Events[i].EventGuid then
          break
        end
      end
      -- Handle possible out of range index
      if eventIndex > #eventSystem.Net_Events then
        error(string.format("Failed to find the newly added event %s", GuidToString(guid)))
      end
    else
      -- Add a new event without any TArray
      eventSystem.Net_Events[eventIndex] = newEvent
    end

    ---@diagnostic disable-next-line:assign-type-mismatch
    eventSystem.Net_Events[eventIndex].RaceSetup.Route.RouteName = event.RaceSetup.Route.RouteName

    -- Add back TArray individually
    eventSystem.Net_Events[eventIndex].RaceSetup.Route.Waypoints:Empty()
    for index, value in ipairs(event.RaceSetup.Route.Waypoints) do
      eventSystem.Net_Events[eventIndex].RaceSetup.Route.Waypoints[index] = value
    end

    eventSystem.Net_Events[eventIndex].RaceSetup.EngineKeys:Empty()
    for index, value in ipairs(event.RaceSetup.EngineKeys) do
      eventSystem.Net_Events[eventIndex].RaceSetup.EngineKeys[index] = FName(value)
    end

    eventSystem.Net_Events[eventIndex].RaceSetup.VehicleKeys:Empty()
    for index, value in ipairs(event.RaceSetup.VehicleKeys) do
      eventSystem.Net_Events[eventIndex].RaceSetup.VehicleKeys[index] = FName(value)
    end

    -- Try setting the lap amount after waypoints
    eventSystem.Net_Events[eventIndex].RaceSetup.NumLaps = event.RaceSetup.NumLaps

    return GuidToString(eventSystem.Net_Events[eventIndex].EventGuid)
  end
  error("Invalid event system")
end

---Update an event name
---@param eventGuid string
---@param eventName string
local function UpdateEventName(eventGuid, eventName)
  local eventSystem = GetEventSystem()

  if eventSystem:IsValid() then
    for i = 1, #eventSystem.Net_Events, 1 do
      if GuidToString(eventSystem.Net_Events[i].EventGuid) == eventGuid:upper() then
        ---@diagnostic disable-next-line:assign-type-mismatch
        eventSystem.Net_Events[i].EventName = eventName
        return
      end
    end
    error(string.format("Unable to find event %s", eventGuid))
  end
  error("Invalid event system")
end

---Update an event race setup
---@param eventGuid string
---@param raceSetup { Route: Route?, NumLaps: integer?, VehicleKeys: string[]?, EngineKeys: string[]? }
local function UpdateEventRaceSetup(eventGuid, raceSetup)
  local eventSystem = GetEventSystem()

  if eventSystem:IsValid() then
    for i = 1, #eventSystem.Net_Events, 1 do
      if GuidToString(eventSystem.Net_Events[i].EventGuid) == eventGuid:upper() then
        if raceSetup.EngineKeys then
          eventSystem.Net_Events[i].RaceSetup.EngineKeys:Empty()
          for index, value in ipairs(raceSetup.EngineKeys) do
            eventSystem.Net_Events[i].RaceSetup.EngineKeys[index - 1] = FName(value)
          end
        end

        if raceSetup.VehicleKeys then
          eventSystem.Net_Events[i].RaceSetup.VehicleKeys:Empty()
          for index, value in ipairs(raceSetup.VehicleKeys) do
            eventSystem.Net_Events[i].RaceSetup.VehicleKeys[index - 1] = FName(value)
          end
        end

        if raceSetup.Route then
          ---@diagnostic disable-next-line:assign-type-mismatch
          eventSystem.Net_Events[i].RaceSetup.Route.RouteName = raceSetup.Route.RouteName

          eventSystem.Net_Events[i].RaceSetup.Route.Waypoints:Empty()
          for index, value in ipairs(raceSetup.Route.Waypoints) do
            eventSystem.Net_Events[i].RaceSetup.Route.Waypoints[index - 1] = value
          end
        end

        if raceSetup.NumLaps then
          eventSystem.Net_Events[i].RaceSetup.NumLaps = raceSetup.NumLaps
        end
        return
      end
    end
    error(string.format("Unable to find event %s", eventGuid))
  end
  error("Invalid event system")
end

---Update an event owner
---@param eventGuid string
---@param eventOwner FMTCharacterId
local function UpdateEventOwner(eventGuid, eventOwner)
  local eventSystem = GetEventSystem()

  if eventSystem:IsValid() then
    for i = 1, #eventSystem.Net_Events, 1 do
      if GuidToString(eventSystem.Net_Events[i].EventGuid) == eventGuid:upper() then
        ---@diagnostic disable-next-line:assign-type-mismatch
        eventSystem.Net_Events[i].OwnerCharacterId = eventOwner
        return
      end
    end
    error(string.format("Unable to find event %s", eventGuid))
  end
  error("Invalid event system")
end

---Change an event status. Requires a player in game to execute.
---@param eventGuid string
---@param state EMTEventState
---@return EMTEventState? previousState
local function ChangeEventState(eventGuid, state)
  local gameState = GetMotorTownGameState()

  if gameState:IsValid() then
    if gameState.Net_EventSystem:IsValid() then
      if #gameState.PlayerArray <= 0 then
        error("No active player in-game")
      end

      local PC = gameState.PlayerArray[1]:GetPlayerController()
      ---@cast PC AMotorTownPlayerController

      if not PC:IsValid() then
        error("Invalid player found")
      end

      for i = 1, #gameState.Net_EventSystem.Net_Events, 1 do
        local event = gameState.Net_EventSystem.Net_Events[i]

        if GuidToString(event.EventGuid) == eventGuid then
          local oldState = event.State

          if oldState == 2 and state == 1 then
            error("Failed to reset race while in progress")
          end

          -- Race won't start if there are no players or waypoints
          if oldState == 1 and state == 2 and (#event.Players == 0 or #event.RaceSetup.Route.Waypoints == 0) then
            error("Unable to start the race without any player or invalid route")
          end

          ExecuteInGameThread(function()
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
          end)

          return oldState
        end
      end
    end
    error("Invalid event system")
  end
  error("Invalid game state")
end

---Remove an event
---@param eventGuid string
local function RemoveEvent(eventGuid)
  local gameState = GetMotorTownGameState()

  if gameState:IsValid() then
    if gameState.Net_EventSystem:IsValid() and #gameState.PlayerArray > 0 then
      local PC = gameState.PlayerArray[1]:GetPlayerController()
      ---@cast PC AMotorTownPlayerController

      for i = 1, #gameState.Net_EventSystem.Net_Events, 1 do
        local event = gameState.Net_EventSystem.Net_Events[i]

        if GuidToString(event.EventGuid) == eventGuid:upper() then
          ExecuteInGameThread(function()
            -- RPC call doesn't support StructProperty, so were using table instead
            PC:ServerRemoveEvent(
              {
                A = event.EventGuid.A,
                B = event.EventGuid.B,
                C = event.EventGuid.C,
                D = event.EventGuid.D
              }
            )
          end)
          return
        end
      end
      error(string.format("Unable to find event %s", eventGuid))
    end
    error("No available player found")
  end
  error("Invalid game state")
end

---Check whether player is in any event
---@param playerId string
local function IsPlayerInAnyEvent(playerId)
  local PC = GetPlayerControllerFromUniqueId(playerId)
  if PC:IsValid() and PC.PlayerState:IsValid() then
    local PS = PC.PlayerState ---@cast PS AMotorTownPlayerState

    if #PS.OwnEventGuids > 0 or #PS.JoinedEventGuids > 0 then
      return true, PC
    end
    return false, PC
  end
  return false
end

-- Console command registration

RegisterConsoleCommandHandler("getevents", function(Cmd, CommandParts, Ar)
  LogOutput("INFO", json.stringify(GetEvents()))
  return true
end)

RegisterConsoleCommandHandler("updateeventname", function(Cmd, CommandParts, Ar)
  local eventGuid = table.remove(CommandParts, 1)
  local eventName = table.concat(CommandParts, " ")
  if UpdateEventName(eventGuid, eventName) then
    LogOutput("INFO", "Updated event %s name to %s", eventGuid, eventName)
  end
  return true
end)

-- Register event hooks

webhook.RegisterEventHook(
  "ServerAddEvent",
  function(context, eventParam)
    local PC = context:get() ---@type APlayerController
    local event = eventParam:get() ---@type FMTEvent

    LogOutput("DEBUG", "New event %s created", GuidToString(event.EventGuid))

    return {
      PlayerId = GetPlayerUniqueId(PC),
      Event = EventToTable(event),
    }
  end
)

webhook.RegisterEventHook(
  "ServerChangeEventState",
  function(context, eventParam, stateParam)
    local PC = context:get() ---@type APlayerController
    local guid = eventParam:get() ---@type FGuid
    local eventState = stateParam:get() ---@type EMTEventState
    local eventGuid = GuidToString(guid)

    LogOutput("DEBUG", "Event %s state changed to %i", eventGuid, eventState)

    local event = GetEvents(eventGuid)

    if #event == 0 then return end

    return {
      PlayerId = GetPlayerUniqueId(PC),
      Event = EventToTable(event[1])
    }
  end
)

webhook.RegisterEventHook(
  "ServerRemoveEvent",
  function(context, eventParam)
    local PC = context:get() ---@type APlayerController
    local event = eventParam:get() ---@type FGuid
    local eventGuid = GuidToString(event)

    LogOutput("DEBUG", "Event %s removed", eventGuid)

    return {
      PlayerId = GetPlayerUniqueId(PC),
      EventGuid = eventGuid
    }
  end
)

webhook.RegisterEventHook(
  "ServerPassedRaceSection",
  function(context, eventGuid, sectionIndex, totalTimeSeconds, laptimeSeconds)
    local PC = context:get() ---@cast PC APlayerController

    if not PC:IsValid() then return end

    local data = {
      PlayerId = GetPlayerUniqueId(PC),
      EventGuid = GuidToString(eventGuid:get()),
      SectionIndex = sectionIndex:get(),
      TotalTimeSeconds = totalTimeSeconds:get(),
      LaptimeSeconds = laptimeSeconds:get()
    }
    LogOutput("DEBUG", "ServerPassedRaceSection: %s", json.stringify(data))

    return data
  end
)

webhook.RegisterEventHook(
  "ServerJoinEvent",
  function(context, eventGuid)
    local PC = context:get() ---@cast PC APlayerController

    if not PC:IsValid() then return end

    local guid = GuidToString(eventGuid:get())

    local data = {
      PlayerId = GetPlayerUniqueId(PC),
      EventGuid = guid
    }

    LogOutput("DEBUG", "serverJoinEvent: %s", json.stringify(data))

    return data
  end
)

webhook.RegisterEventHook(
  "ServerLeaveEvent",
  function(context, eventGuid)
    local PC = context:get() ---@cast PC APlayerController

    if not PC:IsValid() then return end

    local guid = GuidToString(eventGuid:get())

    local data = {
      PlayerId = GetPlayerUniqueId(PC),
      EventGuid = guid
    }

    LogOutput("DEBUG", "serverLeaveEvent: %s", json.stringify(data))
    return data
  end
)

-- HTTP request handlers

---Handle request for all events
---@type RequestPathHandler
local function HandleGetEvents(session)
  local eventGuid = session.pathComponents[2]
  local res = GetEvents(eventGuid)
  if eventGuid and #res == 0 then
    return json.stringify { message = string.format("Event %s not found", eventGuid) }, nil, 404
  end
  return json.stringify { data = res }
end

---Handle request for a new event
---@type RequestPathHandler
local function HandleCreateNewEvent(session)
  local content = json.parse(session.content)

  -- Do a simple test for a valid EventTable
  if content and content.EventName and content.EventType then
    ---@cast content EventTable

    local status, output = pcall(CreateNewEvent, content)
    if status then
      LogOutput("DEBUG", "Created new event %s", output)
      local events = json.stringify {
        data = GetEvents(output)
      }
      return events, nil, 201
    end
    return json.stringify { error = string.format("Failed to create event: %s", output) }, nil, 400
  end

  return json.stringify { error = "Invalid payload" }, nil, 400
end

---Handle request for changing an event state
---@type RequestPathHandler
local function HandleChangeEventState(session)
  local eventGuid = session.pathComponents[2]
  local content = json.parse(session.content)

  if type(content) == "table" and content.State then
    local status, output = pcall(ChangeEventState, eventGuid, content.State)
    if status then
      local msg = string.format("Changed event %s state from %i to %i", eventGuid, output, content.State)
      return json.stringify { message = msg }, nil, 201
    end
    return json.stringify { error = string.format("Failed to change event %s state: %s", eventGuid, output) }, nil, 400
  end
  return json.stringify { error = "Invalid payload" }, nil, 400
end

---Handle request for all events
---@type RequestPathHandler
local function HandleUpdateEvent(session)
  local eventGuid = session.pathComponents[2]
  local content = json.parse(session.content)

  if content then
    local eventName = content.EventName or nil
    ---@type { Route: Route?, NumLaps: integer?, VehicleKeys: string[]?, EngineKeys: string[]? }?
    local eventSetup = content.EventSetup or nil
    local eventOwner = content.OwnerCharacterId or nil ---@type {UniqueNetId: string, CharacterGuid: string}?
    local errPayload = json.stringify { error = string.format("Failed to find event %s", eventGuid) }

    if eventName then
      UpdateEventName(eventGuid, eventName)
    end

    if eventSetup then
      UpdateEventRaceSetup(eventGuid, eventSetup)
    end

    if eventOwner then
      UpdateEventOwner(
        eventGuid,
        ---@diagnostic disable-next-line:assign-type-mismatch
        { CharacterGuid = StringToGuid(eventOwner.CharacterGuid), UniqueNetId = eventOwner.UniqueNetId })
    end

    return json.stringify { data = GetEvents(eventGuid) }
  end
  return json.stringify { error = "Invalid payload" }, nil, 400
end

---Handle request for event removal
---@type RequestPathHandler
local function HandleRemoveEvent(session)
  local eventGuid = session.pathComponents[2]

  local status, err = pcall(RemoveEvent, eventGuid)
  if status then
    return json.stringify { message = string.format("Event %s removed", eventGuid) }
  end
  return json.stringify { error = string.format("Failed to remove event: %s", err) }, nil, 400
end

---Handle request to forcefully make a player join a game
---@type RequestPathHandler
local function HandlePlayerJoinEvent(session)
  local eventGuid = session.pathComponents[2]
  local data = json.parse(session.content)

  if eventGuid and data and data.PlayerId then
    local eventSystem = GetEventSystem()
    local playerId = data.PlayerId ---@type string|string[]
    local PCs = {} ---@type AMotorTownPlayerController[]

    if type(playerId) == "string" then
      local inEvent, PC = IsPlayerInAnyEvent(playerId)
      if not inEvent and PC then
        table.insert(PCs, PC)
      end
    elseif type(playerId) == "table" and #playerId > 0 then
      for _, value in ipairs(playerId) do
        local inEvent, PC = IsPlayerInAnyEvent(value)
        if not inEvent and PC then
          table.insert(PCs, PC)
        end
      end
    else
      return json.stringify { error = "Invalid player ID given" }, nil, 400
    end

    if #PCs <= 0 then
      return json.stringify { error = "No valid player to join event" }, nil, 400
    end

    if eventSystem:IsValid() then
      for i = 1, #eventSystem.Net_Events do
        local event = eventSystem.Net_Events[i]

        if GuidToString(event.EventGuid) == eventGuid:upper() then
          local guid = StringToGuid(eventGuid)
          ExecuteInGameThread(function()
            for _, value in ipairs(PCs) do
              if value:IsValid() then
                value:ServerJoinEvent(guid)
              end
            end
          end)

          local id = type(data.PlayerId) == "string" and data.PlayerId or table.concat(data.PlayerId, ", ")
          local msg = string.format("Set player %s to join event %s", id, eventGuid)
          return json.stringify { message = msg }, nil, 201
        end
      end
      return json.stringify { error = string.format("Failed to find event %s", eventGuid) }, nil, 404
    end
    return json.stringify { error = "Invalid event system or player ID" }, nil, 400
  end
  return json.stringify { error = "Invalid payload" }, nil, 400
end

---Handle request to forcefully remove a player from an event
---@type RequestPathHandler
local function HandlePlayerLeaveEvent(session)
  local eventGuid = session.pathComponents[2]
  local data = json.parse(session.content)

  if eventGuid and data then
    local eventSystem = GetEventSystem()
    local playerId = data.PlayerId ---@type string|string[]|nil
    local PCs = {} ---@type AMotorTownPlayerController[]

    if eventSystem:IsValid() then
      for i = 1, #eventSystem.Net_Events do
        local event = eventSystem.Net_Events[i]
        if GuidToString(event.EventGuid) == eventGuid:upper() then
          -- Making sure that player is actually in the event
          local ids = {}
          for j = 1, #event.Players do
            local player = event.Players[j]
            local eventPlayerId = player.CharacterId.UniqueNetId:ToString()
            if (type(playerId) == "string" and playerId == eventPlayerId) or (type(playerId) == "table" and ListContains(playerId, eventPlayerId)) or type(playerId) == "nil" then
              table.insert(PCs, player.PC)
              table.insert(ids, eventPlayerId)
            end
          end

          if #PCs <= 0 then
            return json.stringify { error = "No valid player to be removed from event" }, nil, 400
          end

          local guid = StringToGuid(eventGuid)
          ExecuteInGameThread(function()
            for _, value in ipairs(PCs) do
              if value:IsValid() then
                value:ServerLeaveEvent(guid)
              end
            end
          end)

          local msg = string.format("Removed player %s from event %s", table.concat(ids, ", "), eventGuid)
          return json.stringify { message = msg }, nil, 201
        end
      end
      return json.stringify { error = string.format("Failed to find event %s", eventGuid) }, nil, 404
    end
    return json.stringify { error = "Invalid event system" }, nil, 400
  end
  return json.stringify { error = "Invalid payload" }, nil, 400
end

return {
  GetEvents = GetEvents,
  HandleGetEvents = HandleGetEvents,
  HandleUpdateEvent = HandleUpdateEvent,
  HandleCreateNewEvent = HandleCreateNewEvent,
  HandleChangeEventState = HandleChangeEventState,
  HandleRemoveEvent = HandleRemoveEvent,
  HandlePlayerJoinEvent = HandlePlayerJoinEvent,
  HandlePlayerLeaveEvent = HandlePlayerLeaveEvent,
}
