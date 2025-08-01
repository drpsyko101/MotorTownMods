# Webserver managements

#### POST `/stop`

Stop the webserver. Useful for restarting the Lua mods. Note that it will still try to complete any ongoing request before stopping. Future request will be rejected.

<details>
<summary>Response data:</summary>

Returns `200 OK` for successful stop command. Will output `Webserver stopped` in the log to confirm the full webserver shutdown.

</details>

#### GET `/status`

Returns Lua HTTP server status. Doesn't require any authentication.

<details>
<summary>Response data:</summary>

Returns `200 OK` if ready to accept connection:

```json
{ "status": "ok" }
```

Returns `503 Service Unavailable` if not ready to accept any connection:

```json
{ "status": "not ready" }
```

</details>

#### GET `/status/general`

Returns general server status

<details>
<summary>Response data:</summary>

```json
{
  "data": {
    "ZoneStates": [
      {
        "BusTransportRate": 0.0,
        "NumResidents": 42,
        "Supermarkets": [{}],
        "Server_Volume": {},
        "ZoneKey": "Ara",
        "FoodSupplyRate": 0.0,
        "GarbageCollectRate": 0.0,
        "PolicePatrolRate": 0.0
      },
      {
        "BusTransportRate": 0.0,
        "NumResidents": 11,
        "Supermarkets": [{}],
        "Server_Volume": {},
        "ZoneKey": "Gwangjin",
        "FoodSupplyRate": 0.0,
        "GarbageCollectRate": 0.0,
        "PolicePatrolRate": 0.0
      },
      {
        "BusTransportRate": 0.0,
        "NumResidents": 64,
        "Supermarkets": [{}],
        "Server_Volume": {},
        "ZoneKey": "Gangjung",
        "FoodSupplyRate": 0.0,
        "GarbageCollectRate": 0.0,
        "PolicePatrolRate": 0.0
      },
      {
        "BusTransportRate": 0.0,
        "NumResidents": 63,
        "Supermarkets": [{}],
        "Server_Volume": {},
        "ZoneKey": "Jeju",
        "FoodSupplyRate": 0.0,
        "GarbageCollectRate": 0.0,
        "PolicePatrolRate": 0.0
      },
      {
        "BusTransportRate": 0.0,
        "NumResidents": 24,
        "Supermarkets": [{}],
        "Server_Volume": {},
        "ZoneKey": "Hallim",
        "FoodSupplyRate": 0.0,
        "GarbageCollectRate": 0.0,
        "PolicePatrolRate": 0.0
      },
      {
        "BusTransportRate": 0.0,
        "NumResidents": 31,
        "Supermarkets": [{}],
        "Server_Volume": {},
        "ZoneKey": "Seongsan",
        "FoodSupplyRate": 0.0,
        "GarbageCollectRate": 0.0,
        "PolicePatrolRate": 0.0
      },
      {
        "BusTransportRate": 0.0,
        "NumResidents": 20,
        "Supermarkets": [{}],
        "Server_Volume": {},
        "ZoneKey": "Gapa",
        "FoodSupplyRate": 0.0,
        "GarbageCollectRate": 0.0,
        "PolicePatrolRate": 0.0
      }
    ],
    "GarbageCollectRate": 0.0,
    "NumResidents": 255,
    "PolicePatrolRate": 0.0,
    "ServerPlatformTimeSeconds": 16793104.642075,
    "FoodSupplyRate": 0.0,
    "BusTransportRate": 0.0,
    "FPS": 75
  }
}
```

</details>

#### GET `/status/general/<zone>`

Returns a specific zone status. Available zone keys can be found from `/status/general` data.

<details>
<summary>Response data:</summary>

```json
{
  "data": {
    "FoodSupplyRate": 0.0,
    "BusTransportRate": 0.0,
    "GarbageCollectRate": 0.0,
    "NumResidents": 65,
    "Supermarkets": [{}],
    "Server_Volume": {},
    "ZoneKey": "Gangjung",
    "PolicePatrolRate": 0.0
  }
}
```

</details>

#### GET `/settings/traffic`

Get the current traffic settings.

<details>
<summary>Response data:</summary>

```json
{
  "data": {
    "DeliveryVehicleSpawnPoints": [],
    "SpawnSettings": [
      {
        "bDespawnIfPlayersAreFar": true,
        "SettingKey": "Small",
        "VehicleKey": "None",
        "bUseNPCPoliceDensity": false,
        "SpawnType": 0,
        "bSpawnAIController": true,
        "VehicleTypes": [330498818, 1444131587],
        "MaxLifetimeSeconds": 0,
        "bDespawnIfNotMoveForLong": true,
        "bAllowCloseToPlayer": false,
        "MaxDistanceFromRoad": -1,
        "CountMultiplierScheduleType": 0,
        "SpawnOverMinCountCoolDownTimeSeconds": 60,
        "MinDistanceFromRoad": -1,
        "GameplayTagQuery2": {
          "AutoDescription": "",
          "TokenStreamVersion": 0,
          "TagDictionary": {},
          "QueryTokenStream": {},
          "UserDescription": ""
        },
        "bAllowCloseToOtherVehicle": false,
        "bUseNPCVehicleDensity": true,
        "bSpawnRoadSide": false,
        "MaxCount": 250,
        "GameplayTagQuery": {
          "AutoDescription": " NONE( Vehicle.Police )",
          "TokenStreamVersion": 0,
          "TagDictionary": [{ "TagName": "Vehicle.Police" }],
          "QueryTokenStream": [16974080, 66305, 16777475, 65537, 256],
          "UserDescription": ""
        },
        "bIsTrafficVehicle": true,
        "bIncludeTrailer": false,
        "MinCount": -1
      }
    ]
  }
}
```

</details>

#### POST `/settings/traffic`

Update the traffic related settings. Vehicle type parameter is optional. This request overrides the current traffic configuration in-game. To restore to the value from the dedicated config or the initial single player settings, a map restart is required.

<details>
<summary>Request body:</summary>

```json
{
  // Vehicle type can be one or many of Small, Special, Truck, Bus, Police, Tow_Ld, Tow, Tow_Heavy, Rescue, HeavyRescue, VehicleDelivery ,VehicleDeliveryHeavy, Getaway
  // Defaults to Small, Special, Truck, Bus if not specified
  "VehicleTypes": ["Small", "Special", "Truck", "Bus"],
  "NPCVehicleDensity": 1.0,
}
```

</details>

<details>
<summary>Response data:</summary>

```json
{ "status": "ok" }
```

</details>

#### PATCH `/settings`

Change game server settings. Each field is optional and not mutually exclusive to each other.

<details>
<summary>Request body:</summary>

```json
{
  "MaxVehiclePerPlayer": 9, // Set a new player maximum spawnable vehicle limit.
  "bAllowModdedVehicle": false, // Set to allow use of modded vehicles
  "MaxHousingPlotRentalDays": 7, // Adjust max house rental duration in days
  "MaxHousingPlotRentalPerPlayer": 1, // Set the max plot a player can have at a given time
  "ServerMessage": "<Title>This is a new server message!</>", // Set server message for newly logged in player
  "HousingPlotRentalPriceRatio": 0.5, // Set the rental rate per days
  "bAllowCompanyAIDriver": true // Allow AI driver in company
}
```

</details>

<details>
<summary>Response data:</summary>

```json
{
  "data": {
    "Net_ServerConfig": {
      "bAllowCompanyAIDriver": true,
      "MaxHousingPlotRentalPerPlayer": 1,
      "bAllowModdedVehicle": false,
      "HousingPlotRentalPriceRatio": 0.10000000149012,
      "PinnedAnnounce": "This is a message from kambing",
      "bAllowPlayerToJoinWithCompanyVehicles": false,
      "MaxVehiclePerPlayer": 9,
      "MaxHousingPlotRentalDays": 7,
      "ServerMessage": "<Title>This is a new server message!</>"
    }
  }
}
```

</details>

#### POST `/command`

Execute a console command on the server. Optionally can be executed on a specific player controller.

<details>
<summary>Request body:</summary>

```json
{
  "Command": "mh.aIVehicleStuckTimeSeconds=120",
  "PlayerId": ""
}
```

</details>

<details>
<summary>Response data:</summary>

```json
{ "status": "ok" }
```

</details>
