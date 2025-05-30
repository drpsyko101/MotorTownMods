local UEHelpers = require("UEHelpers")

---Spawn an actor at a specific location
---@param assetPath string
---@param transform FTransform
local function SpawnAssetAtLocation(assetPath, transform)
  local world = UEHelpers:GetWorld()
  world:SpawnActor()

  ExecuteInGameThread(function()
    LoadAsset()
  end)
  return false
end
