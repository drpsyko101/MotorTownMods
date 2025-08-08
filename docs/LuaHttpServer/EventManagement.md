# Event management

#### GET `/events`

Get all active events.

<details>
<summary>Response data:</summary>

```json
{
  "data": [
    {
      "bInCountdown": false,
      "State": 1,
      "RaceSetup": {
        "VehicleKeys": {},
        "EngineKeys": {},
        "Route": {
          "Waypoints": [
            {
              "Rotation": {
                "X": 0.0045868361219863,
                "Y": -0.0018976408556407,
                "Z": 0.92403108991185,
                "W": 0.3822851092704
              },
              "Scale3D": { "X": 1, "Y": 14, "Z": 10 },
              "Translation": {
                "X": -97056.398061863,
                "Y": -117563.48387672,
                "Z": -21050.320972118
              }
            },
            {
              "Rotation": {
                "X": 0.0014406319799756,
                "Y": -0.0068644038787254,
                "Z": 0.20539026277856,
                "W": 0.97865501812163
              },
              "Scale3D": { "X": 1, "Y": 14, "Z": 10 },
              "Translation": {
                "X": -93947.847830481,
                "Y": -126853.16521403,
                "Z": -21477.158924869
              }
            },
            {
              "Rotation": {
                "X": -0.007671052646189,
                "Y": 0.00060647783012685,
                "Z": 0.9968597732292,
                "W": 0.078812306484315
              },
              "Scale3D": { "X": 1, "Y": 14, "Z": 10 },
              "Translation": {
                "X": -212976.81696971,
                "Y": -97408.83208708,
                "Z": -21545.762334066
              }
            },
            {
              "Rotation": {
                "X": 0.017288231758791,
                "Y": -0.03607338218842,
                "Z": 0.43183666206309,
                "W": 0.90106432924534
              },
              "Scale3D": { "X": 1, "Y": 14, "Z": 10 },
              "Translation": {
                "X": -222430.29234268,
                "Y": -89493.65477886,
                "Z": -21473.098844742
              }
            },
            {
              "Rotation": {
                "X": 0.04035149366434,
                "Y": 0.00079851064577432,
                "Z": -0.99898964493809,
                "W": 0.019768880754114
              },
              "Scale3D": { "X": 1, "Y": 14, "Z": 10 },
              "Translation": {
                "X": -204969.76993894,
                "Y": -62400.74385912,
                "Z": -19238.334390573
              }
            },
            {
              "Rotation": {
                "X": 0.0022522273808386,
                "Y": -0.013915128851652,
                "Z": 0.15975942882025,
                "W": 0.98705532852211
              },
              "Scale3D": { "X": 1, "Y": 14, "Z": 10 },
              "Translation": {
                "X": -168594.6087996,
                "Y": -68971.508357785,
                "Z": -18735.925517306
              }
            },
            {
              "Rotation": {
                "X": -0,
                "Y": 0,
                "Z": -0.42259649839941,
                "W": 0.90631793513124
              },
              "Scale3D": { "X": 1, "Y": 14, "Z": 10 },
              "Translation": {
                "X": -138576.74154581,
                "Y": -71776.48480768,
                "Z": -18199.999593198
              }
            }
          ],
          "RouteName": "Jalan Kambing"
        },
        "NumLaps": 3
      },
      "EventGuid": "1A0DE0C7673055F552B86B9297530EC",
      "Players": {},
      "EventName": "The best event ever!",
      "EventType": 1,
      "OwnerCharacterId": { "UniqueNetId": "", "CharacterGuid": "0000" }
    }
  ]
}
```

</details>

#### POST `/events`

Create a new event. Will return the new event data similar to above if successful. Note that the event will be automatically removed in 10 minutes if no players are in the event, or all participants are idling.

<details>
<summary>Response data:</summary>

```json
{
  "RaceSetup": {
    "EngineKeys": {},
    "Route": {
      "Waypoints": [
        {
          "Rotation": {
            "Y": -0.0018976408556407,
            "X": 0.0045868361219863,
            "W": 0.3822851092704,
            "Z": 0.92403108991185
          },
          "Translation": {
            "Y": -117563.48387672,
            "X": -97056.398061863,
            "Z": -21050.320972118
          },
          "Scale3D": { "Y": 14, "X": 1, "Z": 10 }
        },
        {
          "Rotation": {
            "Y": -0.0068644038787254,
            "X": 0.0014406319799756,
            "W": 0.97865501812163,
            "Z": 0.20539026277856
          },
          "Translation": {
            "Y": -126853.16521403,
            "X": -93947.847830481,
            "Z": -21477.158924869
          },
          "Scale3D": { "Y": 14, "X": 1, "Z": 10 }
        }
      ],
      "RouteName": "Jalan Kambing"
    },
    "VehicleKeys": {},
    "NumLaps": 3
  },
  "EventName": "The best event ever!",
  "OwnerCharacterId": { // Optional event host
    "UniqueNetId": "",
    "CharacterGuid": "" // Optional character ID. Beware that nonexistant character or typo here might cause ownership error
  }
}
```

</details>

#### GET `/events/<guid>`

Returns the specified event. Outputs the same response JSON as `GET /events`, but only for a single object.

#### PATCH `/events/<guid>`

Update event data. Currently only supports changing the event name, host and/or race setup. Will return the event data similar as above if successful.

<details>
<summary>Request body:</summary>

```json
{
  "EventName": "New event name",  // Optional event name
  "OwnerCharacterId": {           // Optional event host
    "UniqueNetId": "",
    "CharacterGuid": ""
  },
  "RaceSetup": {                  // Optional event race setup
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

Remove an event based on the given GUID. Will return `201` code if successful.

<details>
<summary>Response data:</summary>

```json
{"message":"Event 3D5828EF7F06DF4561EAD97C19D2BFE9 removed"}
```

</details>

#### POST `/events/<guid>/state`

Change the state of a given event GUID. Will return a `201` code if successful. This function might fail if there are no players in-game.

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

<details>
<summary>Response data:</summary>

```json
{"message":"Changed event 77ADA819E358E035802ECA554ADBDA4A state from 1 to 2"}
```

</details>

#### POST `/events/<guid>/players`

Add player(s) into an event. This endpoint might fail if a player is already in an active event.

<details>
<summary>Request body:</summary>

Adding a single player:

```json
{
  "PlayerId": ""
}
```

Adding multiple players:

```json
{
  "PlayerId": [""]
}
```

</details>

<details>
<summary>Response data:</summary>

```json
{"message":"Set player 76561198041602276 to join event 3D5828EF7F06DF4561EAD97C19D2BFE9"}
```
</details>

#### DELETE `/events/<guid>/players`

Remove player(s) from an event. Calling this endpoint without any request body will remove all players from an event.

<details>
<summary>Request body:</summary>

Removing a single player:

```json
{
  "PlayerId": ""
}
```

Removing multiple players:

```json
{
  "PlayerId": [""]
}
```

</details>

<details>
<summary>Response data:</summary>

```json
{"message":"Set player 76561198041602276 to join event 3D5828EF7F06DF4561EAD97C19D2BFE9"}
```
</details>
