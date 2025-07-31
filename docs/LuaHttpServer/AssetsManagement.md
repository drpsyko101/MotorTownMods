# Assets management

Manages objects that aren't directly related to any of the other categories. Static/dynamic props like trees, barriers, or cosmetic container fit this type of category.

#### POST `/assets/spawn`

Spawn a given asset path at specified location and rotation. Rotation field is optional. If no tags are provided, a new one will be generated for each asset.

<details>
<summary>Request body:</summary>

Spawning a single actor:

```json
{
  // Path to the spawnable asset. Currently limited to blueprint actor and static mesh.
  // The path must be using the mounted path style, where the Content directory will be mounted as Game during runtime.
  "AssetPath": "/Game/Objects/ParkingSpace/Interaction_ParkingSpace_Large.Interaction_ParkingSpace_Large_C",
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
    "AssetPath": "/Game/Objects/ParkingSpace/Interaction_ParkingSpace_Large.Interaction_ParkingSpace_Large_C",
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
