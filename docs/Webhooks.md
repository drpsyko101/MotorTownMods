# Event Webhooks

Requires `socket` module installed and `MOD_WEBHOOK_URL` environment variable set to function properly. Most of the event hook payloads have similarities with the REST API endpoints return data. Webhook can be enabled individually using `MOD_WEBHOOK_ENABLE_EVENTS` environment variable according to the code block in their headings respectively. All event hooks are enabled by default. To enable multiple events, concatenate them with `,` like `ServerJoinEvent,ServerLeaveEvent`. To disable the webhooks entirely, set it to `none`.

### Events

#### Event creation - `ServerAddEvent`

Returns the new event data.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerAddEvent",
  "timestamp": 1752044853012,
  "data": {
    "PlayerId": "",
    "Event": {
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
        "UniqueNetId": "76561198041602276"
      },
      "Players": [],
      "EventGuid": "6E6705764C17B7F764098091A10567E7",
      "EventName": "EnhancedBrow's Event"
    }
  }
}
```

</details>

#### Event state changed - `ServerChangeEventState`

Returns the GUID of the event and the new event state.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerChangeEventState",
  "timestamp": 1752044853012,
  "data": {
    // similar event structure as above
  }
}
```

</details>

#### Event removal - `ServerRemoveEvent`

Returns the GUID of the removed event.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerRemoveEvent",
  "timestamp": 1752044853012,
  "data": {
    "PlayerId": "",
    "EventGuid": "835BB8FD4104E369D33C6BA74C41922A"
  }
}
```

</details>

#### Event checkpoint update - `ServerPassedRaceSection`

Called when a player passed an event checkpoint.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerPassedRaceSection",
  "timestamp": 1752044853012,
  "data": {
    "PlayerId": "",
    "EventGuid": "",
    "SectionIndex": -1,
    "TotalTimeSeconds": 0,
    "LaptimeSeconds": 0
  }
}
```

</details>

#### Player joined an event - `ServerJoinEvent`

Called when a player joined an event.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerJoinEvent",
  "timestamp": 1752044853012,
  "data": {
    "PlayerId": "",
    "EventGuid": ""
  }
}
```

</details>

#### Player left an event - `ServerLeaveEvent`

Called when a player left an event.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerLeaveEvent",
  "timestamp": 1752044853012,
  "data": {
    "PlayerId": "",
    "EventGuid": ""
  }
}
```

</details>

### Cargo

#### Cargo accept delivery - `ServerAcceptDelivery`

Called when a player accepted a cargo delivery.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerAcceptDelivery",
  "timestamp": 1752044853012,
  "data": { "DeliveryId": 27, "PlayerId": "" }
}
```

</details>

### Chat

#### Player chat sent - `ServerSendChat`

Called when a player send a chat.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerSendChat",
  "timestamp": 1752044853012,
  "data": {
    "Sender": "",
    "Message": "",
    "Category": 0 // Normal = 0, Announce = 1, Company = 2, Event = 3, WhisperIn = 4, WhisperOut = 5
  }
}
```

</details>

### Vehicles

#### Player entered a vehicle - `ServerEnterVehicle`

Called when a player has entered a vehicle.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerEnterVehicle",
  "timestamp": 1755002188779,
  "data": {
    "PlayerId": "76561198041602276",
    "SeatIndex": -1,
    "Stolen": false,
    "Vehicle": {
      "Wheels": [{}, {}, {}, {}],
      "ReverseLights": [{}, {}],
      "ForkliftLiftConstraints": {},
      "SteeringOffsetX": 0,
      "PartSlots": [{}],
      "GameplayTagContainer": {
        "GameplayTags": {},
        "ParentTags": {}
      },
      "InternalWindowMaterials": [{}],
      "bSteeringAttachedToSkeletalSocket": false,
      "Net_PTOThrottle": 0.20000000298023,
      "Doors": [{}, {}, {}],
      "FuelTankCapacityInLiter": 40,
      "Net_AINetData": {
        "CrossRoadNodeIndices": {},
        "CrossroadId": -1,
        "LastCrossRoadId": -1,
        "CrossroadEnterTimeSeconds": 0
      },
      "bIsOpenAir": false,
      "Server_TempMovementOwnerPCs": {},
      "Clutch": 0,
      "HornFadeInSeconds": 0.10000000149012,
      "LOD2DisableTickComponents": {},
      "BodyMaterialList": {},
      "Net_LastMovementOwnerPCName": "EnhancedBrow",
      "bForSale": false,
      "DefaultVehicleFeatures": {},
      "bHasPassengerSeat": true,
      "NetLC_EngineHotState": {
        "bStarterOn": true,
        "CurrentRPM": 399.41635131836,
        "JakeBrake": 0,
        "bIgnitionOn": true,
        "CoolantTemp": 20,
        "RegenBrake": 1
      },
      "Brake": 0,
      "WindNoiseVolume": 1,
      "Headlights": [{}, {}],
      "BodyColorMaterialSlotNames": {
        "Body_01": "Body",
        "Seat": "Seat",
        "CargoBed": "Cargo Bed1"
      },
      "KeyboardSteerReturnSpeed": 2,
      "NetLC_ColdState": {
        "LiftedAxleIndices": {},
        "LastLocationsInRoad": [
          {
            "Location": {
              "Z": -20744.714646221,
              "Y": 104592.98389413,
              "X": 108746.63299232
            },
            "Rotation": {
              "Pitch": 0.94099197634388,
              "Roll": 0.18433111798306,
              "Yaw": 2.724530707643
            }
          },
          {
            "Location": {
              "Z": -20783.817491967,
              "Y": 104834.44522166,
              "X": 110751.73334066
            },
            "Rotation": {
              "Pitch": -2.4957322109099,
              "Roll": -0.12485165077526,
              "Yaw": 10.473000046482
            }
          },
          {
            "Location": {
              "Z": -20915.239254707,
              "Y": 106363.04409112,
              "X": 111597.03357724
            },
            "Rotation": {
              "Pitch": -4.2596287851951,
              "Roll": -0.72187437759192,
              "Yaw": 95.186495239831
            }
          },
          {
            "Location": {
              "Z": -21076.879362043,
              "Y": 108369.6373067,
              "X": 111939.57442941
            },
            "Rotation": {
              "Pitch": -2.0426833952779,
              "Roll": 0.15831654929516,
              "Yaw": 69.903718789866
            }
          },
          {
            "Location": {
              "Z": -21089.209762926,
              "Y": 109633.7428202,
              "X": 113722.40028972
            },
            "Rotation": {
              "Pitch": 0,
              "Roll": -0.22638683486134,
              "Yaw": 4.6653746184345
            }
          }
        ],
        "bStoppedInParkingSpace": false,
        "bIsAIDriving": false,
        "DiffLockIndex": 0,
        "TurnSignal": 0,
        "DriveMode": 1,
        "SirenIndex": -1,
        "ToggleFunctions": [false, false, false, false],
        "HeadLightMode": 2,
        "bHorn": false,
        "RemovedWheels": {},
        "bAcceptTaxiPassenger": false
      },
      "WheelAxles": [
        {
          "LocationX": 81.911186218262,
          "AxleIndex": -1,
          "WheelIndices": [0, 1]
        },
        {
          "LocationX": -106.21788787842,
          "AxleIndex": -1,
          "WheelIndices": [2, 3]
        }
      ],
      "OptimalSlipAngleDegree": 20,
      "PhysicsSettings": {
        "TCSMinWheelSpeed": {
          "X": 100,
          "Y": 200
        }
      },
      "TailLights": [{}, {}],
      "Seats": [{}, {}],
      "VehicleOwnerProfitShareMultiplier": 0.40000000596046,
      "Pistons": {},
      "VehicleReplicatedMovements": [
        {
          "Movement": {
            "Location": {
              "Z": -21090.529360786,
              "Y": 109254.86770149,
              "X": 114305.20591233
            },
            "bForceSync": false,
            "Quat": {
              "Z": 0.15810445362784,
              "Y": -0.00095873363484434,
              "X": 0.0004238986404175,
              "W": 0.98742183634088
            },
            "AngularVelocityInRadian": {
              "Z": 0.000044418189645512,
              "Y": 0.00054324470693246,
              "X": -0.00048801451339386
            },
            "bIsBaseRelativeRotation": false,
            "VehicleState": {
              "Wheels": [
                {
                  "BrakeTemperature": 1310740,
                  "TireBrushTemperature": 1310740,
                  "TireCoreTemperature": 1310740,
                  "BrakeCoreTemperature": 1310740
                },
                {
                  "BrakeTemperature": 1310740,
                  "TireBrushTemperature": 1310740,
                  "TireCoreTemperature": 1310740,
                  "BrakeCoreTemperature": 1310740
                },
                {
                  "BrakeTemperature": 1310740,
                  "TireBrushTemperature": 1310740,
                  "TireCoreTemperature": 1310740,
                  "BrakeCoreTemperature": 1310740
                },
                {
                  "BrakeTemperature": 1310740,
                  "TireBrushTemperature": 536870932,
                  "TireCoreTemperature": 1310740,
                  "BrakeCoreTemperature": 1310740
                }
              ],
              "Fuel": 37.801036834717,
              "Condition": 1,
              "OdoMeterKm": 1.908841252327,
              "LiftAxleProgresses": {}
            },
            "bLODMildlyForced": false,
            "Throttle": 0,
            "BikeDriverLeaningDegree": 0,
            "DriverRelativeLookRotation": {
              "Pitch": -0.10080100543984,
              "Roll": 0.065334129559048,
              "Yaw": -18.193845599512
            },
            "Velocity": {
              "Z": -0.029533870518208,
              "Y": 0.019524648785591,
              "X": 0.0073567256331444
            },
            "EngineHotState": {
              "bStarterOn": false,
              "CurrentRPM": 0,
              "JakeBrake": 0,
              "bIgnitionOn": false,
              "CoolantTemp": 20,
              "RegenBrake": 1
            },
            "Brake": 0,
            "bLODForced": false,
            "bIsBaseRelative": false,
            "LOD": 0,
            "bInNotLoadedLevel": false,
            "bHasBaseVehicle": false,
            "HandBrake": 0,
            "Steer": 0,
            "bIsBaseOffset": false
          },
          "VehicleId": -2
        }
      ],
      "WaterBodies": {},
      "Customization": {
        "BodyColors": [
          {
            "MaterialSlotName": "Body_01",
            "Color": {
              "B": 140,
              "A": 255,
              "R": 131,
              "G": 143
            }
          },
          {
            "MaterialSlotName": "Body_02",
            "Color": {
              "B": 140,
              "A": 255,
              "R": 131,
              "G": 143
            }
          },
          {
            "MaterialSlotName": "CargoBed_01",
            "Color": {
              "B": 140,
              "A": 255,
              "R": 131,
              "G": 143
            }
          }
        ],
        "BodyMaterialIndex": 0
      },
      "Net_CompanyName": "",
      "RefuelSoundFadeInSeconds": 0.10000000149012,
      "BikeDriverLeaning": {
        "Pitch": 0,
        "Roll": 0,
        "Yaw": 0
      },
      "Winches": {},
      "Net_AccountNickname": "",
      "BodyMaterialNames": ["Body"],
      "DefaultDrivingMode": 1,
      "NetLC_TransmissionColdState": {
        "CurrentGear": 1
      },
      "AirDragCoeff": 0.5,
      "AIDriverSetting": {
        "LateralG": 0.30000001192093,
        "RaceLateralG": 0.60000002384186,
        "RaceBrakingG": 0.60000002384186,
        "BrakingG": 0.15000000596046
      },
      "RattleSoundG": 1,
      "bHasSteeringWheel": true,
      "Net_Cargo": {
        "MaxVolumes": 0,
        "CargoWeightKg": 0,
        "LoadedVolumes": 0,
        "NumCargo": 0
      },
      "LOD3UnregisterComponents": [
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {},
        {}
      ],
      "AeroParts": {
        "125": {}
      },
      "Server_GarbageCompress": {},
      "BrakeTorqueMultiplier": 1,
      "IgnoreCollisionComponents": {},
      "KeyboardSteerSpeed": 2,
      "AntiRollBars": [
        {
          "SpringD": 500,
          "Wheel1Name": "Wheel1",
          "Wheel0Name": "Wheel0",
          "SpringK": 80000
        },
        {
          "SpringD": 100,
          "Wheel1Name": "Wheel3",
          "Wheel0Name": "Wheel2",
          "SpringK": 3000
        }
      ],
      "BlinkerLights": [{}, {}, {}, {}],
      "LimitSteeringByLateralG": 0,
      "bHasDriverSeat": true,
      "AeroLiftCoeff_Rear": 0,
      "LiftAxles": {},
      "Suspensions": {},
      "Net_bPTOOn": false,
      "EmegencyLights": {},
      "NetLC_VehicleState": {
        "Wheels": [
          {
            "BrakeTemperature": 1310740,
            "TireBrushTemperature": 1310740,
            "TireCoreTemperature": 1310740,
            "BrakeCoreTemperature": 1310740
          },
          {
            "BrakeTemperature": 1310740,
            "TireBrushTemperature": 1310740,
            "TireCoreTemperature": 1310740,
            "BrakeCoreTemperature": 1310740
          },
          {
            "BrakeTemperature": 1310740,
            "TireBrushTemperature": 1310740,
            "TireCoreTemperature": 1310740,
            "BrakeCoreTemperature": 1310740
          },
          {
            "BrakeTemperature": 1310740,
            "TireBrushTemperature": 1461714964,
            "TireCoreTemperature": 1310740,
            "BrakeCoreTemperature": 1310740
          }
        ],
        "Fuel": 37.801036834717,
        "Condition": 1,
        "OdoMeterKm": 1.908841252327,
        "LiftAxleProgresses": {}
      },
      "SirenSounds": {},
      "OverlappingActors": [{}, {}, {}, {}, {}],
      "ParallelSteering": 0.80000001192093,
      "Net_VehicleOwnerSetting": {
        "LevelRequirementsToDrive": [0, 0, 0, 0, 0, 0, 0],
        "bLocked": false,
        "DriveAllowedPlayers": 0,
        "VehicleOwnerProfitShare": 0.083200000226498
      },
      "MaxSteeringWheelAngleDegree": 450,
      "bLeanDriver": false,
      "Net_VehicleId": -2,
      "AeroLiftCoeff_Front": 0,
      "AeroLiftCoeff": {
        "X": 0,
        "Y": 0
      },
      "Constraints": {},
      "Net_CargoBedParts": {},
      "Net_RoofRackParts": {},
      "Net_OwnerCharacterId": {
        "UniqueNetId": "",
        "CharacterGuid": "00000000000000000000000000000000"
      },
      "HandBrake": 0,
      "NetLC_EngineColdState": {
        "bDisabled": false,
        "bOverHeated": false
      },
      "Throttle": 0,
      "LOD1DisableTickComponents": {},
      "BodyMaterialName": "Body",
      "Net_VehicleSettings": [
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 0,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 0
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 1,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 1
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 1,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 2
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 2,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 3
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 10,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 4
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 0.5,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 5
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 1,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 6
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 2,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 7
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 10,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 8
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 100,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 9
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 100,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 10
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 0,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 11
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 1,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 12
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 1,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 13
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 20,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 14
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 100,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 15
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 1,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 16
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 1,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 17
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 20,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 18
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 100,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 19
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 100,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 20
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 100,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 21
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 0,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 22
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 1,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 23
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 1,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 24
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 20,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 25
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 100,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 26
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 1,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 27
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 1,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 28
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 20,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 29
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 100,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 30
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 100,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 31
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 100,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 32
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 0,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 33
        },
        {
          "Value": {
            "BoolValue": false,
            "FloatValue": 0,
            "EnumValue": 0,
            "ValueType": 2,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 34
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 0,
            "EnumValue": 1,
            "ValueType": 4,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 35
        },
        {
          "Value": {
            "BoolValue": false,
            "FloatValue": 0,
            "EnumValue": 0,
            "ValueType": 2,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 36
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 0,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 37
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 0,
            "EnumValue": 0,
            "ValueType": 4,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 38
        },
        {
          "Value": {
            "BoolValue": true,
            "FloatValue": 1,
            "EnumValue": 0,
            "ValueType": 0,
            "StringValue": "",
            "Int64Value": 0
          },
          "SettingType": 39
        }
      ],
      "AttachmentParts": {},
      "DecalableMaterialSlotNames": ["Body_01", "Body_02", "CargoBed_01"],
      "MirrorComponents": [{}, {}, {}],
      "bUseSteeringWheelSocketAsPivot": false,
      "Net_LastNoMovementOwnerPCServerTimeSeconds": 0,
      "ExControls": [5, 1, 15, 2, 9, 10, 16, 7, 8],
      "Net_OwnerCompanyGuid": "00000000000000000000000000000000",
      "BodyMaterials": {},
      "ColorSlots": {
        "Body_01": {
          "bUseColorAlpha": false,
          "DisplayName": "Body1",
          "DefaultColor": {
            "B": 255,
            "A": 255,
            "R": 255,
            "G": 255
          }
        },
        "Window": {
          "bUseColorAlpha": true,
          "DisplayName": "Window1",
          "DefaultColor": {
            "B": 150,
            "A": 63,
            "R": 101,
            "G": 158
          }
        },
        "Seats_02": {
          "bUseColorAlpha": false,
          "DisplayName": "Seat2",
          "DefaultColor": {
            "B": 199,
            "A": 255,
            "R": 115,
            "G": 186
          }
        },
        "Body_02": {
          "bUseColorAlpha": false,
          "DisplayName": "Body2",
          "DefaultColor": {
            "B": 255,
            "A": 255,
            "R": 255,
            "G": 255
          }
        },
        "CargoBed_01": {
          "bUseColorAlpha": false,
          "DisplayName": "Cargo Bed1",
          "DefaultColor": {
            "B": 255,
            "A": 255,
            "R": 255,
            "G": 255
          }
        },
        "Seats_01": {
          "bUseColorAlpha": false,
          "DisplayName": "Seat1",
          "DefaultColor": {
            "B": 95,
            "A": 255,
            "R": 95,
            "G": 95
          }
        }
      },
      "Net_Parts": [
        {
          "Damage": 0,
          "StringValues": {},
          "Key": "5SpeedSports",
          "VectorValues": {},
          "ItemInventory": {
            "Slots": {}
          },
          "Int64Values": {},
          "ID": -1,
          "Slot": 3,
          "FloatValues": {}
        },
        {
          "Damage": 0,
          "StringValues": {},
          "Key": "110",
          "VectorValues": {},
          "ItemInventory": {
            "Slots": {}
          },
          "Int64Values": {},
          "ID": -2,
          "Slot": 4,
          "FloatValues": {}
        },
        {
          "Damage": 0,
          "StringValues": {},
          "Key": "I4_50HP",
          "VectorValues": {},
          "ItemInventory": {
            "Slots": {}
          },
          "Int64Values": {},
          "ID": -3,
          "Slot": 2,
          "FloatValues": {}
        },
        {
          "Damage": 0,
          "StringValues": {},
          "Key": "SmallRadiator_100",
          "VectorValues": {},
          "ItemInventory": {
            "Slots": {}
          },
          "Int64Values": {},
          "ID": -4,
          "Slot": 6,
          "FloatValues": [1]
        },
        {
          "Damage": 0.00013500699424185,
          "StringValues": {},
          "Key": "BasicTire_65",
          "VectorValues": {},
          "ItemInventory": {
            "Slots": {}
          },
          "Int64Values": {},
          "ID": -5,
          "Slot": 19,
          "FloatValues": {}
        },
        {
          "Damage": 0.00015065034676809,
          "StringValues": {},
          "Key": "BasicTire_65",
          "VectorValues": {},
          "ItemInventory": {
            "Slots": {}
          },
          "Int64Values": {},
          "ID": -6,
          "Slot": 20,
          "FloatValues": {}
        },
        {
          "Damage": 0.000069469439040404,
          "StringValues": {},
          "Key": "BasicTire_45",
          "VectorValues": {},
          "ItemInventory": {
            "Slots": {}
          },
          "Int64Values": {},
          "ID": -7,
          "Slot": 21,
          "FloatValues": {}
        },
        {
          "Damage": 0.000088472646893933,
          "StringValues": {},
          "Key": "BasicTire_45",
          "VectorValues": {},
          "ItemInventory": {
            "Slots": {}
          },
          "Int64Values": {},
          "ID": -8,
          "Slot": 22,
          "FloatValues": {}
        },
        {
          "Damage": 0,
          "StringValues": {},
          "Key": "Dabo_01",
          "VectorValues": {},
          "ItemInventory": {
            "Slots": {}
          },
          "Int64Values": {},
          "ID": -9,
          "Slot": 40,
          "FloatValues": {}
        },
        {
          "Damage": 0,
          "StringValues": {},
          "Key": "Dabo_01",
          "VectorValues": {},
          "ItemInventory": {
            "Slots": {}
          },
          "Int64Values": {},
          "ID": -10,
          "Slot": 41,
          "FloatValues": {}
        },
        {
          "Damage": 0,
          "StringValues": {},
          "Key": "Dabo_01",
          "VectorValues": {},
          "ItemInventory": {
            "Slots": {}
          },
          "Int64Values": {},
          "ID": -11,
          "Slot": 42,
          "FloatValues": {}
        },
        {
          "Damage": 0,
          "StringValues": {},
          "Key": "Dabo_01",
          "VectorValues": {},
          "ItemInventory": {
            "Slots": {}
          },
          "Int64Values": {},
          "ID": -12,
          "Slot": 43,
          "FloatValues": {}
        },
        {
          "Damage": 0.0030452054925263,
          "StringValues": {},
          "Key": "DefaultBody",
          "VectorValues": {},
          "ItemInventory": {
            "Slots": {}
          },
          "Int64Values": {},
          "ID": -13,
          "Slot": 1,
          "FloatValues": {}
        },
        {
          "Damage": 0.001053967513144,
          "StringValues": {},
          "Key": "BrakePad_Small_01",
          "VectorValues": {},
          "ItemInventory": {
            "Slots": {}
          },
          "Int64Values": {},
          "ID": -14,
          "Slot": 70,
          "FloatValues": {}
        },
        {
          "Damage": 0.0010726300533861,
          "StringValues": {},
          "Key": "BrakePad_Small_01",
          "VectorValues": {},
          "ItemInventory": {
            "Slots": {}
          },
          "Int64Values": {},
          "ID": -15,
          "Slot": 71,
          "FloatValues": {}
        },
        {
          "Damage": 0.00016215826326516,
          "StringValues": {},
          "Key": "BrakePad_Small_01",
          "VectorValues": {},
          "ItemInventory": {
            "Slots": {}
          },
          "Int64Values": {},
          "ID": -16,
          "Slot": 72,
          "FloatValues": {}
        },
        {
          "Damage": 0.00016261906421278,
          "StringValues": {},
          "Key": "BrakePad_Small_01",
          "VectorValues": {},
          "ItemInventory": {
            "Slots": {}
          },
          "Int64Values": {},
          "ID": -17,
          "Slot": 73,
          "FloatValues": {}
        },
        {
          "Damage": 0,
          "StringValues": {},
          "Key": "Dabo_FrontBumper_01",
          "VectorValues": {},
          "ItemInventory": {
            "Slots": {}
          },
          "Int64Values": {},
          "ID": -18,
          "Slot": 125,
          "FloatValues": {}
        }
      ],
      "LOD4UnregisterComponents": [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}],
      "AreaVolumes": [{}],
      "Laptime": {
        "Courses": {
          "Range_Oval_1": {
            "NumSections": 2,
            "Sections": [{}, {}]
          },
          "OlleSpeedway_1": {
            "NumSections": 2,
            "Sections": [{}, {}]
          },
          "AnsanOval": {
            "NumSections": 2,
            "Sections": [{}, {}]
          },
          "OlleSpeedway_Kart_1": {
            "NumSections": 2,
            "Sections": [{}, {}]
          },
          "Ae-Wol_OffRoad": {
            "NumSections": 12,
            "Sections": [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}]
          },
          "AnsanSpeedway": {
            "NumSections": 3,
            "Sections": [{}, {}, {}]
          },
          "Ae-Wol_InnerTrack": {
            "NumSections": 4,
            "Sections": [{}, {}, {}, {}]
          },
          "HaborRaceway2": {
            "NumSections": 12,
            "Sections": [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}]
          }
        }
      },
      "ControlSettings": {
        "SteeringAssistMinSpeed": {
          "X": 0,
          "Y": 200
        },
        "SteeringSpeedInComfort": 0.5,
        "bRearSteering": false
      },
      "InteriorLights": [{}, {}, {}, {}, {}],
      "CargoSpaces": [{}],
      "Net_CompanyGuid": "00000000000000000000000000000000",
      "VehicleReplicatedMovement": {
        "Location": {
          "Z": -21090.529360786,
          "Y": 109254.86770149,
          "X": 114305.20591233
        },
        "bForceSync": false,
        "Quat": {
          "Z": 0.15810445362784,
          "Y": -0.00095873363484434,
          "X": 0.0004238986404175,
          "W": 0.98742183634088
        },
        "AngularVelocityInRadian": {
          "Z": 0.000044418189645512,
          "Y": 0.00054324470693246,
          "X": -0.00048801451339386
        },
        "bIsBaseRelativeRotation": false,
        "VehicleState": {
          "Wheels": [
            {
              "BrakeTemperature": 1310740,
              "TireBrushTemperature": 1310740,
              "TireCoreTemperature": 1310740,
              "BrakeCoreTemperature": 1310740
            },
            {
              "BrakeTemperature": 1310740,
              "TireBrushTemperature": 1310740,
              "TireCoreTemperature": 1310740,
              "BrakeCoreTemperature": 1310740
            },
            {
              "BrakeTemperature": 1310740,
              "TireBrushTemperature": 1310740,
              "TireCoreTemperature": 1310740,
              "BrakeCoreTemperature": 1310740
            },
            {
              "BrakeTemperature": 1310740,
              "TireBrushTemperature": 2097172,
              "TireCoreTemperature": 1310740,
              "BrakeCoreTemperature": 1310740
            }
          ],
          "Fuel": 37.801036834717,
          "Condition": 1,
          "OdoMeterKm": 1.908841252327,
          "LiftAxleProgresses": {}
        },
        "bLODMildlyForced": false,
        "Throttle": 0,
        "BikeDriverLeaningDegree": 0,
        "DriverRelativeLookRotation": {
          "Pitch": -0.10080100543984,
          "Roll": 0.065334129559048,
          "Yaw": -18.193845599512
        },
        "Velocity": {
          "Z": -0.029533870518208,
          "Y": 0.019524648785591,
          "X": 0.0073567256331444
        },
        "EngineHotState": {
          "bStarterOn": false,
          "CurrentRPM": 0,
          "JakeBrake": 0,
          "bIgnitionOn": false,
          "CoolantTemp": 20,
          "RegenBrake": 1
        },
        "Brake": 0,
        "bLODForced": false,
        "bIsBaseRelative": false,
        "LOD": 0,
        "bInNotLoadedLevel": false,
        "bHasBaseVehicle": false,
        "HandBrake": 0,
        "Steer": 0,
        "bIsBaseOffset": false
      },
      "Server_Winches": {},
      "LOD2UnregisterComponents": [{}],
      "RefuelSoundFadeOutSeconds": 0.10000000149012,
      "Steer": 0,
      "BodyColors": [
        {
          "Colors": {
            "Body_02": {
              "B": 140,
              "A": 255,
              "R": 131,
              "G": 143
            },
            "CargoBed_01": {
              "B": 140,
              "A": 255,
              "R": 131,
              "G": 143
            },
            "Body_01": {
              "B": 140,
              "A": 255,
              "R": 131,
              "G": 143
            }
          }
        },
        {
          "Colors": {
            "Body_02": {
              "B": 221,
              "A": 255,
              "R": 159,
              "G": 181
            },
            "CargoBed_01": {
              "B": 221,
              "A": 255,
              "R": 159,
              "G": 181
            },
            "Body_01": {
              "B": 221,
              "A": 255,
              "R": 159,
              "G": 181
            }
          }
        },
        {
          "Colors": {
            "Body_02": {
              "B": 237,
              "A": 0,
              "R": 237,
              "G": 237
            },
            "CargoBed_01": {
              "B": 237,
              "A": 0,
              "R": 237,
              "G": 237
            },
            "Body_01": {
              "B": 237,
              "A": 0,
              "R": 237,
              "G": 237
            }
          }
        }
      ],
      "Net_VehicleFlags": 66561,
      "HornFadeOutSeconds": 0.10000000149012,
      "AttachmentPartsComponents": {},
      "ExplosionDetector": {},
      "LocalBoundsComponentDefaultTransforms": {},
      "Net_Seats": [
        {
          "SeatName": "DriverSeat",
          "bHasCharacter": false
        },
        {
          "SeatName": "PassengerSeat1",
          "bHasCharacter": false
        }
      ],
      "AirDragFrontalAreaMultiplier": 0.89999997615814,
      "Differentials": [{}],
      "DiffLockings": {},
      "BaseLeanForwardDegree": 0,
      "Net_Decal": {
        "DecalLayers": {}
      },
      "LC_InteractionCandidates": {},
      "bDrivable": true,
      "StaticMeshDefaultTransforms": {},
      "MaxSteeringAngleDegree": 40,
      "BrakeTemperatureMass": -1,
      "Net_Hooks": {},
      "UtilitySlots": {},
      "LocalBoundsComponents": [{}, {}, {}, {}]
    },
    "SeatType": 1
  }
}
```

</details>

#### Player entered a vehicle by ID and/or seat name `ServerEnterVehicleByIdAndSeatName`

Called when a player has entered a vehicle using a seat ID/name. Usually called after being spawned into the world in a vehicle.

<details>
<summary>Response data:</summary>

```json
{
  "hook": "/Script/MotorTown.MotorTownPlayerController:ServerEnterVehicleByIdAndSeatName",
  "timestamp": 1755002053634,
  "data": {
    "SeatName": "DriverSeat",
    "PlayerId": "76561198041602276",
    "CheckDistance": false,
    "VehicleId": -2
  }
}
```

</details>
