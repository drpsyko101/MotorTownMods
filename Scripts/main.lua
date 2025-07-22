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

local function LoadWebserver()
  local status, err = pcall(function()
    local server = require("Webserver")

    -- Local imports are placed here due to socket dependency

    local propertyManager = require("PropertyManager")
    local vehicleManager = require("VehicleManager")
    local assetManager = require("AssetManager")

    -- Note that the ordering of the path registration matters.
    -- Put more specific paths before more general ones

    -- General server status
    server.registerHandler(
      "/status",
      "GET",
      function(session)
        local gameState = GetMotorTownGameState()
        if not gameState:IsValid() then
          -- Game state is not created yet
          return json.stringify { status = "not ready" }, nil, 503
        end
        return json.stringify { status = "ok" }
      end,
      false
    )
    server.registerHandler(
      "/version",
      "GET",
      function(session) return json.stringify { version = statics.ModVersion } end,
      false
    )
    server.registerHandler("/status/general", "GET", serverManager.HandleGetServerState)
    server.registerHandler("/status/general/*", "GET", serverManager.HandleGetZoneState)
    server.registerHandler("/status/traffic", "POST", serverManager.HandleUpdateNpcTraffic)

    -- Player management
    server.registerHandler("/players", "GET", playerManager.HandleGetPlayerStates)
    server.registerHandler("/players/*", "GET", playerManager.HandleGetPlayerStates)

    -- Event management
    server.registerHandler("/events", "GET", eventManager.HandleGetEvents)
    server.registerHandler("/events", "POST", eventManager.HandleCreateNewEvent)
    server.registerHandler("/events/*", "GET", eventManager.HandleGetEvents)
    server.registerHandler("/events/*/state", "POST", eventManager.HandleChangeEventState)
    server.registerHandler("/events/*", "POST", eventManager.HandleUpdateEvent)
    server.registerHandler("/events/*", "DELETE", eventManager.HandleRemoveEvent)

    -- Properties management
    server.registerHandler("/houses", "GET", propertyManager.HandleGetHouses)
    server.registerHandler("/houses/spawn", "POST", propertyManager.HandleSpawnHouse)

    -- Cargo management
    server.registerHandler("/delivery/points", "GET", cargoManager.HandleGetDeliveryPoints)
    server.registerHandler("/delivery/points/*", "GET", cargoManager.HandleGetDeliveryPoints)

    -- Vehicle management
    server.registerHandler("/vehicles", "GET", vehicleManager.HandleGetVehicles)
    server.registerHandler("/vehicles/*/despawn", "POST", vehicleManager.HandleDespawnVehicle)
    server.registerHandler("/vehicles/*", "GET", vehicleManager.HandleGetVehicles)
    server.registerHandler("/dealers/spawn", "POST", vehicleManager.HandleCreateVehicleDealerSpawnPoint)
    server.registerHandler("/garages", "GET", vehicleManager.HandleGetGarages)
    server.registerHandler("/garages/spawn", "POST", vehicleManager.HandleGetGarages)

    -- Asset management
    server.registerHandler("/assets/spawn", "POST", assetManager.HandleSpawnActor)
    server.registerHandler("/assets/despawn", "POST", assetManager.HandleDespawnActor)

    -- UI management
    server.registerHandler("/messages/popup", "POST", widgetManager.HandleShowPopupMessage)
    server.registerHandler("/messages/announce", "POST", chatManager.HandleAnnounceMessage)

    -- Company management
    server.registerHandler("/companies", "GET", companyManager.HandleGetCompanies)

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
