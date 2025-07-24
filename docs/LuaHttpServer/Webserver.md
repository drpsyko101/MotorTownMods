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
        "ZoneKey": "Ara",
        "FoodSupplyRate": 0.0,
        "GarbageCollectRate": 0.0,
        "PolicePatrolRate": 0.0
      },
      {
        "BusTransportRate": 0.0,
        "NumResidents": 11,
        "ZoneKey": "Gwangjin",
        "FoodSupplyRate": 0.0,
        "GarbageCollectRate": 0.0,
        "PolicePatrolRate": 0.0
      },
      {
        "BusTransportRate": 0.0,
        "NumResidents": 64,
        "ZoneKey": "Gangjung",
        "FoodSupplyRate": 0.0,
        "GarbageCollectRate": 0.0,
        "PolicePatrolRate": 0.0
      },
      {
        "BusTransportRate": 0.0,
        "NumResidents": 63,
        "ZoneKey": "Jeju",
        "FoodSupplyRate": 0.0,
        "GarbageCollectRate": 0.0,
        "PolicePatrolRate": 0.0
      },
      {
        "BusTransportRate": 0.0,
        "NumResidents": 24,
        "ZoneKey": "Hallim",
        "FoodSupplyRate": 0.0,
        "GarbageCollectRate": 0.0,
        "PolicePatrolRate": 0.0
      },
      {
        "BusTransportRate": 0.0,
        "NumResidents": 31,
        "ZoneKey": "Seongsan",
        "FoodSupplyRate": 0.0,
        "GarbageCollectRate": 0.0,
        "PolicePatrolRate": 0.0
      },
      {
        "BusTransportRate": 0.0,
        "NumResidents": 20,
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
    "ZoneKey": "Gangjung",
    "PolicePatrolRate": 0.0
  }
}
```

</details>

#### POST `/status/traffic`

Update the traffic related settings. Each request parameter is optional.

<details>
<summary>Request body:</summary>

```json
{
  "NPCVehicleDensity": 1.0,
  "MaxVehiclePerPlayer": 10
}
```

</details>

<details>
<summary>Response data:</summary>

```json
{ "status": "ok" }
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
