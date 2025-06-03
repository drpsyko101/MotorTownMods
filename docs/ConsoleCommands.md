# Motor Town Console Commands

List of Motor Town console commands.

## General

* `setnpctraffic <amount>` - Set the current traffic amount. Defaults to `1.0`.

## Player management

* `getplayers` - Returns all player states data

## Event management

* `getevents` - Returns all active events
* `updateeventname <guid> <new name>` - Update an event name by its given GUID

## Vehicle management

* `setvehicleparam <param.param1> <value>` - Set the currently driven vehicle parameter value. Nested variable can be set by using period (i.e. `ControlSettings.bRearSteering`).
