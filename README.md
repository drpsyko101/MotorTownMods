# Motor Town Mods

Powered by UE4SS lua scripts!

## Usage

### Installation

1. Clone this repository into your `ue4ss/Mods` directory.

   ```shell
   git -C <path/to/ue4ss/Mods> clone https://github.com/drpsyko101/MotorTownMods.git
   ```

2. _(Optional)_ Download and extract [luasocket](https://github.com/alain-riedinger/luasocket/releases/tag/3.1-5.4.7) to `path/to/ue4ss/Mods/shared` directory to use the HTTP server
2. Launch your game!

### Configuration

Most of the settings can be configured using environment variables:

| Variable name          | Default value | Description                                                          |
| ---------------------- | ------------- | -------------------------------------------------------------------- |
| `MOD_LUA_PORT`         | `5001`        | Lua HTTP port. This only applies if `luasocket` module is installed  |
| `MOD_WEBHOOK_URL`      | _none_        | Webhook URL to send the events to. Requires `luasocket` to function  |
| `MOD_AUTO_FPS_ENABLE`  | _none_        | Enable automatic server traffic adjustment based on the server's FPS |
| `MOD_AUTO_FPS_TRAFFIC` | `75`          | Amount of base traffic in percentage                                 |
| `MOD_AUTO_FPS_PLAYER`  | `10`          | Maximum amount of vehicle spawnable by the player                    |

## Documentation

More detailed instructions can be found in the [docs](./docs). 
