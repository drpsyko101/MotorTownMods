# Lua HTTP Server

## REST Endpoints

Query parameter and/or request body is not needed unless specified. A basic HTTP authentication header `Authorization: Basic <token>` is required for all request unless specified otherwise. The `token` can be either hashed with `bcrypt` or a simple `base64` encoding.

### Webserver control

#### POST `/stop`

Stop the webserver. Useful for restarting the Lua mods. Note that it will still try to complete any ongoing request before stopping. Future request will be rejected.

<details>
<summary>Response data:</summary>

Returns `200 OK` for successful stop command. Will output `Webserver stopped` in the log to confirm the full webserver shutdown.

</details>

### General server settings

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

### Player Management

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

### Event management

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

### Vehicle management

#### GET `/vehicles`

Get all currently available vehicles in game. This is a very resource intensive request if no filters applied. Use sparingly.

<details>
<summary>Query:</summary>

- `filters` (string|multi) - `DefaultVehicleFeatures,ExControls,BodyMaterials,BodyMaterialList,BodyMaterialName,BodyMaterialNames,DecalableMaterialSlotNames,BodyColorMaterialSlotNames,ColorSlots,BodyColors,BusComponentClass,RootBody,Mesh,SteeringWheel,Wheels,EngineComponent,CargoSpaceInteractableComponent,DrivingInput,HornAudioComponent,SirenAudioComponent,BackupBeepAudioComponent,RefuelAudioComponent,AirHydraulicAudioComponent,WindNoiseAudioComponent,AirHydraulicSound,DriverSeatInteractionSphereComponent,DriverSeatInteractableComponent,PassengerSeatInteractionSphereComponent,PassengerSeatInteractableComponent,NavModifierComponent,Dashboard,CameraSpringArm,TrailCamera,CockpitCamera,LOD1DisableTickComponents,LOD2DisableTickComponents,LOD2UnregisterComponents,LOD3UnregisterComponents,LOD4UnregisterComponents,TransmissionComponent,Differentials,Seats,MirrorComponents,Doors,CargoSpaces,TaxiComponent,Net_BusComponent,TruckComponent,WreckerComponent,TrailerComponent,Headlights,TailLights,ReverseLights,BlinkerLights,EmegencyLights,Constraints,ForkliftTiltConstraint,ForkliftLiftConstraints,ForkliftForkLeftConstraint,ForkliftForkRightConstraint,Winches,TowRequestComponent,TowingComponent,PartSlots,InteriorLights,TaxiRoofSign,RearSpoiler,RearWing,AeroParts,AttachmentParts,AttachmentPartsComponents,Net_RoofRackParts,Net_CargoBedParts,Server_Winches,TrailerHitch,PoliceComponent,SellerComponent,CraneComponent,GetawayComponent,DecalComponent,TankerFuelPumpComponent,GameplayTagContainer,StaticMeshDefaultTransforms,bForSale,bDrivable,bHasSteeringWheel,bHasDriverSeat,bHasPassengerSeat,AIDriverSetting,bIsOpenAir,DefaultDrivingMode,MaxSteeringAngleDegree,ParallelSteering,OptimalSlipAngleDegree,SteeringOffsetX,MaxSteeringWheelAngleDegree,BrakeTorqueMultiplier,BrakeTemperatureMass,KeyboardSteerSpeed,KeyboardSteerReturnSpeed,AntiRollBars,Suspensions,Pistons,FuelTankCapacityInLiter,AirDragCoeff,AeroLiftCoeff,AeroLiftCoeff_Front,AeroLiftCoeff_Rear,AirDragFrontalAreaMultiplier,DiffLockings,LiftAxles,ControlSettings,PhysicsSettings,bUseSteeringWheelSocketAsPivot,bSteeringAttachedToSkeletalSocket,LimitSteeringByLateralG,bLeanDriver,BaseLeanForwardDegree,HornSound,HornFadeInSeconds,HornFadeOutSeconds,SirenSounds,AirBrakeSound,ParkingBrakeSound,ParkingBrakeReleaseSound,BackupBeep,RefuelingSound,RefuelSoundFadeInSeconds,RefuelSoundFadeOutSeconds,RefuelingEndSound,RattleSound,RattleSoundG,WindNoiseSound,WindNoiseVolume,Throttle,Brake,Steer,HandBrake,Clutch,BikeDriverLeaning,Net_VehicleFlags,WheelAxles,LocalBoundsComponents,LocalBoundsComponentDefaultTransforms,VehicleReplicatedMovement,VehicleReplicatedMovements,NetLC_VehicleState,NetLC_ColdState,NetLC_EngineHotState,NetLC_EngineColdState,NetLC_TransmissionColdState,Net_Seats,Net_Cargo,Net_VehicleOwnerSetting,Net_VehicleSettings,Customization,Net_Decal,Net_OwnerPlayerState,Net_OwnerCharacterId,Net_OwnerCompanyGuid,Net_AccountNickname,Net_VehicleId,Server_OwnerPlayerController,Net_Parts,UtilitySlots,Net_AINetData,InternalWindowMaterials,LC_InteractionCandidates,Laptime,TrailerHitchSocketComponent,CurrentRoad,Net_Hooks,Net_Tractor,Net_MovementOwnerPC,Server_TempMovementOwnerPCs,Server_LastMovementOwnerPC,Net_LastNoMovementOwnerPCServerTimeSeconds,Net_LastMovementOwnerPCName,VehicleOwnerProfitShareMultiplier,ExplosionDetector,Server_GarbageCompress,Server_LastPlayerController,IgnoreCollisionComponents,Net_CarCarrierCargoSpace,Net_CompanyGuid,Net_CompanyName,OverlappingActors,AreaVolumes,WaterBodies,Net_PTOThrottle,Net_bPTOOn`
- `limit` (integer) - Limit the amount of result(s)

</details>

<details>
<summary>Response data:</summary>

```json
{
  "data": [
    {
      "Winches": {},
      "HandBrake": 1.0,
      "NetLC_VehicleState": {
        "OdoMeterKm": 0.0,
        "Fuel": 40.0,
        "LiftAxleProgresses": {},
        "Wheels": [
          {
            "BrakeTemperature": 0,
            "TireBrushTemperature": 0,
            "BrakeCoreTemperature": 0,
            "TireCoreTemperature": 0
          },
          {
            "BrakeTemperature": 0,
            "TireBrushTemperature": 0,
            "BrakeCoreTemperature": 0,
            "TireCoreTemperature": 0
          },
          {
            "BrakeTemperature": 0,
            "TireBrushTemperature": 0,
            "BrakeCoreTemperature": 0,
            "TireCoreTemperature": 0
          },
          {
            "BrakeTemperature": 0,
            "TireBrushTemperature": 0,
            "BrakeCoreTemperature": 0,
            "TireCoreTemperature": 0
          }
        ],
        "Condition": 1.0
      },
      "BrakeTorqueMultiplier": 1.0,
      "DefaultDrivingMode": 1,
      "HornFadeInSeconds": 0.10000000149012,
      "NetLC_EngineColdState": { "bDisabled": false, "bOverHeated": false },
      "Net_VehicleOwnerSetting": {
        "LevelRequirementsToDrive": [4, 0, 0, 0, 0, 0, 0],
        "DriveAllowedPlayers": 0,
        "bLocked": false,
        "VehicleOwnerProfitShare": 0.21999999880791
      },
      "NetLC_TransmissionColdState": { "CurrentGear": 0 },
      "WindNoiseVolume": 1.0,
      "bHasDriverSeat": true,
      "AeroLiftCoeff": { "X": 0.0, "Y": 0.0 },
      "bHasSteeringWheel": true,
      "KeyboardSteerReturnSpeed": 1.5,
      "Throttle": 0.0,
      "bSteeringAttachedToSkeletalSocket": false,
      "RefuelSoundFadeOutSeconds": 0.10000000149012,
      "bUseSteeringWheelSocketAsPivot": false,
      "RattleSoundG": 1.0,
      "LimitSteeringByLateralG": 0.0,
      "BodyColorMaterialSlotNames": { "Seat": "Seat", "Body": "Body" },
      "ExControls": [5, 1, 15, 2, 9, 10, 16, 7, 8],
      "Net_LastNoMovementOwnerPCServerTimeSeconds": 0.0,
      "bIsOpenAir": false,
      "Suspensions": {},
      "NetLC_ColdState": {
        "DriveMode": 1,
        "ToggleFunctions": [false, false, false, false],
        "bHorn": false,
        "bAcceptTaxiPassenger": false,
        "bIsAIDriving": false,
        "LiftedAxleIndices": {},
        "DiffLockIndex": 0,
        "RemovedWheels": {},
        "SirenIndex": -1,
        "LastLocationsInRoad": {},
        "HeadLightMode": 0,
        "bStoppedInParkingSpace": false,
        "TurnSignal": 0
      },
      "AttachmentParts": {},
      "LiftAxles": {},
      "AIDriverSetting": {
        "BrakingG": 0.20000000298023,
        "RaceLateralG": 0.69999998807907,
        "LateralG": 0.30000001192093,
        "RaceBrakingG": 0.69999998807907
      },
      "Net_VehicleSettings": [
        {
          "SettingType": 0,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 0.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 1,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 1.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 2,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 1.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 3,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 2.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 4,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 10.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 5,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 0.5,
            "ValueType": 0
          }
        },
        {
          "SettingType": 6,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 1.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 7,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 2.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 8,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 10.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 9,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 100.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 10,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 100.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 11,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 0.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 12,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 1.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 13,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 1.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 14,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 20.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 15,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 100.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 16,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 1.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 17,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 1.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 18,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 20.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 19,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 100.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 20,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 100.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 21,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 100.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 22,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 0.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 23,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 1.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 24,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 1.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 25,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 20.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 26,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 100.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 27,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 1.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 28,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 1.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 29,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 20.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 30,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 100.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 31,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 100.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 32,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 100.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 33,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 0.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 34,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": false,
            "Int64Value": 0,
            "FloatValue": 0.0,
            "ValueType": 2
          }
        },
        {
          "SettingType": 35,
          "Value": {
            "EnumValue": 1,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 0.0,
            "ValueType": 4
          }
        },
        {
          "SettingType": 36,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": false,
            "Int64Value": 0,
            "FloatValue": 0.0,
            "ValueType": 2
          }
        },
        {
          "SettingType": 37,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 0.0,
            "ValueType": 0
          }
        },
        {
          "SettingType": 38,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 0.0,
            "ValueType": 4
          }
        },
        {
          "SettingType": 39,
          "Value": {
            "EnumValue": 0,
            "StringValue": "",
            "BoolValue": true,
            "Int64Value": 0,
            "FloatValue": 1.0,
            "ValueType": 0
          }
        }
      ],
      "Clutch": 0.0,
      "Net_Hooks": {},
      "MaxSteeringAngleDegree": 40.0,
      "bForSale": false,
      "Net_CompanyGuid": "0000",
      "Steer": 0.0,
      "Net_RoofRackParts": {},
      "SteeringOffsetX": 0.0,
      "Net_bPTOOn": false,
      "TowRequestComponent": {},
      "DiffLockings": {},
      "AirDragFrontalAreaMultiplier": 0.89999997615814,
      "Net_CompanyName": "",
      "Net_CarCarrierCargoSpace": {},
      "AeroLiftCoeff_Front": 500.0,
      "VehicleOwnerProfitShareMultiplier": 1.0,
      "AntiRollBars": [
        {
          "Wheel1Name": "Wheel1",
          "Wheel0Name": "Wheel0",
          "SpringK": 1000.0,
          "SpringD": 10.0
        },
        {
          "Wheel1Name": "Wheel3",
          "Wheel0Name": "Wheel2",
          "SpringK": 200.0,
          "SpringD": 10.0
        }
      ],
      "OptimalSlipAngleDegree": 20.0,
      "BodyMaterialNames": ["Body_01", "Body"],
      "Net_AINetData": {
        "CrossroadId": -1,
        "CrossroadEnterTimeSeconds": 0.0,
        "CrossRoadNodeIndices": {},
        "LastCrossRoadId": -1
      },
      "KeyboardSteerSpeed": 1.5,
      "NetLC_EngineHotState": {
        "CoolantTemp": 0,
        "bStarterOn": false,
        "JakeBrake": 0,
        "CurrentRPM": 0.0,
        "bIgnitionOn": false,
        "RegenBrake": 1
      },
      "Net_OwnerCharacterId": { "UniqueNetId": "", "CharacterGuid": "0000" },
      "BaseLeanForwardDegree": 0.0,
      "MaxSteeringWheelAngleDegree": 450.0,
      "ParallelSteering": 0.80000001192093,
      "Server_TempMovementOwnerPCs": {},
      "Net_VehicleFlags": 0,
      "CurrentRoad": {},
      "Net_CargoBedParts": {},
      "BrakeTemperatureMass": -1.0,
      "Net_PTOThrottle": 0.20000000298023,
      "Net_Parts": [
        {
          "FloatValues": {},
          "ID": -1,
          "Key": "301",
          "Slot": 3,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": {},
          "ID": -2,
          "Key": "FD_6.5",
          "Slot": 4,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": {},
          "ID": -3,
          "Key": "SmallBlock_90HP",
          "Slot": 2,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": [1.0],
          "ID": -4,
          "Key": "SmallRadiator_100",
          "Slot": 6,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": {},
          "ID": -5,
          "Key": "BasicTire_65",
          "Slot": 19,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": {},
          "ID": -6,
          "Key": "BasicTire_65",
          "Slot": 20,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": {},
          "ID": -7,
          "Key": "BasicTire_65",
          "Slot": 21,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": {},
          "ID": -8,
          "Key": "BasicTire_65",
          "Slot": 22,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": {},
          "ID": -9,
          "Key": "Savanah",
          "Slot": 40,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": {},
          "ID": -10,
          "Key": "Savanah",
          "Slot": 41,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": {},
          "ID": -11,
          "Key": "Savanah",
          "Slot": 42,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": {},
          "ID": -12,
          "Key": "Savanah",
          "Slot": 43,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": {},
          "ID": -13,
          "Key": "DefaultBody",
          "Slot": 1,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": {},
          "ID": -14,
          "Key": "BrakePad_Small_01",
          "Slot": 70,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": {},
          "ID": -15,
          "Key": "BrakePad_Small_01",
          "Slot": 71,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": {},
          "ID": -16,
          "Key": "BrakePad_Small_01",
          "Slot": 72,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": {},
          "ID": -17,
          "Key": "BrakePad_Small_01",
          "Slot": 73,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": {},
          "ID": -18,
          "Key": "Savannah_FrontBumper_01",
          "Slot": 125,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": {},
          "ID": -19,
          "Key": "Savannah_RearBumper_01",
          "Slot": 126,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        },
        {
          "FloatValues": {},
          "ID": -20,
          "Key": "Savannah_Roof_01",
          "Slot": 124,
          "ItemInventory": { "Slots": {} },
          "Damage": 0.0,
          "VectorValues": {},
          "Int64Values": {},
          "StringValues": {}
        }
      ],
      "BodyMaterialName": "Body",
      "Net_VehicleId": -1,
      "Net_AccountNickname": "",
      "Net_Cargo": {
        "LoadedVolumes": 0,
        "NumCargo": 0,
        "CargoWeightKg": 0.0,
        "MaxVolumes": 0
      },
      "Net_OwnerCompanyGuid": "0000",
      "WheelAxles": [
        {
          "LocationX": 98.055839538574,
          "WheelIndices": [0, 1],
          "AxleIndex": -1
        },
        {
          "LocationX": -137.80386352539,
          "WheelIndices": [2, 3],
          "AxleIndex": -1
        }
      ],
      "RefuelSoundFadeInSeconds": 0.10000000149012,
      "HornFadeOutSeconds": 0.10000000149012,
      "Server_Winches": {},
      "Customization": {
        "BodyMaterialIndex": 3,
        "BodyColors": [
          {
            "Color": { "R": 226, "G": 196, "B": 54, "A": 0 },
            "MaterialSlotName": "Body_01"
          }
        ]
      },
      "Net_Seats": [
        { "bHasCharacter": false, "SeatName": "DriverSeat" },
        { "bHasCharacter": false, "SeatName": "PassengerSeat1" },
        { "bHasCharacter": false, "SeatName": "PassengerSeat2" },
        { "bHasCharacter": false, "SeatName": "PassengerSeat3" }
      ],
      "Brake": 0.0,
      "Net_LastMovementOwnerPCName": "",
      "BikeDriverLeaning": { "Pitch": 0.0, "Roll": 0.0, "Yaw": 0.0 },
      "BodyColors": [
        { "Colors": { "Body_01": { "R": 226, "G": 196, "B": 54, "A": 0 } } },
        { "Colors": { "Body_01": { "R": 234, "G": 226, "B": 199, "A": 0 } } },
        { "Colors": { "Body_01": { "R": 155, "G": 159, "B": 150, "A": 0 } } },
        { "Colors": { "Body_01": { "R": 226, "G": 123, "B": 53, "A": 0 } } }
      ],
      "bHasPassengerSeat": true,
      "AttachmentPartsComponents": {},
      "AirDragCoeff": 0.60000002384186,
      "PhysicsSettings": { "TCSMinWheelSpeed": { "X": 100.0, "Y": 200.0 } },
      "GameplayTagContainer": {},
      "DecalableMaterialSlotNames": ["Body_01", "Roof_01"],
      "ColorSlots": {
        "Roof_01": {
          "DefaultColor": { "R": 67, "G": 67, "B": 67, "A": 255 },
          "bUseColorAlpha": false,
          "DisplayName": "Roof1"
        },
        "Body_01": {
          "DefaultColor": { "R": 255, "G": 255, "B": 255, "A": 255 },
          "bUseColorAlpha": false,
          "DisplayName": "Body1"
        },
        "Window": {
          "DefaultColor": { "R": 101, "G": 158, "B": 150, "A": 63 },
          "bUseColorAlpha": true,
          "DisplayName": "Window1"
        },
        "Seat": {
          "DefaultColor": { "R": 115, "G": 115, "B": 115, "A": 255 },
          "bUseColorAlpha": false,
          "DisplayName": "Seat1"
        }
      },
      "Pistons": {},
      "FuelTankCapacityInLiter": 40.0,
      "Differentials": [
        {
          "LSDSlotIndex": 0,
          "LinkGearRatio": 1.0,
          "TransmissionComponentName": "Transmission",
          "Inertia": 100.0,
          "LSDSlotName": "",
          "bAllowLockableLSD": false,
          "DifferentialComponentName": ""
        }
      ],
      "TowingComponent": {},
      "PoliceComponent": {},
      "AeroLiftCoeff_Rear": 100.0,
      "ControlSettings": {
        "bRearSteering": false,
        "SteeringAssistMinSpeed": { "X": 0.0, "Y": 200.0 },
        "SteeringSpeedInComfort": 0.5
      },
      "Net_Decal": { "DecalLayers": {} },
      "bLeanDriver": false,
      "Laptime": { "CourseRoad": {}, "Courses": {} },
      "bDrivable": true
    }
  ]
}
```

</details>

#### GET `/vehicles/<guid>`

Get selected vehicle guid. This is currently only works for player owned vehicles as NPC vehicles are marked with -1 guid. Retuns the same response and using the same query as above.

#### POST `/vehicles/<guid>/despawn`

Despawn selected vehicle with the given guid. This is currently only works for player owned vehicles as NPC vehicles are marked with -1 guid. Returns a `204` for a successful request.

#### POST `/dealers/spawn`

Spawn a vehicle dealer spawn point at given location, along with optional vehicle parameter. The vehicle pricing is calculated based on the vehicle base value and equipped parts.

<details>
<summary>Request body:</summary>

```json
{
  "Location": { "X": 0.0, "Y": 0.0, "Z": 0.0 },
  "Rotation": { "Pitch": 0.0, "Roll": 0.0, "Yaw": 0.0 },
  "VehicleClass": "",
  "VehicleParam": {
    "VehicleKey": ""
  }
}
```

</details>

<details>
<summary>Response data:</summary>

```json
{
  "data": {
    "tag": ""
  }
}
```

</details>

### Properties management

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

### Cargo

#### GET `/delivery/points`

Returns all delivery points in-game. Note that this is a bandwith heavy operation if not supplied with any filters. Use sparingly.

<details>
<summary>Query:</summary>

- `filters` (string|multi) - `MaxDeliveryDistance,Supplies,DeliveryPointName,MaxPassiveDeliveries,MissionPointType,MaxDeliveryReceiveDistance,bUseAsDestinationInteraction,bConsumeContainer,Net_RuntimeFlags,bShowStorage,DemandConfigs,InputInventoryShareTarget,BasePayment,InputInventoryShare,Net_OutputInventory,DestinationCargoLimits,bIsSender,PassiveSupplies,Net_ProductionLocalFoodSupply,Net_ProductionBonusByPopulation,Net_ProductionBonusByProduction,ProductionConfigs,MaxStorage,Net_Deliveries,PaymentMultiplier,GameplayTags,bRemoveUnusedInputCargo,DestinationTypes,StorageConfigs,DestinationExcludeTypes,bIsReceiver,MissionPointName,Net_InputInventory,PointName,bLoadCargoBySpawnAtPoint,DemandPriority,MaxDeliveries,Demands`

</details>

<details>
<summary>Response data:</summary>

```json
{
  "data": [
    {
      "MaxDeliveryDistance": 0.0,
      "Supplies": {},
      "DeliveryPointName": { "Name": "1100 Rest Area", "Number": 0 },
      "MaxPassiveDeliveries": 5,
      "MissionPointType": 2,
      "MaxDeliveryReceiveDistance": 0.0,
      "bUseAsDestinationInteraction": false,
      "bConsumeContainer": false,
      "Net_RuntimeFlags": 3,
      "bShowStorage": true,
      "DemandConfigs": [
        {
          "MaxStorage": 10,
          "CargoKey": "MilitarySupplyBox_01_Empty",
          "PaymentMultiplier": 1.0,
          "CargoGameplayTagQuery": {
            "UserDescription": "",
            "AutoDescription": "",
            "TokenStreamVersion": 0,
            "TagDictionary": {},
            "QueryTokenStream": {}
          },
          "CargoType": 0
        }
      ],
      "InputInventoryShareTarget": {},
      "BasePayment": 0,
      "InputInventoryShare": {},
      "Net_OutputInventory": { "Entries": {} },
      "DestinationCargoLimits": [
        {
          "DeliveryPointTagQuery": {
            "UserDescription": "",
            "AutoDescription": " ALL( DeliveryPoint.Warehouse )",
            "TokenStreamVersion": 0,
            "TagDictionary": ["DeliveryPoint.Warehouse"],
            "QueryTokenStream": [0, 1, 2, 1, 0]
          },
          "CargoTagQuery": {
            "UserDescription": "",
            "AutoDescription": " ANY( Cargo.FoodIngredients )",
            "TokenStreamVersion": 0,
            "TagDictionary": ["Cargo.FoodIngredients"],
            "QueryTokenStream": [0, 1, 1, 1, 0]
          },
          "LimitCount": 0
        },
        {
          "DeliveryPointTagQuery": {
            "UserDescription": "",
            "AutoDescription": " ALL( DeliveryPoint.Warehouse )",
            "TokenStreamVersion": 0,
            "TagDictionary": ["DeliveryPoint.Warehouse"],
            "QueryTokenStream": [0, 1, 2, 1, 0]
          },
          "CargoTagQuery": {
            "UserDescription": "",
            "AutoDescription": " ANY( Cargo.WarehouseStore )",
            "TokenStreamVersion": 0,
            "TagDictionary": ["Cargo.WarehouseStore"],
            "QueryTokenStream": [0, 1, 1, 1, 0]
          },
          "LimitCount": 0
        }
      ],
      "bIsSender": true,
      "DeliveryPointGuid": "47152D314AE8ABEF9DB76CA1E3B3C649",
      "PassiveSupplies": [
        {
          "MaxNumCargoPerDelivery": 6,
          "CargoKey": "None",
          "Priority": 4,
          "MinNumCargoPerDelivery": 1,
          "CargoType": 3,
          "MaxDeliveries": 5
        },
        {
          "MaxNumCargoPerDelivery": 5,
          "CargoKey": "None",
          "Priority": 4,
          "MinNumCargoPerDelivery": 1,
          "CargoType": 2,
          "MaxDeliveries": 5
        }
      ],
      "Net_ProductionLocalFoodSupply": 0.0,
      "Net_ProductionBonusByPopulation": 0.0,
      "Net_ProductionBonusByProduction": 0.0,
      "ProductionConfigs": [
        {
          "OutputCargos": {},
          "ProductionTimeSeconds": 60.0,
          "InputCargoTypes": { "9": 1 },
          "ProductionFlags": 3,
          "TimeSinceLastProduction": 0.0,
          "bHidden": false,
          "OutputCargoTypes": { "3": 4 },
          "InputCargos": {},
          "LocalFoodSupply": 0.0,
          "ProductionSpeedMultiplier": 1.0,
          "OutputCargoRowGameplayTagQuery": {
            "UserDescription": "",
            "AutoDescription": " ALL( Cargo.GeneralPallet )",
            "TokenStreamVersion": 0,
            "TagDictionary": ["Cargo.GeneralPallet"],
            "QueryTokenStream": [0, 1, 2, 1, 0]
          },
          "InputCargoGameplayTagQuery": {
            "UserDescription": "",
            "AutoDescription": "",
            "TokenStreamVersion": 0,
            "TagDictionary": {},
            "QueryTokenStream": {}
          },
          "bStoreInputCargo": false
        },
        {
          "OutputCargos": {},
          "ProductionTimeSeconds": 10.0,
          "InputCargoTypes": { "3": 1 },
          "ProductionFlags": 3,
          "TimeSinceLastProduction": 0.0,
          "bHidden": true,
          "OutputCargoTypes": {},
          "InputCargos": {},
          "LocalFoodSupply": 0.0,
          "ProductionSpeedMultiplier": 1.0,
          "OutputCargoRowGameplayTagQuery": {
            "UserDescription": "",
            "AutoDescription": "",
            "TokenStreamVersion": 0,
            "TagDictionary": {},
            "QueryTokenStream": {}
          },
          "InputCargoGameplayTagQuery": {
            "UserDescription": "",
            "AutoDescription": "",
            "TokenStreamVersion": 0,
            "TagDictionary": {},
            "QueryTokenStream": {}
          },
          "bStoreInputCargo": true
        },
        {
          "OutputCargos": {},
          "ProductionTimeSeconds": 10.0,
          "InputCargoTypes": { "4": 1 },
          "ProductionFlags": 3,
          "TimeSinceLastProduction": 0.0,
          "bHidden": true,
          "OutputCargoTypes": {},
          "InputCargos": {},
          "LocalFoodSupply": 0.0,
          "ProductionSpeedMultiplier": 1.0,
          "OutputCargoRowGameplayTagQuery": {
            "UserDescription": "",
            "AutoDescription": "",
            "TokenStreamVersion": 0,
            "TagDictionary": {},
            "QueryTokenStream": {}
          },
          "InputCargoGameplayTagQuery": {
            "UserDescription": "",
            "AutoDescription": " ALL( Cargo.WarehouseStore )",
            "TokenStreamVersion": 0,
            "TagDictionary": ["Cargo.WarehouseStore"],
            "QueryTokenStream": [0, 1, 2, 1, 0]
          },
          "bStoreInputCargo": true
        },
        {
          "OutputCargos": { "MilitarySupplyBox_01": 1 },
          "ProductionTimeSeconds": 10.0,
          "InputCargoTypes": {},
          "ProductionFlags": 3,
          "TimeSinceLastProduction": 0.0,
          "bHidden": false,
          "OutputCargoTypes": {},
          "InputCargos": { "MilitarySupplyBox_01_Empty": 1 },
          "LocalFoodSupply": 0.0,
          "ProductionSpeedMultiplier": 1.0,
          "OutputCargoRowGameplayTagQuery": {
            "UserDescription": "",
            "AutoDescription": "",
            "TokenStreamVersion": 0,
            "TagDictionary": {},
            "QueryTokenStream": {}
          },
          "InputCargoGameplayTagQuery": {
            "UserDescription": "",
            "AutoDescription": "",
            "TokenStreamVersion": 0,
            "TagDictionary": {},
            "QueryTokenStream": {}
          },
          "bStoreInputCargo": false
        }
      ],
      "MaxStorage": 50,
      "Net_Deliveries": [
        {
          "PathDistance": 572316.0625,
          "DeliveryFlags": 0,
          "PaymentMultiplierBySupply": 0.0,
          "ReceiverPoint": "FD77C5AF49B45F4260DB538B7A086276",
          "CargoKey": "BoxPallete_03",
          "ColorIndex": -1,
          "PathClimbHeight": 3766.0307617188,
          "ID": 57,
          "PaymentMultiplierByDemand": 0.0,
          "Weight": 669.77142333984,
          "PaymentMultiplierByBalanceConfig": 2.5999999046326,
          "TimerSeconds": -1.0,
          "NumCargos": 4,
          "RegisteredTimeSeconds": 0.0,
          "SenderPoint": "47152D314AE8ABEF9DB76CA1E3B3C649",
          "PathSpeedKPH": 60.295635223389,
          "ExpiresAtTimeSeconds": 322.47912597656,
          "CargoType": 3
        },
        {
          "PathDistance": 488957.71875,
          "DeliveryFlags": 0,
          "PaymentMultiplierBySupply": 0.0,
          "ReceiverPoint": "6AC429CF4D459399AB8530B8AA1C1FB5",
          "CargoKey": "CarrotBox",
          "ColorIndex": -1,
          "PathClimbHeight": 3232.38671875,
          "ID": 72,
          "PaymentMultiplierByDemand": 0.0,
          "Weight": 0.0,
          "PaymentMultiplierByBalanceConfig": 3.5999999046326,
          "TimerSeconds": -1.0,
          "NumCargos": 1,
          "RegisteredTimeSeconds": 0.0,
          "SenderPoint": "47152D314AE8ABEF9DB76CA1E3B3C649",
          "PathSpeedKPH": 50.534671783447,
          "ExpiresAtTimeSeconds": 138.92004394531,
          "CargoType": 2
        },
        {
          "PathDistance": 2596794.25,
          "DeliveryFlags": 0,
          "PaymentMultiplierBySupply": 0.0,
          "ReceiverPoint": "8824998640317D45AE6BEBADAA056CB6",
          "CargoKey": "Rice",
          "ColorIndex": -1,
          "PathClimbHeight": 34777.5546875,
          "ID": 194,
          "PaymentMultiplierByDemand": 0.0,
          "Weight": 0.0,
          "PaymentMultiplierByBalanceConfig": 3.5999999046326,
          "TimerSeconds": -1.0,
          "NumCargos": 2,
          "RegisteredTimeSeconds": 0.0,
          "SenderPoint": "47152D314AE8ABEF9DB76CA1E3B3C649",
          "PathSpeedKPH": 86.923835754395,
          "ExpiresAtTimeSeconds": 264.70550537109,
          "CargoType": 2
        },
        {
          "PathDistance": 2689873.25,
          "DeliveryFlags": 0,
          "PaymentMultiplierBySupply": 0.0,
          "ReceiverPoint": "AFF6017D41E6DA856BCFD3879D90BA06",
          "CargoKey": "OrangeBox",
          "ColorIndex": -1,
          "PathClimbHeight": 34819.66015625,
          "ID": 196,
          "PaymentMultiplierByDemand": 0.0,
          "Weight": 0.0,
          "PaymentMultiplierByBalanceConfig": 3.5999999046326,
          "TimerSeconds": -1.0,
          "NumCargos": 2,
          "RegisteredTimeSeconds": 0.0,
          "SenderPoint": "47152D314AE8ABEF9DB76CA1E3B3C649",
          "PathSpeedKPH": 85.707252502441,
          "ExpiresAtTimeSeconds": 156.92727661133,
          "CargoType": 2
        },
        {
          "PathDistance": 410317.65625,
          "DeliveryFlags": 0,
          "PaymentMultiplierBySupply": 0.0,
          "ReceiverPoint": "26F9073F4F6D6A6FDCD3BD97897A3B6F",
          "CargoKey": "CornBox",
          "ColorIndex": -1,
          "PathClimbHeight": 2147.5737304688,
          "ID": 441,
          "PaymentMultiplierByDemand": 0.0,
          "Weight": 0.0,
          "PaymentMultiplierByBalanceConfig": 3.5999999046326,
          "TimerSeconds": -1.0,
          "NumCargos": 4,
          "RegisteredTimeSeconds": 0.0,
          "SenderPoint": "47152D314AE8ABEF9DB76CA1E3B3C649",
          "PathSpeedKPH": 61.20641708374,
          "ExpiresAtTimeSeconds": 75.503082275391,
          "CargoType": 2
        }
      ],
      "PaymentMultiplier": 1.2000000476837,
      "GameplayTags": ["DeliveryPoint.Warehouse"],
      "bRemoveUnusedInputCargo": true,
      "DestinationTypes": {},
      "StorageConfigs": [
        { "MaxStorage": 10, "CargoKey": "None", "CargoType": 9 }
      ],
      "DestinationExcludeTypes": {},
      "bIsReceiver": true,
      "MissionPointName": "1100 Rest Area",
      "Net_InputInventory": { "Entries": {} },
      "PointName": { "Texts": ["1100 Rest Area"] },
      "bLoadCargoBySpawnAtPoint": false,
      "DemandPriority": 1,
      "MaxDeliveries": 40,
      "Demands": {}
    }
  ]
}
```

</details>

#### GET `/delivery/points/<guid>`

Returns a delivery point given the guid in-game. Uses the same queries as above.

<details>
<summary>Response data:</summary>

```json
{
  "data": {
    "MaxDeliveryDistance": 0.0,
    "Supplies": {},
    "DeliveryPointName": { "Name": "1100 Rest Area", "Number": 0 },
    "MaxPassiveDeliveries": 5,
    "MissionPointType": 2,
    "MaxDeliveryReceiveDistance": 0.0,
    "bUseAsDestinationInteraction": false,
    "bConsumeContainer": false,
    "Net_RuntimeFlags": 3,
    "bShowStorage": true,
    "DemandConfigs": [
      {
        "MaxStorage": 10,
        "CargoKey": "MilitarySupplyBox_01_Empty",
        "PaymentMultiplier": 1.0,
        "CargoGameplayTagQuery": {
          "UserDescription": "",
          "AutoDescription": "",
          "TokenStreamVersion": 0,
          "TagDictionary": {},
          "QueryTokenStream": {}
        },
        "CargoType": 0
      }
    ],
    "InputInventoryShareTarget": {},
    "BasePayment": 0,
    "InputInventoryShare": {},
    "Net_OutputInventory": { "Entries": {} },
    "DestinationCargoLimits": [
      {
        "DeliveryPointTagQuery": {
          "UserDescription": "",
          "AutoDescription": " ALL( DeliveryPoint.Warehouse )",
          "TokenStreamVersion": 0,
          "TagDictionary": ["DeliveryPoint.Warehouse"],
          "QueryTokenStream": [0, 1, 2, 1, 0]
        },
        "CargoTagQuery": {
          "UserDescription": "",
          "AutoDescription": " ANY( Cargo.FoodIngredients )",
          "TokenStreamVersion": 0,
          "TagDictionary": ["Cargo.FoodIngredients"],
          "QueryTokenStream": [0, 1, 1, 1, 0]
        },
        "LimitCount": 0
      },
      {
        "DeliveryPointTagQuery": {
          "UserDescription": "",
          "AutoDescription": " ALL( DeliveryPoint.Warehouse )",
          "TokenStreamVersion": 0,
          "TagDictionary": ["DeliveryPoint.Warehouse"],
          "QueryTokenStream": [0, 1, 2, 1, 0]
        },
        "CargoTagQuery": {
          "UserDescription": "",
          "AutoDescription": " ANY( Cargo.WarehouseStore )",
          "TokenStreamVersion": 0,
          "TagDictionary": ["Cargo.WarehouseStore"],
          "QueryTokenStream": [0, 1, 1, 1, 0]
        },
        "LimitCount": 0
      }
    ],
    "bIsSender": true,
    "DeliveryPointGuid": "47152D314AE8ABEF9DB76CA1E3B3C649",
    "PassiveSupplies": [
      {
        "MaxNumCargoPerDelivery": 6,
        "CargoKey": "None",
        "Priority": 4,
        "MinNumCargoPerDelivery": 1,
        "CargoType": 3,
        "MaxDeliveries": 5
      },
      {
        "MaxNumCargoPerDelivery": 5,
        "CargoKey": "None",
        "Priority": 4,
        "MinNumCargoPerDelivery": 1,
        "CargoType": 2,
        "MaxDeliveries": 5
      }
    ],
    "Net_ProductionLocalFoodSupply": 0.0,
    "Net_ProductionBonusByPopulation": 0.0,
    "Net_ProductionBonusByProduction": 0.0,
    "ProductionConfigs": [
      {
        "OutputCargos": {},
        "ProductionTimeSeconds": 60.0,
        "InputCargoTypes": { "9": 1 },
        "ProductionFlags": 3,
        "TimeSinceLastProduction": 0.0,
        "bHidden": false,
        "OutputCargoTypes": { "3": 4 },
        "InputCargos": {},
        "LocalFoodSupply": 0.0,
        "ProductionSpeedMultiplier": 1.0,
        "OutputCargoRowGameplayTagQuery": {
          "UserDescription": "",
          "AutoDescription": " ALL( Cargo.GeneralPallet )",
          "TokenStreamVersion": 0,
          "TagDictionary": ["Cargo.GeneralPallet"],
          "QueryTokenStream": [0, 1, 2, 1, 0]
        },
        "InputCargoGameplayTagQuery": {
          "UserDescription": "",
          "AutoDescription": "",
          "TokenStreamVersion": 0,
          "TagDictionary": {},
          "QueryTokenStream": {}
        },
        "bStoreInputCargo": false
      },
      {
        "OutputCargos": {},
        "ProductionTimeSeconds": 10.0,
        "InputCargoTypes": { "3": 1 },
        "ProductionFlags": 3,
        "TimeSinceLastProduction": 0.0,
        "bHidden": true,
        "OutputCargoTypes": {},
        "InputCargos": {},
        "LocalFoodSupply": 0.0,
        "ProductionSpeedMultiplier": 1.0,
        "OutputCargoRowGameplayTagQuery": {
          "UserDescription": "",
          "AutoDescription": "",
          "TokenStreamVersion": 0,
          "TagDictionary": {},
          "QueryTokenStream": {}
        },
        "InputCargoGameplayTagQuery": {
          "UserDescription": "",
          "AutoDescription": "",
          "TokenStreamVersion": 0,
          "TagDictionary": {},
          "QueryTokenStream": {}
        },
        "bStoreInputCargo": true
      },
      {
        "OutputCargos": {},
        "ProductionTimeSeconds": 10.0,
        "InputCargoTypes": { "4": 1 },
        "ProductionFlags": 3,
        "TimeSinceLastProduction": 0.0,
        "bHidden": true,
        "OutputCargoTypes": {},
        "InputCargos": {},
        "LocalFoodSupply": 0.0,
        "ProductionSpeedMultiplier": 1.0,
        "OutputCargoRowGameplayTagQuery": {
          "UserDescription": "",
          "AutoDescription": "",
          "TokenStreamVersion": 0,
          "TagDictionary": {},
          "QueryTokenStream": {}
        },
        "InputCargoGameplayTagQuery": {
          "UserDescription": "",
          "AutoDescription": " ALL( Cargo.WarehouseStore )",
          "TokenStreamVersion": 0,
          "TagDictionary": ["Cargo.WarehouseStore"],
          "QueryTokenStream": [0, 1, 2, 1, 0]
        },
        "bStoreInputCargo": true
      },
      {
        "OutputCargos": { "MilitarySupplyBox_01": 1 },
        "ProductionTimeSeconds": 10.0,
        "InputCargoTypes": {},
        "ProductionFlags": 3,
        "TimeSinceLastProduction": 0.0,
        "bHidden": false,
        "OutputCargoTypes": {},
        "InputCargos": { "MilitarySupplyBox_01_Empty": 1 },
        "LocalFoodSupply": 0.0,
        "ProductionSpeedMultiplier": 1.0,
        "OutputCargoRowGameplayTagQuery": {
          "UserDescription": "",
          "AutoDescription": "",
          "TokenStreamVersion": 0,
          "TagDictionary": {},
          "QueryTokenStream": {}
        },
        "InputCargoGameplayTagQuery": {
          "UserDescription": "",
          "AutoDescription": "",
          "TokenStreamVersion": 0,
          "TagDictionary": {},
          "QueryTokenStream": {}
        },
        "bStoreInputCargo": false
      }
    ],
    "MaxStorage": 50,
    "Net_Deliveries": [
      {
        "PathDistance": 572316.0625,
        "DeliveryFlags": 0,
        "PaymentMultiplierBySupply": 0.0,
        "ReceiverPoint": "FD77C5AF49B45F4260DB538B7A086276",
        "CargoKey": "BoxPallete_03",
        "ColorIndex": -1,
        "PathClimbHeight": 3766.0307617188,
        "ID": 57,
        "PaymentMultiplierByDemand": 0.0,
        "Weight": 669.77142333984,
        "PaymentMultiplierByBalanceConfig": 2.5999999046326,
        "TimerSeconds": -1.0,
        "NumCargos": 4,
        "RegisteredTimeSeconds": 0.0,
        "SenderPoint": "47152D314AE8ABEF9DB76CA1E3B3C649",
        "PathSpeedKPH": 60.295635223389,
        "ExpiresAtTimeSeconds": 322.47912597656,
        "CargoType": 3
      },
      {
        "PathDistance": 488957.71875,
        "DeliveryFlags": 0,
        "PaymentMultiplierBySupply": 0.0,
        "ReceiverPoint": "6AC429CF4D459399AB8530B8AA1C1FB5",
        "CargoKey": "CarrotBox",
        "ColorIndex": -1,
        "PathClimbHeight": 3232.38671875,
        "ID": 72,
        "PaymentMultiplierByDemand": 0.0,
        "Weight": 0.0,
        "PaymentMultiplierByBalanceConfig": 3.5999999046326,
        "TimerSeconds": -1.0,
        "NumCargos": 1,
        "RegisteredTimeSeconds": 0.0,
        "SenderPoint": "47152D314AE8ABEF9DB76CA1E3B3C649",
        "PathSpeedKPH": 50.534671783447,
        "ExpiresAtTimeSeconds": 138.92004394531,
        "CargoType": 2
      },
      {
        "PathDistance": 2596794.25,
        "DeliveryFlags": 0,
        "PaymentMultiplierBySupply": 0.0,
        "ReceiverPoint": "8824998640317D45AE6BEBADAA056CB6",
        "CargoKey": "Rice",
        "ColorIndex": -1,
        "PathClimbHeight": 34777.5546875,
        "ID": 194,
        "PaymentMultiplierByDemand": 0.0,
        "Weight": 0.0,
        "PaymentMultiplierByBalanceConfig": 3.5999999046326,
        "TimerSeconds": -1.0,
        "NumCargos": 2,
        "RegisteredTimeSeconds": 0.0,
        "SenderPoint": "47152D314AE8ABEF9DB76CA1E3B3C649",
        "PathSpeedKPH": 86.923835754395,
        "ExpiresAtTimeSeconds": 264.70550537109,
        "CargoType": 2
      },
      {
        "PathDistance": 2689873.25,
        "DeliveryFlags": 0,
        "PaymentMultiplierBySupply": 0.0,
        "ReceiverPoint": "AFF6017D41E6DA856BCFD3879D90BA06",
        "CargoKey": "OrangeBox",
        "ColorIndex": -1,
        "PathClimbHeight": 34819.66015625,
        "ID": 196,
        "PaymentMultiplierByDemand": 0.0,
        "Weight": 0.0,
        "PaymentMultiplierByBalanceConfig": 3.5999999046326,
        "TimerSeconds": -1.0,
        "NumCargos": 2,
        "RegisteredTimeSeconds": 0.0,
        "SenderPoint": "47152D314AE8ABEF9DB76CA1E3B3C649",
        "PathSpeedKPH": 85.707252502441,
        "ExpiresAtTimeSeconds": 156.92727661133,
        "CargoType": 2
      },
      {
        "PathDistance": 410317.65625,
        "DeliveryFlags": 0,
        "PaymentMultiplierBySupply": 0.0,
        "ReceiverPoint": "26F9073F4F6D6A6FDCD3BD97897A3B6F",
        "CargoKey": "CornBox",
        "ColorIndex": -1,
        "PathClimbHeight": 2147.5737304688,
        "ID": 441,
        "PaymentMultiplierByDemand": 0.0,
        "Weight": 0.0,
        "PaymentMultiplierByBalanceConfig": 3.5999999046326,
        "TimerSeconds": -1.0,
        "NumCargos": 4,
        "RegisteredTimeSeconds": 0.0,
        "SenderPoint": "47152D314AE8ABEF9DB76CA1E3B3C649",
        "PathSpeedKPH": 61.20641708374,
        "ExpiresAtTimeSeconds": 75.503082275391,
        "CargoType": 2
      }
    ],
    "PaymentMultiplier": 1.2000000476837,
    "GameplayTags": ["DeliveryPoint.Warehouse"],
    "bRemoveUnusedInputCargo": true,
    "DestinationTypes": {},
    "StorageConfigs": [
      { "MaxStorage": 10, "CargoKey": "None", "CargoType": 9 }
    ],
    "DestinationExcludeTypes": {},
    "bIsReceiver": true,
    "MissionPointName": "1100 Rest Area",
    "Net_InputInventory": { "Entries": {} },
    "PointName": { "Texts": ["1100 Rest Area"] },
    "bLoadCargoBySpawnAtPoint": false,
    "DemandPriority": 1,
    "MaxDeliveries": 40,
    "Demands": {}
  }
}
```

</details>

### Assets

#### POST `/assets/spawn`

Spawn a given asset path at specified location and rotation. Rotation field is optional. If no tags are provided, a new one will be generated for each asset.

<details>
<summary>Request body:</summary>

Spawning a single actor:

```json
{
  "AssetPath": "/Path/To/Asset.Asset",
  "Location": {
    "X": 0.0,
    "Y": 0.0,
    "Z": 0.0
  },
  "Rotation": {
    "Pitch": 0.0,
    "Roll": 0.0,
    "Yaw": 0.0
  },
  "Tag": "SomeIdentifiableTag"
}
```

Spawning multiple actors:

```json
[
  {
    "AssetPath": "/Path/To/Asset.Asset",
    "Location": {
      "X": 0.0,
      "Y": 0.0,
      "Z": 0.0
    },
    "Rotation": {
      "Pitch": 0.0,
      "Roll": 0.0,
      "Yaw": 0.0
    },
    "Tag": "SomeIdentifiableTag"
  }
]
```

</details>

<details>
<summary>Response data:</summary>

```json
{
  "Data": ["AssetTagHere"]
}
```

</details>

#### POST `/assets/despawn`

Despawn actor(s) based on the given tag(s).

<details>
<summary>Request body:</summary>

Despawn using a single tag:

```json
{
  "Tag": "AssetTagToDelete"
}
```

Despawn using multiple tags:

```json
{
  "Tags": ["Tag1", "Tag2"]
}
```

</details>

## Webhooks

### Events

#### Event creation

Returns the new event data.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerAddEvent",
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
  "hook": "",
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

### Cargo

#### Cargo accept delivery

Called when a player accepted a cargo delivery.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerAcceptDelivery",
  "data": { "DeliveryId": 27, "Sender": "EA50F9CE42B8A468F4FBFE8C42AD87ED" }
}
```

</details>
