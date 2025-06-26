# Motor Town Mods

Powered by UE4SS lua scripts!

## Usage

### Installation

Download the latest releases [here](https://github.com/drpsyko101/MotorTownMods/releases). Extract its contents to `path/to/ue4ss/Mods/` directory.

### Building from source

1. Clone this repository into your `ue4ss/Mods` directory.

   ```shell
   git -C <path/to/ue4ss/Mods> clone https://github.com/drpsyko101/MotorTownMods.git
   ```

#### (Optional) Lua module

Download and extract [luasocket](https://github.com/alain-riedinger/luasocket/releases/tag/3.1-5.4.7) to `path/to/ue4ss/Mods/shared` directory to use the HTTP server. For webhook functionality, build [Luasec](https://github.com/lunarmodules/luasec) either from source or using [Luarocks](https://luarocks.org/) for Win64. Install [lua-bcrypt](https://github.com/mikejsavage/lua-bcrypt) to enable server API authentication with `bcrypt` hashing algorithm.

#### (Optional) C++ module

These steps are similar to [creating a C++ mod](https://docs.ue4ss.com/dev/guides/creating-a-c++-mod.html) tutorial. Please read them before proceeding for a full understanding of the project structure.

1. Clone the RE-UE4SS into the `ue4ss` directory.

   ```shell
   git -C <path/to/ue4ss> clone --recurse-submodules https://github.com/drpsyko101/RE-UE4SS.git
   ```

2. Create a `xmake.lua` file at `ue4ss/` directory with these contents:

   ```lua
   includes("RE-UE4SS")
   includes("MotorTownMods")
   ```

3. Configure the project with `xmake`:

   ```shell
   xmake f -m "Game__Shipping__Win64" -y
   ```

4. Generate the Visual Studio solution file:

   ```shell
   xmake project -k vsxmake2022 -m "Game__Shipping__Win64" -y
   ```

5. Open the generated solution in `vsxmake2022/*.sln`, and right click on the `mods/MotorTownMods` in the solution explorer and click **Build**.
6. If the build is successfull, copy or create symlink the generated `ue4ss\Binaries\Game__Shipping__Win64\MotorTownMods\MotorTownMods.dll` to `ue4ss/MotorTownMods/dlls/main.dll`.

### Configuration

Most of the server settings can be configured using environment variables:

| Variable name         | Default value | Description                                                          |
| --------------------- | ------------- | -------------------------------------------------------------------- |
| `MOD_MANAGEMENT_PORT` | `5000`        | Management port. Used for managing mods in the dedicated server      |
| `MOD_LUA_PORT`        | `5001`        | Lua HTTP port. This only applies if `luasocket` module is installed  |
| `MOD_WEBHOOK_URL`     | _none_        | Webhook URL to send the events to. Requires `luasec` to function     |
| `MOD_SERVER_API_URL`  | _none_        | Server API to call from client side                                  |
| `MOD_SERVER_PASSWORD` | _none_        | Authenticate server request with `Authorization: Basic ` header      |
| `MOD_AUTO_FPS_ENABLE` | _none_        | Enable automatic server traffic adjustment based on the server's FPS |

## Documentation

More detailed instructions can be found in the [docs](./docs).

## Contributing

More contributions are welcomed! Read how to contribute [here](./docs/CONTRIBUTING.md).
