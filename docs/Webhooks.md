# Event Webhooks

Requires `socket` module installed and `MOD_WEBHOOK_URL` environment variable set to function properly. Most of the event hook payloads have similarities with the REST API endpoints return data. Webhook can be enabled separately using `MOD_WEBHOOK_ENABLE_EVENTS` environment variable according to the code block in their headings respectively. All event hooks are enabled by default.

### Events

#### Event creation - `ServerAddEvent`

Returns the new event data.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerAddEvent",
  "timestamp": 1752044853012,
  "data": {    
    "PlayerId": "",
    "Event": {
      "State": 1,
      "EventType": 1,
      "RaceSetup": {
        "NumLaps": 0,
        "Route": { "RouteName": "", "Waypoints": [] },
        "VehicleKeys": [],
        "EngineKeys": []
      },
      "bInCountdown": false,
      "OwnerCharacterId": {
        "CharacterGuid": "EA50F9CE42B8A468F4FBFE8C42AD87ED",
        "UniqueNetId": "76561198041602277"
      },
      "Players": [],
      "EventGuid": "6E6705764C17B7F764098091A10567E7",
      "EventName": "EnhancedBrow's Event"
    }
  }
}
```

</details>

#### Event state changed - `ServerChangeEventState`

Returns the GUID of the event and the new event state.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerChangeEventState",
  "timestamp": 1752044853012,
  "data": {
    // similar event structure as above
  }
}
```

</details>

#### Event removal - `ServerRemoveEvent`

Returns the GUID of the removed event.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerRemoveEvent",
  "timestamp": 1752044853012,
  "data": {
    "PlayerId": "",
    "EventGuid": "835BB8FD4104E369D33C6BA74C41922A"
  }
}
```

</details>

#### Event checkpoint update - `ServerPassedRaceSection`

Called when a player passed an event checkpoint.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerPassedRaceSection",
  "timestamp": 1752044853012,
  "data": {
    "PlayerId": "",
    "EventGuid": "",
    "SectionIndex": -1,
    "TotalTimeSeconds": 0,
    "LaptimeSeconds": 0
  }
}
```

</details>

#### Player joined an event - `ServerJoinEvent`

Called when a player joined an event.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerJoinEvent",
  "timestamp": 1752044853012,
  "data": {
    "PlayerId": "",
    "EventGuid": ""
  }
}
```

</details>

#### Player left an event - `ServerLeaveEvent`

Called when a player left an event.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerLeaveEvent",
  "timestamp": 1752044853012,
  "data": {
    "PlayerId": "",
    "EventGuid": ""
  }
}
```

</details>

### Cargo

#### Cargo accept delivery - `ServerAcceptDelivery`

Called when a player accepted a cargo delivery.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerAcceptDelivery",
  "timestamp": 1752044853012,
  "data": { "DeliveryId": 27, "PlayerId": "" }
}
```

</details>

### Chat

### Player chat sent - `ServerSendChat`

Called when a player send a chat.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerSendChat",
  "timestamp": 1752044853012,
  "data": {
      "Sender": "",
      "Message": "",
      "Category": 0 // Normal = 0, Announce = 1, Company = 2, Event = 3, WhisperIn = 4, WhisperOut = 5
  }
}
```

</details>
