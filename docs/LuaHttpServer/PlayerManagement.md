# Player management

#### GET `/players`

Returns all available player states.

<details>
<summary>Query:</summary>

- `filters` (string|multi) - `Levels`,`OwnEventGuids`,`GridIndex`,`bIsAdmin`,`bIsHost`,`CustomDestinationAbsoluteLocation`,`JoinedEventGuids`,`PlayerName`,`Location`,`BestLapTime`,`VehicleKey`,`JoinedCompanyGuid`,`CharacterGuid`,`OwnCompanyGuid`
- `limit` (integer) - Limit the amount of results returned
- `depth` (integer|default `2`) - Recursive search depth limit

</details>

<details>
<summary>Response data:</summary>

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

</details>

#### GET `/players/<uniqueId>`

Returns the specified player state based on the player unique net ID. Output the same response JSON as above.

#### POST `/players/<uniqueId>/teleport`

Teleport a player pawn to the desired location and optionally its rotation.

<details>
<summary>Request body:</summary>

```json
{
  "Location": {
    "X": 0.0,
    "Y": 0.0,
    "Z": 0.0
  },
  "Rotation": {
    "Pitch": 0.0,
    "Roll": 0.0,
    "Yaw": 0.0
  }
}
```

</details>

<details>
<summary>Response data:</summary>

```json
{
  "status": "Teleported player 76561198041602276 to {\"X\":-191656.25868804,\"Y\":-68211.974820721,\"Z\":-19425.726114405}"
}
```

</details>

#### POST `/players/<uniqueId>/money`

Add a specific amount of money to a player.

<details>
<summary>Request body:</summary>

```json
{
  "Amount": 1000, // Optional amount. Defaults to 0.
  "Message": "Here is some money", // Optional message to be displayed.
  "AllowNegative": false // Allow player to go into debt
}
```

</details>

#### DELETE `/players/<uniqueId>/gameplay/effects`

Remove a specific amount from the gameplay effect stack. Useful for removing GAS related effect without specifying the tag. Currently only used for removing `Police.Suspect` effect.

<details>
<summary>Request body:</summary>

```json
{
  "Amount": 1 // Optional amount. Defaults to 1.
}
```

</details>

<details>
<summary>Response data:</summary>

```json
{
  "message": "Successfully removed gameplay effect"
}
```

</details>

#### POST `/players/<uniqueId>/eject`

Forcefully eject a player from a vehicle.

<details>
<summary>Response data:</summary>

```json
{
  "status": "ok"
}
```

</details>
