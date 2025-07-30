# Property management

#### GET `/houses`

Returns all houses in the game.

<details>
<summary>Response data:</summary>

```json
{
  "data": [
    {
      "Location": {
        "Y": 153095.171875,
        "Z": -20989.853515625,
        "X": -54631.31640625
      },
      "Net_OwnerCharacterGuid": "EA50F9CE42B8A468F4FBFE8C42AD87ED",
      "AreaSize": { "Y": 2300.0, "Z": 2000.0, "X": 2500.0 },
      "Net_RentLeftTimeSeconds": -1.0,
      "Net_OwnerName": "EnhancedBrow",
      "ForSale": false,
      "HousegKey": "FirstHouse",
      "Net_OwnerUniqueNetId": "76561198041602277",
      "FenceStep": 200.0,
      "Teleport": {
        "Y": 154461.02123321,
        "Z": -20990.000000828,
        "X": -55425.852504868
      },
      "Rotation": { "Pitch": 0.0, "Roll": 0.0, "Yaw": 96.066780090332 }
    }
  ]
}
```

</details>

#### GET `/houses/<guid>`

Returns a house with the givent GUID. Returns similar data as above.

#### POST `/houses/spawn`

Spawn a house plot for sale. Returns a `201` status if the plot successfully spawned. Can be despawned using POST `/assets/despawn` with the resulting GUID. The house can only be purchased if the corresponding house GUID and dataset exists in the `MotorTown/Content/DataAsset/Houses.uasset` data table.

<details>
<summary>Request body:</summary>

```json
{
  "Location": {
    "Z": -19719.254892776,
    "Y": -102554.50214499,
    "X": -16507.28222902
  },
  "Rotation": {
    "Roll": 0.0,
    "Pitch": 0.0,
    "Yaw": -24.493621826172
  },
  "HouseParam": {
    "AreaSize": {
      "X": 4500.0,
      "Y": 4500.0,
      "Z": 5000.0
    },
    "HouseKey": "KambingHouse",
    "HouseGuid": "8BADB28B13C6345A9487E957D0D5D4D8"
  }
}
```

</details>

<details>
<summary>Response data:</summary>

```json
{
  "data": {
    "HouseGuid": "8BADB28B13C6345A9487E957D0D5D4D8"
  }
}
```

</details>
