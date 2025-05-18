# Motor Town Mods

Powered by UE4SS lua scripts!

## Instructions

1. Download RE-UE4SS from the [releases](https://github.com/UE4SS-RE/RE-UE4SS/releases) page. Using the `experimental-latest` branch is highly recommended. Follow the [full installation guide](https://docs.ue4ss.com/dev/installation-guide.html) for more in-depth steps.
2. Clone this repository into your `ue4ss/Mods` directory.

   ```shell
   git -C <path/to/ue4ss/Mods> clone https://github.com/drpsyko101/MotorTownMods.git
   ```

Both Lua and C++ mods are included in this repository. For Lua mods, it is enabled by default at launch. C++ mods require additional build steps.

### C++

These steps are similar to [creating a C++ mod](https://docs.ue4ss.com/dev/guides/creating-a-c++-mod.html) tutorial. Please read them before proceeding for a full understanding of the project structure.

1. Clone the RE-UE4SS into the `ue4ss` directory.

   ```shell
   git -C <path/to/ue4ss> clone --recurse-submodules https://github.com/UE4SS-RE/RE-UE4SS.git
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

5. Open the solution, and right click on the `mods/MotorTownMods` in the solution explorer and click **Build**.
6. If the build is successfull, copy or create symlink the generated `ue4ss\Binaries\Game__Shipping__Win64\MotorTownMods\MotorTownMods.dll` to `ue4ss/MotorTownMods/dlls/main.dll`.
