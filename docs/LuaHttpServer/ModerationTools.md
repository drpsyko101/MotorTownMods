# Moderation tools

Collection of useful requests to moderate the players in-game.

#### POST `/messages/popup`

Show a popup message for everyone or at a specified player. Use `\n` to indicate a new line. The content can be customized by using the XML-like tag as follows, with the rests are within the image below:

```xml
<Title>This is a title</>\n<Small>This is a small subtitle</>
```

![example popup with tags](https://media.discordapp.net/attachments/1359918336007213236/1396799659674177616/image.png?ex=687f668e&is=687e150e&hm=c4f97310c0dbe1518ae39c7d999fe040d06abc81b5da7a25e60ac74c486bc8ed&=&format=webp&quality=lossless)

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

#### POST `/messages/announce`

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
