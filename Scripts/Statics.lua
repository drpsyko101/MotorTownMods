local outputLogLevel = tonumber(os.getenv("MOD_SERVER_LOG_LEVEL")) or 2

return {
    ModName = "MotorTownMods",
    ModVersion = "0.0.0",
    ModLogLevel = outputLogLevel,
}
