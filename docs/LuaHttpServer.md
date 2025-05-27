# Lua HTTP Server

## REST Endpoints

Query parameter and/or request body is not needed unless specified.

### General server settings

#### GET `/status`

Returns Lua HTTP server status.

Response:
```json
{"status":"ok"}
```

### Player Management

#### GET `/players`

Returns all available player states.

Response:
```json
{
  "data": [
    {
      "Levels": [1, 1, 1, 1, 1, 1, 1],
      "OwnEventGuids": [],
      "GridIndex": 0,
      "bIsAdmin": true,
      "bIsHost": true,
      "CustomDestinationAbsoluteLocation": { "X": 0.0, "Y": 0.0, "Z": 0.0 },
      "JoinedEventGuids": ["6E6705764C17B7F764098091A10567E7"],
      "PlayerName": "EnhancedBrow",
      "Location": { "X": -48375.038, "Y": 152602.669, "Z": -20900.902 },
      "BestLapTime": 0.0,
      "VehicleKey": "None",
      "JoinedCompanyGuid": "0000",
      "CharacterGuid": "EA50F9CE42B8A468F4FBFE8C42AD87ED",
      "OwnCompanyGuid": "0000"
    }
  ]
}
```

#### GET `/players/<guid>`

Returns the specified player state. Output the same response JSON as above.

### Event management

#### GET `/events`

Get all active events

Response:
```json
{
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
      "Players": [
        {
          "Rank": 0,
          "Laps": 0,
          "bWrongVehicle": false,
          "Reward_RacingExp": 0,
          "LapTimes": [],
          "LastSectionTotalTimeSeconds": 0.0,
          "bDisqualified": false,
          "PlayerName": "EnhancedBrow",
          "Reward_Money": { "BaseValue": 0, "ShadowedValue": 521312 },
          "BestLapTime": 0.0,
          "CharacterId": {
            "CharacterGuid": "EA50F9CE42B8A468F4FBFE8C42AD87ED",
            "UniqueNetId": "76561198041602277"
          },
          "SectionIndex": -1,
          "bWrongEngine": false,
          "bFinished": false
        }
      ],
      "EventGuid": "6E6705764C17B7F764098091A10567E7",
      "EventName": "EnhancedBrow's Event"
    }
  ]
}
```

#### GET `/events/<guid>`

Returns the specified event. Output the same response JSON as above.

#### POST `/events/<guid>`

Update event data. Currently only supports event name change. Will return the event data similar as above if successful.

Request body:
```json
{ "EventName": "New event name" }
```

## Webhooks

### Events

#### Event creation

Returns the new event data:
```json
{
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

#### Event removal

Returns the GUID of the removed event
```json
{
  "data": [
    "835BB8FD4104E369D33C6BA74C41922A"
  ]
}
```
