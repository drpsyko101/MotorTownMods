local dir = os.getenv("PWD") or io.popen("cd"):read()
package.cpath = package.cpath .. ";" .. dir .. "/ue4ss/Mods/shared/?/core.dll"
package.cpath = package.cpath .. ";" .. dir .. "/ue4ss/Mods/shared/?.dll"

require("Helpers")
local json = require("JsonParser")
local logging = require("Debugging/Logging")
local statics = require("Statics")

---@deprecated Use LogOutput instead to avoid concat errors
LogMsg = logging.logMsg
LogOutput = logging.logOutput

local playerManager = require("PlayerManager")
local eventManager = require("EventManager")
local serverManager = require("ServerManager")
local cargoManager = require("CargoManager")
local chatManager = require("ChatManager")
local widgetManager = require("ViewportManager")
local companyManager = require("CompanyManager")
local characterManager = require("CharacterManager")
local propertyManager = require("PropertyManager")
local vehicleManager = require("VehicleManager")
local assetManager = require("AssetManager")

local function LoadWebserver()
  local status, err = pcall(function()
    local server = require("Webserver")

    -- General server status
    server.registerHandler("/status", "GET", serverManager.HandleGetServerStatus, false)
    server.registerHandler("/status/general", "GET", serverManager.HandleGetServerState)
    server.registerHandler("/status/general/*", "GET", serverManager.HandleGetZoneState)
    server.registerHandler("/settings/traffic", "GET", serverManager.HandleGetNpcTraffic)
    server.registerHandler("/settings/traffic", "POST", serverManager.HandleUpdateNpcTraffic)
    server.registerHandler("/settings", "PATCH", serverManager.HandleSetServerSettings)
    server.registerHandler("/command", "POST", serverManager.HandleServerExecCommand)

    -- Player management
    server.registerHandler("/players", "GET", playerManager.HandleGetPlayerStates)
    server.registerHandler("/players/*/teleport", "POST", playerManager.HandleTeleportPlayer)
    server.registerHandler("/players/*/money", "POST", playerManager.HandleAddMoney)
    server.registerHandler("/players/*/gameplay/effects", "DELETE", playerManager.HandleRemoveGameplayEffect)
    server.registerHandler("/players/*", "GET", playerManager.HandleGetPlayerStates)

    -- Event management
    server.registerHandler("/events", "GET", eventManager.HandleGetEvents)
    server.registerHandler("/events", "POST", eventManager.HandleCreateNewEvent)
    server.registerHandler("/events/*", "GET", eventManager.HandleGetEvents)
    server.registerHandler("/events/*/state", "POST", eventManager.HandleChangeEventState)
    server.registerHandler("/events/*/players", "POST", eventManager.HandlePlayerJoinEvent)
    server.registerHandler("/events/*/players", "DELETE", eventManager.HandlePlayerLeaveEvent)
    server.registerHandler("/events/*", "PATCH", eventManager.HandleUpdateEvent)
    server.registerHandler("/events/*", "DELETE", eventManager.HandleRemoveEvent)

    -- Properties management
    server.registerHandler("/houses", "GET", propertyManager.HandleGetHouses)
    server.registerHandler("/houses/*", "GET", propertyManager.HandleGetHouses)
    server.registerHandler("/houses/spawn", "POST", propertyManager.HandleSpawnHouse)

    -- Cargo management
    server.registerHandler("/delivery/points", "GET", cargoManager.HandleGetDeliveryPoints)
    server.registerHandler("/delivery/points/*", "GET", cargoManager.HandleGetDeliveryPoints)
    server.registerHandler("/delivery", "GET", cargoManager.HandleGetDeliveries)
    server.registerHandler("/delivery/*", "GET", cargoManager.HandleGetDeliveries)

    -- Vehicle management
    server.registerHandler("/vehicles", "GET", vehicleManager.HandleGetVehicles)
    server.registerHandler("/vehicles", "PATCH", vehicleManager.HandleSetVehicleParameter)
    server.registerHandler("/vehicles/*/despawn", "POST", vehicleManager.HandleDespawnVehicle)
    server.registerHandler("/vehicles/*", "GET", vehicleManager.HandleGetVehicles)
    server.registerHandler("/vehicles/*", "PATCH", vehicleManager.HandleSetVehicleParameter)
    server.registerHandler("/dealers/spawn", "POST", vehicleManager.HandleCreateVehicleDealerSpawnPoint)
    server.registerHandler("/garages", "GET", vehicleManager.HandleGetGarages)
    server.registerHandler("/garages/spawn", "POST", vehicleManager.HandleSpawnGarage)

    -- Asset management
    server.registerHandler("/assets/spawn", "POST", assetManager.HandleSpawnActor)
    server.registerHandler("/assets/despawn", "POST", assetManager.HandleDespawnActor)

    -- UI management
    server.registerHandler("/messages/popup", "POST", widgetManager.HandleShowPopupMessage)
    server.registerHandler("/messages/announce", "POST", chatManager.HandleAnnounceMessage)

    -- Company management
    server.registerHandler("/companies", "GET", companyManager.HandleGetCompanies)
    server.registerHandler("/companies/*/vehicles", "GET", companyManager.HandleGetCompanyVehicles)
    server.registerHandler("/companies/*/routes/bus", "GET", companyManager.HandleGetCompanyBusRoutes)
    server.registerHandler("/companies/*/routes/bus/*", "GET", companyManager.HandleGetCompanyBusRoutes)
    server.registerHandler("/companies/*/routes/truck", "GET", companyManager.HandleGetCompanyTruckRoutes)
    server.registerHandler("/companies/*/routes/truck/*", "GET", companyManager.HandleGetCompanyTruckRoutes)
    server.registerHandler("/companies/*/depots", "GET", companyManager.HandleGetCompanyDepots)
    server.registerHandler("/companies/*/depots/*", "GET", companyManager.HandleGetCompanyDepots)
    server.registerHandler("/companies/*", "GET", companyManager.HandleGetCompanies)
    server.registerHandler("/depots", "GET", companyManager.HandleGetDepots)

    -- Character management
    server.registerHandler("/characters", "GET", characterManager.HandleGetCharacters)

    server.run("*")
    return nil
  end)
  if not status then
    LogOutput("ERROR", "Webserver stopped unexpectedly due to error: %s", err)
  end
end

LoadWebserver()
LogOutput("INFO", "Mod loaded")
