# Moderation tools

Collection of useful requests to moderate the players in-game.

#### POST `/messages/popup`

Show a popup message for everyone or at a specified player.

<details>
<summary>Request body:</summary>

Spawning popup message for a single player:

```json
{
  "message": "",
  "playerId": ""
}
```

Spawning popup message for multiple players:

```json
{
  "message": "",
  "playerId": [""]
}
```

Omit `playerId` to spawn popup message to everyone:

```json
{
  "message": ""
}
```

</details>

<details>
<summary>Response data:</summary>

```json
{
  "status": "ok"
}
```

</details>

#### POST `/server/announce`

Post an announcement on the server. Does have an option to pin the announcement. Requires an admin player to be present on the server, with an exception to the pin option.

<details>
<summary>Request body:</summary>

```json
{
  "message": "Some announcement here",
  "playerId": "",
  "isPinned": false
}
```

</details>

<details>
<summary>Response data:</summary>

```json
{
  "status": "ok"
}
```

</details>
