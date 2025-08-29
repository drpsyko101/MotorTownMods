# Vehicle management

#### GET `/vehicles`

Get all currently available vehicles in game. This is a very resource intensive request if no filters applied. Use sparingly.

<details>
<summary>Query:</summary>

- `filters` (string|multi) - `DefaultVehicleFeatures,ExControls,BodyMaterials,BodyMaterialList,BodyMaterialName,BodyMaterialNames,DecalableMaterialSlotNames,BodyColorMaterialSlotNames,ColorSlots,BodyColors,BusComponentClass,RootBody,Mesh,SteeringWheel,Wheels,EngineComponent,CargoSpaceInteractableComponent,DrivingInput,HornAudioComponent,SirenAudioComponent,BackupBeepAudioComponent,RefuelAudioComponent,AirHydraulicAudioComponent,WindNoiseAudioComponent,AirHydraulicSound,DriverSeatInteractionSphereComponent,DriverSeatInteractableComponent,PassengerSeatInteractionSphereComponent,PassengerSeatInteractableComponent,NavModifierComponent,Dashboard,CameraSpringArm,TrailCamera,CockpitCamera,LOD1DisableTickComponents,LOD2DisableTickComponents,LOD2UnregisterComponents,LOD3UnregisterComponents,LOD4UnregisterComponents,TransmissionComponent,Differentials,Seats,MirrorComponents,Doors,CargoSpaces,TaxiComponent,Net_BusComponent,TruckComponent,WreckerComponent,TrailerComponent,Headlights,TailLights,ReverseLights,BlinkerLights,EmegencyLights,Constraints,ForkliftTiltConstraint,ForkliftLiftConstraints,ForkliftForkLeftConstraint,ForkliftForkRightConstraint,Winches,TowRequestComponent,TowingComponent,PartSlots,InteriorLights,TaxiRoofSign,RearSpoiler,RearWing,AeroParts,AttachmentParts,AttachmentPartsComponents,Net_RoofRackParts,Net_CargoBedParts,Server_Winches,TrailerHitch,PoliceComponent,SellerComponent,CraneComponent,GetawayComponent,DecalComponent,TankerFuelPumpComponent,GameplayTagContainer,StaticMeshDefaultTransforms,bForSale,bDrivable,bHasSteeringWheel,bHasDriverSeat,bHasPassengerSeat,AIDriverSetting,bIsOpenAir,DefaultDrivingMode,MaxSteeringAngleDegree,ParallelSteering,OptimalSlipAngleDegree,SteeringOffsetX,MaxSteeringWheelAngleDegree,BrakeTorqueMultiplier,BrakeTemperatureMass,KeyboardSteerSpeed,KeyboardSteerReturnSpeed,AntiRollBars,Suspensions,Pistons,FuelTankCapacityInLiter,AirDragCoeff,AeroLiftCoeff,AeroLiftCoeff_Front,AeroLiftCoeff_Rear,AirDragFrontalAreaMultiplier,DiffLockings,LiftAxles,ControlSettings,PhysicsSettings,bUseSteeringWheelSocketAsPivot,bSteeringAttachedToSkeletalSocket,LimitSteeringByLateralG,bLeanDriver,BaseLeanForwardDegree,HornSound,HornFadeInSeconds,HornFadeOutSeconds,SirenSounds,AirBrakeSound,ParkingBrakeSound,ParkingBrakeReleaseSound,BackupBeep,RefuelingSound,RefuelSoundFadeInSeconds,RefuelSoundFadeOutSeconds,RefuelingEndSound,RattleSound,RattleSoundG,WindNoiseSound,WindNoiseVolume,Throttle,Brake,Steer,HandBrake,Clutch,BikeDriverLeaning,Net_VehicleFlags,WheelAxles,LocalBoundsComponents,LocalBoundsComponentDefaultTransforms,VehicleReplicatedMovement,VehicleReplicatedMovements,NetLC_VehicleState,NetLC_ColdState,NetLC_EngineHotState,NetLC_EngineColdState,NetLC_TransmissionColdState,Net_Seats,Net_Cargo,Net_VehicleOwnerSetting,Net_VehicleSettings,Customization,Net_Decal,Net_OwnerPlayerState,Net_OwnerCharacterId,Net_OwnerCompanyGuid,Net_AccountNickname,Net_VehicleId,Server_OwnerPlayerController,Net_Parts,UtilitySlots,Net_AINetData,InternalWindowMaterials,LC_InteractionCandidates,Laptime,TrailerHitchSocketComponent,CurrentRoad,Net_Hooks,Net_Tractor,Net_MovementOwnerPC,Server_TempMovementOwnerPCs,Server_LastMovementOwnerPC,Net_LastNoMovementOwnerPCServerTimeSeconds,Net_LastMovementOwnerPCName,VehicleOwnerProfitShareMultiplier,ExplosionDetector,Server_GarbageCompress,Server_LastPlayerController,IgnoreCollisionComponents,Net_CarCarrierCargoSpace,Net_CompanyGuid,Net_CompanyName,OverlappingActors,AreaVolumes,WaterBodies,Net_PTOThrottle,Net_bPTOOn`
- `limit` (integer) - Limit the amount of result(s)
- `isPlayerControlled` (boolean) - Returns only vehicles currently being driven by player.
- `depth` (integer|default `2`) - Recursive search depth limit

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

#### PATCH `/vehicles`

Patch a vehicle parameter based on the player unique ID.

<details>
<summary>Request body:</summary>

```json
{
  "PlayerId": "",
  "Field": "NetLC_VehicleState.Fuel",
  "Value": 10
}
```

</details>

<details>
<summary>Response data:</summary>

```json
{ "status": "ok" }
```

</details>

#### GET `/vehicles/<id>`

Get selected vehicle ID. This is currently only works for player owned vehicles as NPC vehicles are marked with negative integers. Retuns the same response and using the same query as [`GET /vehicles`](#get-vehicles).

#### PATCH `/vehicles/<id>`

Patch a vehicle parameter based on the vehicle ID. Uses the same request body and return response as [`PATCH /vehicles`](#patch-vehicles) without the `PlayerId` field.

#### POST `/vehicles/<id>/despawn`

Despawn selected vehicle with the given ID. This is currently only works for player owned vehicles as NPC vehicles are marked with negative integers. Returns a `204` for a successful request.

#### POST `/vehicles/<id>/fuel`

Set the vehicle fuel amount.

<details>
<summary>Request body:</summary>

```json
{
  "InFuel": 55.0
}
```

</details>

#### POST `/vehicles/<id>/damage`

Set the damage value to a specific part of a vehicle given the vehicle ID.

<details>
<summary>Request body:</summary>

```json
{
  // Vehicle part enum value
  // Body = 1,
  // Engine = 2,
  // Transmission = 3,
  // FinalDriveRatio = 4,
  // Intake = 5,
  // CoolantRadiator = 6,
  // Turbocharger = 7,
  // LSD0 = 8,
  // LSD1 = 9,
  // LSD2 = 10,
  // LSD3 = 11,
  // LSD4 = 12,
  // LSD5 = 13,
  // LSD6 = 14,
  // LSD7 = 15,
  // LSD8 = 16,
  // LSD9 = 17,
  // LSDMax = 18,
  // Tire0 = 19,
  // Tire1 = 20,
  // Tire2 = 21,
  // Tire3 = 22,
  // Tire4 = 23,
  // Tire5 = 24,
  // Tire6 = 25,
  // Tire7 = 26,
  // Tire8 = 27,
  // Tire9 = 28,
  // Tire10 = 29,
  // Tire11 = 30,
  // Tire12 = 31,
  // Tire13 = 32,
  // Tire14 = 33,
  // Tire15 = 34,
  // Tire16 = 35,
  // Tire17 = 36,
  // Tire18 = 37,
  // Tire19 = 38,
  // TireMax = 39,
  // Wheel0 = 40,
  // Wheel1 = 41,
  // Wheel2 = 42,
  // Wheel3 = 43,
  // Wheel4 = 44,
  // Wheel5 = 45,
  // Wheel6 = 46,
  // Wheel7 = 47,
  // Wheel8 = 48,
  // Wheel9 = 49,
  // Wheel10 = 50,
  // Wheel11 = 51,
  // Wheel12 = 52,
  // Wheel13 = 53,
  // Wheel14 = 54,
  // Wheel15 = 55,
  // Wheel16 = 56,
  // Wheel17 = 57,
  // Wheel18 = 58,
  // Wheel19 = 59,
  // WheelMax = 60,
  // WheelSpacer0 = 61,
  // WheelSpacer1 = 62,
  // WheelSpacer2 = 63,
  // WheelSpacer3 = 64,
  // WheelSpacer4 = 65,
  // WheelSpacer5 = 66,
  // WheelSpacer6 = 67,
  // WheelSpacer7 = 68,
  // WheelSpacerMax = 69,
  // BrakePad0 = 70,
  // BrakePad1 = 71,
  // BrakePad2 = 72,
  // BrakePad3 = 73,
  // BrakePad4 = 74,
  // BrakePad5 = 75,
  // BrakePad6 = 76,
  // BrakePad7 = 77,
  // BrakePadMax = 78,
  // AngleKit = 79,
  // Suspension_Spring0 = 80,
  // Suspension_Spring1 = 81,
  // Suspension_Spring2 = 82,
  // Suspension_Spring3 = 83,
  // Suspension_Spring4 = 84,
  // Suspension_Spring5 = 85,
  // Suspension_Spring6 = 86,
  // Suspension_Spring7 = 87,
  // Suspension_SpringMax = 88,
  // Suspension_Damper0 = 89,
  // Suspension_Damper1 = 90,
  // Suspension_Damper2 = 91,
  // Suspension_Damper3 = 92,
  // Suspension_Damper4 = 93,
  // Suspension_Damper5 = 94,
  // Suspension_Damper6 = 95,
  // Suspension_Damper7 = 96,
  // Suspension_DamperMax = 97,
  // Suspension_RideHeight0 = 98,
  // Suspension_RideHeight1 = 99,
  // Suspension_RideHeight2 = 100,
  // Suspension_RideHeight3 = 101,
  // Suspension_RideHeight4 = 102,
  // Suspension_RideHeight5 = 103,
  // Suspension_RideHeight6 = 104,
  // Suspension_RideHeight7 = 105,
  // Suspension_RideHeightMax = 106,
  // AntiRollBar0 = 107,
  // AntiRollBar1 = 108,
  // AntiRollBar2 = 109,
  // AntiRollBarMax = 110,
  // TaxiLicense = 111,
  // BusLicense = 112,
  // FrontSpoiler = 113,
  // RearSpoiler = 114,
  // RearWing = 115,
  // Fender = 116,
  // SideSkirt = 117,
  // FrontWindowSticker = 118,
  // RearWindowLouvers = 119,
  // TrailerHitch = 120,
  // CargoBed0 = 121,
  // CargoBedAttachment0 = 122,
  // RoofRack0 = 123,
  // Roof = 124,
  // FrontBumper = 125,
  // RearBumper = 126,
  // Bonnet = 127,
  // Trunk = 128,
  // Winch0 = 129,
  // Crane0 = 130,
  // Crane1 = 131,
  // Crane2 = 132,
  // BrakePower = 133,
  // Headlight = 134,
  // Utility0 = 135,
  // Utility1 = 136,
  // Utility2 = 137,
  // Utility3 = 138,
  // Utility4 = 139,
  // Utility5 = 140,
  // Utility6 = 141,
  // Utility7 = 142,
  // Utility8 = 143,
  // Utility9 = 144,
  // UtilityMax = 145,
  // Bullbar = 146,
  // Attachment0 = 147,
  // Attachment1 = 148,
  // Attachment2 = 149,
  // Attachment3 = 150,
  // Attachment4 = 151,
  // Attachment5 = 152,
  // Attachment6 = 153,
  // Attachment7 = 154,
  // Attachment8 = 155,
  // Attachment9 = 156,
  // AttachmentMax = 157,
  "PartSlot": 6,
  // Damage value 1.0 indicate full damage, while 0.0 has no damage.
  "NewDamage": 0.0
}
```

</details>

#### POST `/dealers/spawn`

Spawn a vehicle dealer spawn point at given location, along with optional vehicle parameter. The vehicle pricing is calculated based on the vehicle base value and equipped parts. Can be despawned using POST `/assets/despawn` with the given tag.

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

#### GET `/garages`

Get all of the garage instances in-game.

<details>
<summary>Response data:</summary>

```json
{
  "GameplayTags": {},
  "GarageFlags": 0,
  "AvailableVehiclePartTagQuery": {
    "AutoDescription": "",
    "QueryTokenStream": {},
    "TagDictionary": {},
    "UserDescription": "",
    "TokenStreamVersion": 0
  },
  "Rotation": { "Yaw": 90.0, "Pitch": 0.0, "Roll": 0.0 },
  "Location": { "Y": 153460.28125, "X": -48329.17578125, "Z": -20990.1640625 }
}
```

</details>

#### POST `/garages/spawn`

Spawn a new garage instance at given location.

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
  "data": {
    "tag": "6E6705764C17B7F764098091A10567E7"
  }
}
```

</details>
