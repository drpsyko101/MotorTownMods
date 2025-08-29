### New (reworked) company endpoints!

* `GET /companies` - Now returns company data properly
* `GET /companies/<guid>` - Get a specific company data
* `GET /companies/<guid>/vehicles` - Get a company vehicle list
* `GET /companies/<guid>/routes/bus` - Get a company bus route list
* `GET /companies/<guid>/routes/bus/<guid>` - Get a company bus route
* `GET /companies/<guid>/routes/truck` - Get a company truck route list
* `GET /companies/<guid>/routes/truck/<guid>` - Get a company truck route
* `GET /depots` - Get all depots in-game
* `GET /companies/<guid>/depots` - Now returns a company depot list
* `GET /companies/<guid>/depots/<guid>` - Now returns a company depot
* `POST /players/<id>/money` - Because why not
* `POST /vehicles/<id>/fuel` - Set vehicle fuel
* `POST /vehicles/<id>/parts/<partId>/damage` - Set vehicle part damage

### New commands

* `addmoney` - Add money to player. May trigger `bIsCheater` flag in the save game.
* `teleporttodest` - Teleport to specified player waypoint.

### Support for spawning static mesh

Static mesh now can be spawned using the `POST /assets/spawn` endpoint! Be careful when spawning a large amount of assets as they have longer draw distance from the normal static mesh, which can cause performance hit.

### Minor performance upgrade

C++ object parser now supports larger data type and faster in normal operation mode. The C++ debug log level is now matched with the Lua counterparts.

### Bugfixes

* Fix endpoints wildcard ambiguity
* Fix return code for some endpoints
* Fix character and player filter query parameter not returning intended data
* Fix game crash while trying to add/deduct money from the player
* Fix asset spawner not using and returning the given tag
