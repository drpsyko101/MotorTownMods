# Event Webhooks

Requires `socket` module installed and `MOD_WEBHOOK_URL` environment variable set to function properly. Most of the event hook payloads have similarities with the REST API endpoints return data.

### Events

#### Event creation

Returns the new event data.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerAddEvent",
  "timestamp": 1752044853012,
  "data": [
    {
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
  ]
}
```

</details>

#### Event state changed

Returns the GUID of the event and the new event state.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerChangeEventState",
  "timestamp": 1752044853012,
  "data": [
    // similar event structure as above
  ]
}
```

</details>

#### Event removal

Returns the GUID of the removed event.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerRemoveEvent",
  "timestamp": 1752044853012,
  "data": {
    "EventGuid": "835BB8FD4104E369D33C6BA74C41922A"
  }
}
```

</details>

#### Event checkpoint update

Called when a player passed an event checkpoint.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerPassedRaceSection",
  "timestamp": 1752044853012,
  "data": {
    "SenderGuid": "",
    "EventGuid": "",
    "SectionIndex": -1,
    "TotalTimeSeconds": 0,
    "LaptimeSeconds": 0
  }
}
```

</details>

#### Player joined an event

Called when a player joined an event.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerJoinEvent",
  "timestamp": 1752044853012,
  "data": {
    "SenderGuid": "",
    "EventGuid": ""
  }
}
```

</details>

#### Player left an event

Called when a player left an event.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerLeaveEvent",
  "timestamp": 1752044853012,
  "data": {
    "SenderGuid": "",
    "EventGuid": ""
  }
}
```

</details>

### Cargo

#### Cargo accept delivery

Called when a player accepted a cargo delivery.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerAcceptDelivery",
  "timestamp": 1752044853012,
  "data": { "DeliveryId": 27, "Sender": "EA50F9CE42B8A468F4FBFE8C42AD87ED" }
}
```

</details>
