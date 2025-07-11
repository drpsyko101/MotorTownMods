# Player management

#### GET `/players`

Returns all available player states.

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

#### GET `/players/<guid>`

Returns the specified player state. Output the same response JSON as above.
