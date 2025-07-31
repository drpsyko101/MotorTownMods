# Cargo management

Manages all objects related to the game's delivery system, from manufacturing to transportation logistics.

#### GET `/delivery/points`

Returns all delivery points in-game. Note that this is a bandwith heavy operation if not supplied with any filters. Use sparingly.

<details>
<summary>Query:</summary>

- `filters` (string|multi) - `MaxDeliveryDistance,Supplies,DeliveryPointName,MaxPassiveDeliveries,MissionPointType,MaxDeliveryReceiveDistance,bUseAsDestinationInteraction,bConsumeContainer,Net_RuntimeFlags,bShowStorage,DemandConfigs,InputInventoryShareTarget,BasePayment,InputInventoryShare,Net_OutputInventory,DestinationCargoLimits,bIsSender,PassiveSupplies,Net_ProductionLocalFoodSupply,Net_ProductionBonusByPopulation,Net_ProductionBonusByProduction,ProductionConfigs,MaxStorage,Net_Deliveries,PaymentMultiplier,GameplayTags,bRemoveUnusedInputCargo,DestinationTypes,StorageConfigs,DestinationExcludeTypes,bIsReceiver,MissionPointName,Net_InputInventory,PointName,bLoadCargoBySpawnAtPoint,DemandPriority,MaxDeliveries,Demands`
- `limit` (integer) - Limit the amount of results returned
- `depth` (integer|default `2`) - Recursive search depth limit

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
