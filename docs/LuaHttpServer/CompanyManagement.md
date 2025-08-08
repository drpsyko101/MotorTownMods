# Company Management

#### GET `/depots`

Get all depots in the game.

<details>
<summary>Response data:</summary>

```json
[
  {
    "StorageMultiplier": 1.2000000476837,
    "BuildingGuid": "25BD62274460B519F5E01A9F25D3D9E3",
    "Name": "Depot",
    "Server_Building": {},
    "CompanyGuid": "944281B2490D9482F7DF2DB26E345637",
    "Storage": 1,
    "bIsUnderConstruction": true,
    "NumActiveVehicles": 0,
    "RunningCostPer10Mins": 60
  }
]
```

</details>

#### GET `/companies`

Get all companies active in the game.

<details>
<summary>Query:</summary>

* `depth` - Recursive search depth

</details>

<details>
<summary>Response data:</summary>

```json
[
  {
    "PendingRunningCost": 1,
    "AddedVehicleSlots": 0,
    "bDeactivated": false,
    "OwnerCharacterName": "EnhancedBrow",
    "OwnerCharacterId": {
      "CharacterGuid": "EA50F9CE42B8A468F4FBFE8C42AD87ED",
      "UniqueNetId": "76561198041602276"
    },
    "BusProfitShareToApply": 65,
    "OwnerPC": {},
    "Players": [{}],
    "Money": {
      "BaseValue": 0,
      "ShadowedValue": 521312
    },
    "JoinRequests": {},
    "Guid": "944281B2490D9482F7DF2DB26E345637",
    "TruckRoutes": {},
    "OwnVehicleWorldData": {},
    "BusRoutes": [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}],
    "TruckProfitShareToApply": 0,
    "ContractsInProgress": {},
    "Settings": {
      "Name": "Kambing Incorporated",
      "ShortDesc": ""
    },
    "OwnVehicles": {},
    "Roles": [{}, {}, {}],
    "bIsCorporation": false,
    "MoneyTransactions": {},
    "IdleDurationSeconds": 26.354810900986,
    "OwnVehicleParts": {},
    "Vehicles": [{}, {}]
  }
]
```

</details>

#### GET `/companies/<guid>`

Get company by the given GUID. Returns the same data as above as a single object.

#### GET `/companies/<guid>/depots`

Get all depots registered in a company. Returns the same response data as [`GET /deppots`](#get-depots).

#### GET `/companies/<guid>/vehicles`

Get a list of vehicles in a company.

<details>
<summary>Response data:</summary>

```json
[
  {
    "ProblemText": "",
    "VehicleId": 3,
    "VehicleState": 2,
    "TotalRunningCost": 27,
    "DonatorVehicleId": 3,
    "Setting": {
      "VehicleName": "Bongo",
      "RouteGuid": "46E510044E87089B23341EAD434DFB94"
    },
    "DailyStats": [{}],
    "VehicleFlags": 5,
    "RoutePointIndex": 2,
    "VehicleKey": "Bongo",
    "VehicleActor": {},
    "LastUserCharacterId": {
      "CharacterGuid": "EA50F9CE42B8A468F4FBFE8C42AD87ED",
      "UniqueNetId": "76561198041602276"
    },
    "TotalProfitShare": 0,
    "UserCharacterId": {
      "CharacterGuid": "00000000000000000000000000000000",
      "UniqueNetId": ""
    }
  }
]
```

</details>

#### GET `/companies/<guid>/routes/bus`

Get the company bus routes.

<details>
<summary>Response data:</summary>

```json
[
  {
    "Guid": "46E510044E87089B23341EAD434DFB94",
    "Points": [
      {
        "PointGuid": "A65E6E4647093938401CD2965BB6BCBA",
        "RouteFlags": 0
      },
      {
        "PointGuid": "93B5867E4AC019E5F92835B960C7CDC4",
        "RouteFlags": 0
      },
      {
        "PointGuid": "1E32D13A45A80C9C007EDC9F38DDAF10",
        "RouteFlags": 0
      },
      {
        "PointGuid": "BF87062B4E2269E18B4F4197B3E52588",
        "RouteFlags": 0
      },
      {
        "PointGuid": "AD9521074CFC1B74523C7C9F5B757D56",
        "RouteFlags": 0
      },
      {
        "PointGuid": "8D5CA3044572EB6D72DA62969ECF148A",
        "RouteFlags": 0
      },
      {
        "PointGuid": "297A784E42BE26B6A54CF7BA4A9337AA",
        "RouteFlags": 0
      },
      {
        "PointGuid": "ED02CFDA4A5C5F64EE2F1AAFB32DE445",
        "RouteFlags": 0
      },
      {
        "PointGuid": "3CD4C9504D6012A8A22855A12B614D56",
        "RouteFlags": 0
      },
      {
        "PointGuid": "4E01D6E3437128C2307993B5C9E8D0C9",
        "RouteFlags": 0
      },
      {
        "PointGuid": "3ECFE14343DC08C95BA7438CC1EB9E98",
        "RouteFlags": 0
      },
      {
        "PointGuid": "E305C6C94089253771F7618E21609129",
        "RouteFlags": 0
      },
      {
        "PointGuid": "120562D445446FCB0876EE849ACC0BB6",
        "RouteFlags": 0
      },
      {
        "PointGuid": "3CD9ED4E4EA24B4C186C698355B26E9F",
        "RouteFlags": 0
      },
      {
        "PointGuid": "F92731E8430BDA36BC67B09C53699837",
        "RouteFlags": 0
      },
      {
        "PointGuid": "BB2F43EB42BED3498AE922B0E2ED2672",
        "RouteFlags": 0
      },
      {
        "PointGuid": "3CA1BE0842E13DF75D7587963E8527B4",
        "RouteFlags": 0
      },
      {
        "PointGuid": "1F8E6487485365AE9715D78E4AACB763",
        "RouteFlags": 0
      },
      {
        "PointGuid": "0C5F351940E92CC7E96C8CA631C67AFD",
        "RouteFlags": 0
      }
    ],
    "RouteName": "West-1"
  }
]
```

</details>

#### GET `/companies/<guid>/routes/bus/<guid>`

Get a specific company bus route. Returns the same response data as above.

#### GET `/companies/<guid>/routes/truck`

<details>
<summary>Response data:</summary>

```json
[
  {
    "Guid": "3582948D48D1E704D7CBA68816EFF570",
    "DeliveryPoints": [
      {
        "PointGuid": "4B4BA00C48FF4EB4B612E5B27A7CDB32",
        "RouteFlags": 0
      },
      {
        "PointGuid": "0AAA0A5D48BA51047EF2768C222D0791",
        "RouteFlags": 0
      }
    ],
    "RouteName": "Haul 101"
  }
]
```

</details>

#### GET `/companies/<guid>/routes/truck/<guid>`

Get a specific company truck route. Returns the same response data as above.
