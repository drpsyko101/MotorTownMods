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
