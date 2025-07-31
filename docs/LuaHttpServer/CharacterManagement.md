# Character management

#### GET `/characters`

Get all characters data.

<details>
<summary>Query:</summary>

- `filters` (string|multi) - `AbilityComponent`,`CameraBoom`,`FollowCamera`,`VoiceLineData`,`InteractionMontages`,`InteractionFailMontage`,`FirstPersonCamera`,`Passenger`,`Net_GroupPassenger`,`BaseTurnRate`,`BaseLookUpRate`,`Net_Customization`,`Net_ResidentKey`,`MapIconName`,`LC_InteractionTarget`,`Net_Cargo`,`Net_HoldingItem`,`Net_SeatPositionType`,`Net_Seat`,`Net_Pose`,`Net_PoseFlags`,`Net_CharacterFlags`,`Net_Buff2`,`GameplayTagContainer`,`Net_MTPlayerState`,`Net_LookRotation`,`Net_bSprint`
- `limit` (integer) - Limit the amount of results returned
- `depth` (integer|default `2`) - Recursive search depth limit

</details>

<details>
<summary>Response data:</summary>

```json
{
  "data": [
    {
      "Net_bSprint": false,
      "InteractionMontages": {
        "54": {}
      },
      "LC_InteractionTarget": {
        "Interactables": {},
        "ItemTargetComponents": {},
        "ItemTargetActors": {}
      },
      "Net_CharacterFlags": 0,
      "GameplayTagContainer": {
        "GameplayTags": {},
        "ParentTags": {}
      },
      "BaseTurnRate": 45,
      "Net_PoseFlags": 0,
      "Net_Customization": {
        "BodyKey": "None",
        "CostumeBodyKey": "None",
        "CostumeItemKey": "None"
      },
      "MapIconName": "",
      "Net_HoldingItem": {
        "QuickSlotIndex": -1,
        "ItemKey": "None"
      },
      "Net_LookRotation": {
        "Yaw": 0,
        "Pitch": 0,
        "Roll": 0
      },
      "Net_Pose": 0,
      "Net_Buff2": {
        "Net_Buffs": {},
        "BuffDataList": {}
      },
      "Net_SeatPositionType": 0,
      "BaseLookUpRate": 45,
      "Net_ResidentKey": "None"
    }
  ]
}
```

</details>
