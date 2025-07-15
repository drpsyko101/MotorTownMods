local json = require("JsonParser")
local statics = require("Statics")

local dir = os.getenv("PWD") or io.popen("cd"):read()
local modConfigFilePath = dir .. "/ue4ss/Mods/" .. statics.ModName .. "/config.json"

---@enum HotBarLocation
local hotbarLocation = {
    default = "default",
    center = "center",
}

---The mod config table
---@enum (key) ModConfigKey
local modConfig = {
    showMiniMap = true,
    showQuest = true,
    showDrivingHud = true,
    showControls = true,
    showHotbar = true,
    showPlayerList = true,
    hotbarLocation = "default", ---@type HotBarLocation
    uiScale = 1.0,
    modName = statics.ModName,
    modVersion = statics.ModVersion
}

---Get current mod config
---@param key ModConfigKey? Return a specific mod config value
---@return unknown
local function GetModConfig(key)
    if key then
        if modConfig[key] ~= nil then
            return modConfig[key]
        else
            error(string.format("Mod config does not have %s key", key))
        end
    end
    return modConfig
end

---Save mod config to file
local function SaveModConfig()
    local file, err = io.open(modConfigFilePath, "wb")
    if file then
        local jsonContent = json.stringify(modConfig)
        file:write(jsonContent)
        file:close()
        LogOutput("DEBUG", "Mod config saved to \"%s\"", modConfigFilePath)
    else
        LogOutput("ERROR", "Failed to save mod config to \"%s\": %s", modConfigFilePath, err)
    end
end

---Set mod config key value
---@param key ModConfigKey
---@param value string|number|boolean
local function SetModConfig(key, value)
    if modConfig[key] ~= nil then
        modConfig[key] = value
        SaveModConfig()
    else
        error(string.format("Mod config does not have %s key", key))
    end
end

---Load mod config from disk
---@param force boolean? Force refresh mod configuration from disk
local function LoadModConfig(force)
    local file, err = io.open(modConfigFilePath, "rb")
    if file then
        local rawContent = file:read("a")
        file:close()

        local success, content = pcall(json.parse, rawContent)
        if success and type(content) == "table" then
            -- Merge loaded config with defaults to ensure all keys exist
            for key, defaultValue in pairs(modConfig) do
                if content[key] ~= nil then
                    modConfig[key] = content[key]
                end
            end
            LogOutput("DEBUG", "Mod config loaded from \"%s\"", modConfigFilePath)
        else
            LogOutput("WARN", "Invalid JSON in \"%s\", creating new config", modConfigFilePath)
            SaveModConfig()
        end
    else
        LogOutput("WARN", "Failed to open \"%s\": %s - Creating new config", modConfigFilePath, err)
        SaveModConfig()
    end
end

-- Create the singleton module
local ModConfigInstance = {}

-- Only expose the public functions
ModConfigInstance.GetModConfig = GetModConfig
ModConfigInstance.SetModConfig = SetModConfig

-- Initialize the config on module load
LoadModConfig()

-- Make it a global singleton
if not _G.ModConfig then
    _G.ModConfig = ModConfigInstance
end

return _G.ModConfig
