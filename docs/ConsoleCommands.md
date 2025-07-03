# Motor Town Console Commands

List of Motor Town console commands.

## General

* `stopwebserver` - Stop the webserver. Useful for restarting Lua mods.
* `setnpctraffic <amount>` - Set the current traffic amount. Defaults to `1.0`.

## Player management

* `getplayers` - Returns all player states data

## Event management

* `getevents` - Returns all active events
* `updateeventname <guid> <new name>` - Update an event name by its given GUID

## Vehicle management

* `setvehicleparam <param.param1> <value>` - Set the currently driven vehicle parameter value. Nested variable can be set by using period (i.e. `ControlSettings.bRearSteering`).

## Asset management

* `spawnactor <assetPath> <0,0,0> <0,0,0>` - Spawn an actor given the asset path, along with optional location and rotation value. If not given any location and rotation, it will use the camera crosshair to spawn at location. Note that some of the blueprint actors require hard reference to other actors.
* `destroyactor <assetTag>` - Destroy an actor with tag. Use with caution. This action will delete all actors with the same tag. Might break the game if deleted core actors with the same tag.
