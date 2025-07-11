# Event management

#### GET `/events`

Get all active events.

<details>
<summary>Response data:</summary>

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

</details>

#### POST `/events`

Create a new event. Will return the new event data similar to above if successful.

<details>
<summary>Response data:</summary>

```json
{
  "EventName": "EnhancedBrow's Event",
  "EventType": 1,
  "RaceSetup": {
    "NumLaps": 0,
    "Route": {
      "RouteName": "My Super Track",
      "Waypoints": [
        {
          "Translation": {
            "X": -388146.600618,
            "Y": 630854.981784,
            "Z": -11157.142135
          },
          "Scale3D": {
            "X": 1,
            "Y": 19,
            "Z": 10
          },
          "Rotation": {
            "X": 0,
            "Y": 0,
            "Z": 0.5696381972391096,
            "W": 0.8218955677251077
          }
        },
        {
          "Translation": {
            "X": -386101.669514,
            "Y": 656907.891716,
            "Z": -11137.687317
          },
          "Scale3D": {
            "X": 1,
            "Y": 28,
            "Z": 10
          },
          "Rotation": {
            "X": 0,
            "Y": 0,
            "Z": 0.7823908105765881,
            "W": 0.6227877804881126
          }
        }
      ]
    },
    "VehicleKeys": [],
    "EngineKeys": []
  }
}
```

</details>

#### GET `/events/<guid>`

Returns the specified event. Outputs the same response JSON as `GET /events`, but only for a single object.

#### POST `/events/<guid>`

Update event data. Currently only supports changing the event name and/or race setup. Will return the event data similar as above if successful.

<details>
<summary>Request body:</summary>

```json
{
  "EventName": "New event name",
  "RaceSetup": {
    "NumLaps": 0,
    "Route": {
      "RouteName": "My Super Track",
      "Waypoints": [
        {
          "Translation": {
            "X": -388146.600618,
            "Y": 630854.981784,
            "Z": -11157.142135
          },
          "Scale3D": {
            "X": 1,
            "Y": 19,
            "Z": 10
          },
          "Rotation": {
            "X": 0,
            "Y": 0,
            "Z": 0.5696381972391096,
            "W": 0.8218955677251077
          }
        },
        {
          "Translation": {
            "X": -386101.669514,
            "Y": 656907.891716,
            "Z": -11137.687317
          },
          "Scale3D": {
            "X": 1,
            "Y": 28,
            "Z": 10
          },
          "Rotation": {
            "X": 0,
            "Y": 0,
            "Z": 0.7823908105765881,
            "W": 0.6227877804881126
          }
        }
      ]
    },
    "VehicleKeys": [],
    "EngineKeys": []
  }
}
```

</details>

#### DELETE `/events/<guid>`

Remove an event based on the given GUID. Will return `204` code if successful.

#### POST `/events/<guid>/state`

Change the state of a given event GUID. Will return a `204` code if successful. This function might fail if there are no players in-game.

<details>
<summary>Request body:</summary>

```json
{
  // Ready = 1,
  // InProgress = 2,
  // Finished = 3,
  "State": 1
}
```

</details>
