local vehicleManager = require("VehicleManager")
local character = require("CharacterManager")
local json = require("JsonParser")

---Convert company role to JSON serializable table
---@param role FMTCompanyPlayerRole
local function CompanyPlayerRoleToTable(role)
  return {
    Name = role.Name:ToString(),
    RoleGuid = GuidToString(role.RoleGuid),
    bIsDefaultRole = role.bIsDefaultRole,
    bIsManager = role.bIsManager,
    bIsOwner = role.bIsOwner
  }
end

---Convert company player to JSON serializable table
---@param player FMTCompanyPlayer
local function CompanyPlayerToTable(player)
  return {
    CharacterId = CharacterIdToTable(player.CharacterId),
    CharacterName = player.CharacterName:ToString(),
    RoleGuid = GuidToString(player.RoleGuid),
  }
end

---Converts company join request to JSON serializable table
---@param request FMTCompanyJoinRequest
local function CompanyJoinRequestToTable(request)
  return {
    CharacterId = CharacterIdToTable(request.CharacterId),
    CharacterName = request.CharacterName:ToString()
  }
end

---Converty company vehicle stat to JSON serializable table
---@param stat FMTCompanyVehicleStat
local function CompanyVehicleStatToTable(stat)
  local data = {}

  data.TotalCost = stat.TotalCost
  data.TotalIncome = stat.TotalIncome
  data.CargoStats = {}
  stat.CargoStats:ForEach(function(index, element)
    local cargo = element:get() ---@type FMTCompanyVehicleCargoStat
    table.insert(data.CargoStats, {
      CargoKey = cargo.CargoKey:ToString(),
      NumCargo = cargo.NumCargo,
      Payments = cargo.Payments,
      Weights = cargo.Weights
    })
  end)

  return data
end

---Convert company vehicle to JSON serializable table
---@param vehicle FMTCompanyVehicle
local function CompanyVehicleToTable(vehicle)
  local data = {}
  data.VehicleId = vehicle.VehicleId
  data.DonatorVehicleId = vehicle.DonatorVehicleId
  data.VehicleKey = vehicle.VehicleKey:ToString()

  data.Setting = {
    RouteGuid = GuidToString(vehicle.Setting.RouteGuid),
    VehicleName = vehicle.Setting.VehicleName:ToString()
  }

  data.RoutePointIndex = vehicle.RoutePointIndex
  data.TotalRunningCost = vehicle.TotalRunningCost
  data.TotalProfitShare = vehicle.TotalProfitShare

  data.DailyStats = {}
  vehicle.DailyStats:ForEach(function(index, element)
    table.insert(data.DailyStats, CompanyVehicleStatToTable(element:get()))
  end)

  data.VehicleState = vehicle.VehicleState
  data.ProblemText = vehicle.ProblemText:ToString()
  data.VehicleFlags = vehicle.VehicleFlags
  data.UserCharacterId = CharacterIdToTable(vehicle.UserCharacterId)
  data.LastUserCharacterId = CharacterIdToTable(vehicle.LastUserCharacterId)
  data.VehicleActor = vehicle.VehicleActor:IsValid() and vehicleManager.VehicleToTable(vehicle.VehicleActor) or json
      .null
  return data
end

---Convert vehicle owner setting to JSON serializable table
---@param setting FMTVehicleOwnerSetting
local function VehicleOwnerSettingToTable(setting)
  local data = {}

  data.bLocked = setting.bLocked
  data.DriveAllowedPlayers = setting.DriveAllowedPlayers

  data.LevelRequirementsToDrive = {}
  setting.LevelRequirementsToDrive:ForEach(function(index, element)
    table.insert(data.LevelRequirementsToDrive, element:get())
  end)

  data.VehicleOwnerProfitShare = setting.VehicleOwnerProfitShare
  return data
end

---Convert player data vehicle to JSON serializable table
---@param vehicleData FMTPlayerDataVehicle
local function PlayerDataVehicleToTable(vehicleData)
  local data = {}

  data.ID = vehicleData.ID
  data.Key = vehicleData.Key:ToString()
  data.VehicleName = vehicleData.VehicleName:ToString()
  data.Condition = vehicleData.Condition
  data.Fuel = vehicleData.Fuel
  data.Customization = vehicleManager.VehicleCustomizationToTable(vehicleData.Customization)
  data.Decal = vehicleManager.VehicleDecalToTable(vehicleData.Decal)
  data.TraveledDistanceKm = vehicleData.TraveledDistanceKm

  data.SeatPosition = {
    ForwardPosition = vehicleData.SeatPosition.ForwardPosition,
    Height = vehicleData.SeatPosition.Height,
    SteeringWheelDistance = vehicleData.SeatPosition.SteeringWheelDistance,
    SteeringWheelHeight = vehicleData.SeatPosition.SteeringWheelHeight
  }

  data.MirrorPositions = { MirrorPositions = {} }
  vehicleData.MirrorPositions.MirrorPositions:ForEach(function(index, element)
    table.insert(data.MirrorPositions.MirrorPositions, vehicleManager.VehicleMirrorPositionToTable(element:get()))
  end)

  data.OwnerSetting = VehicleOwnerSettingToTable(vehicleData.OwnerSetting)

  data.VehicleSettings = {}
  vehicleData.VehicleSettings:ForEach(function(index, element)
    table.insert(data.VehicleSettings, vehicleManager.VehicleSettingToTable(element:get()))
  end)

  data.bIsModded = vehicleData.bIsModded
  data.VehicleTags = {}
  vehicleData.VehicleTags:ForEach(function(index, element)
    table.insert(data.VehicleTags, element:get():ToString())
  end)

  return data
end

---COnvert company own vehicle world data to JSON serializable table
---@param worldData FMTCompanyOwnVehicleWorldData
local function CompanyOwnVehicleWorldDataToTable(worldData)
  local data = {}

  data.VehicleId = worldData.VehicleId
  data.CargoSpaces = {}
  worldData.CargoSpaces:ForEach(function(index, element)
    local space = element:get() ---@type FMTPlayerDataCargoSpace
    table.insert(data.CargoSpaces, {
      CargoSpaceIndex = space.CargoSpaceIndex,
      LoadedItemType = space.LoadedItemType,
      LoadedItemVolume = space.LoadedItemVolume
    })
  end)

  return data
end

---Convert player data vehicle part to table
---@param part FMTPlayerDataVehiclePart
local function PlayerDataVehiclePartToTable(part)
  local data = {}

  data.ID = part.ID
  data.Key = part.Key:ToString()
  data.Slot = part.Slot
  data.InstalledVehicleId = part.InstalledVehicleId
  data.Damage = part.Damage

  data.FloatValues = {}
  part.FloatValues:ForEach(function(index, element)
    table.insert(data.FloatValues, element:get())
  end)

  data.Int64Values = {}
  part.Int64Values:ForEach(function(index, element)
    table.insert(data.Int64Values, element:get())
  end)

  data.StringValues = {}
  part.StringValues:ForEach(function(index, element)
    table.insert(data.StringValues, element:get():ToString())
  end)

  data.VectorValues = {}
  part.VectorValues:ForEach(function(index, element)
    table.insert(data.VectorValues, VectorToTable(element:get()))
  end)

  data.ItemInventory = { Slots = {} }
  part.ItemInventory.Slots:ForEach(function(index, element)
    table.insert(data.ItemInventory.Slots, character.ItemInventorySlotToTable(element:get()))
  end)

  return data
end

---Convert company bus route to table
---@param route FMTCompanyBusRoute
local function CompanyBusRouteToTable(route)
  local data = {}

  data.Guid = GuidToString(route.Guid)
  data.RouteName = route.RouteName:ToString()

  data.Points = {}
  route.Points:ForEach(function(index, element)
    local point = element:get() ---@type FMTCompanyBusRoutePoint
    table.insert(data.Points, {
      PointGuid = GuidToString(point.PointGuid),
      RouteFlags = point.RouteFlags
    })
  end)

  return data
end

---Convert company truck route to table
---@param route FMTCompanyTruckRoute
local function CompanyTruckRouteToTable(route)
  local data = {}
  data.Guid = GuidToString(route.Guid)
  data.RouteName = route.RouteName:ToString()
  data.DeliveryPoints = {}
  route.DeliveryPoints:ForEach(function(index, element)
    local point = element:get() ---@type FMTCompanyTruckRoutePoint
    table.insert(data.DeliveryPoints, {
      PointGuid = GuidToString(point.PointGuid),
      RouteFlags = point.RouteFlags
    })
  end)
  return data
end

---Convert contract to JSON serializable table
---@param contract FMTContract
local function ContractToTable(contract)
  return {
    ContractType = contract.ContractType,
    Contractor = contract.Contractor:ToString(),
    Item = contract.Item:ToString(),
    Amount = contract.Amount,
    DurationSeconds = contract.DurationSeconds,
    Cost = RewardToTable(contract.Cost),
    BonusPaymentRate = contract.BonusPaymentRate,
    CompletionPayment = RewardToTable(contract.CompletionPayment),
  }
end

---Convert contract in progress to JSON serializable table
---@param contract FMTContractInProgress
local function ContractInProgressToTable(contract)
  return {
    Guid = GuidToString(contract.Guid),
    Contract = ContractToTable(contract.Contract),
    TimeLeftSeconds = contract.TimeLeftSeconds,
    FinishedAmount = contract.FinishedAmount,
  }
end

---Convert company to JSON serializable table
---@param company FMTCompany
local function CompanyToTable(company)
  local data = {}

  data.Guid = GuidToString(company.Guid)
  data.bDeactivated = company.bDeactivated
  data.bIsCorporation = company.bIsCorporation
  data.Money = RewardToTable(company.Money)

  data.Settings = {
    Name = company.Settings.Name:ToString(),
    ShortDesc = company.Settings.ShortDesc:ToString()
  }

  data.OwnerCharacterId = CharacterIdToTable(company.OwnerCharacterId)
  data.OwnerCharacterName = company.OwnerCharacterName:ToString()
  data.AddedVehicleSlots = company.AddedVehicleSlots

  data.Roles = {}
  company.Roles:ForEach(function(index, element)
    table.insert(data.Roles, CompanyPlayerRoleToTable(element:get()))
  end)

  data.Players = {}
  company.Players:ForEach(function(index, element)
    table.insert(data.Players, CompanyPlayerToTable(element:get()))
  end)

  data.JoinRequests = {}
  company.JoinRequests:ForEach(function(index, element)
    table.insert(data.JoinRequests, CompanyJoinRequestToTable(element:get()))
  end)

  data.Vehicles = {}
  company.Vehicles:ForEach(function(index, element)
    table.insert(data.Vehicles, CompanyVehicleToTable(element:get()))
  end)

  data.OwnVehicles = {}
  company.OwnVehicles:ForEach(function(index, element)
    table.insert(data.OwnVehicles, PlayerDataVehicleToTable(element:get()))
  end)

  data.OwnVehicleWorldData = {}
  company.OwnVehicleWorldData:ForEach(function(index, element)
    table.insert(data.OwnVehicleWorldData, CompanyOwnVehicleWorldDataToTable(element:get()))
  end)

  data.OwnVehicleParts = {}
  company.OwnVehicleParts:ForEach(function(index, element)
    table.insert(data.OwnVehicleParts, PlayerDataVehiclePartToTable(element:get()))
  end)

  data.BusRoutes = {}
  company.BusRoutes:ForEach(function(index, element)
    table.insert(data.BusRoutes, CompanyBusRouteToTable(element:get()))
  end)

  data.TruckRoutes = {}
  company.TruckRoutes:ForEach(function(index, element)
    table.insert(data.TruckRoutes, CompanyTruckRouteToTable(element:get()))
  end)

  data.MoneyTransactions = {}
  company.MoneyTransactions:ForEach(function(index, element)
    local transact = element:get() ---@type FMTCompanyMoneyTransaction
    table.insert(data.MoneyTransactions, {
      Money = transact.Money,
      TransactionType = transact.TransactionType,
      CharacterId = CharacterIdToTable(transact.CharacterId),
      PlayerName = transact.PlayerName:ToString(),
      VehicleId = transact.VehicleId
    })
  end)

  data.ContractsInProgress = {}
  company.ContractsInProgress:ForEach(function(index, element)
    table.insert(data.ContractsInProgress, ContractInProgressToTable(element:get()))
  end)

  data.OwnerPC = company.OwnerPC:IsValid() and GetPlayerUniqueId(company.OwnerPC) or json.null
  data.PendingRunningCost = company.PendingRunningCost
  data.BusProfitShareToApply = company.BusProfitShareToApply
  data.TruckProfitShareToApply = company.TruckProfitShareToApply
  data.IdleDurationSeconds = company.IdleDurationSeconds

  return data
end

---Get all companies or selected company by given GUID
---@param id string?
---@param filter string[]?
---@param limit integer?
local function GetCompanies(id, filter, limit)
  local data = {}

  local gameState = GetMotorTownGameState()
  if gameState:IsValid() then
    local comp = gameState.Net_CompanySystem
    if comp:IsValid() then
      for i = 1, #comp.Server_Companies, 1 do
        if limit and limit <= #data then
          break
        end

        if id and id:upper() ~= GuidToString(comp.Server_Companies[i].Guid) then
          goto continue
        end

        local company = CompanyToTable(comp.Server_Companies[i])

        if filter then
          for index, value in ipairs(filter) do
            if company[value] == nil then
              error(string.format("Company key %s is invalid", value))
            end

            local filtered = {}
            filtered[value] = company[value]
            filtered.Guid = company.Guid -- always return guid

            table.insert(data, filtered)
          end
        else
          table.insert(data, company)
        end

        :: continue ::
      end
    end
  end
  return data
end

-- Handle HTTP requests

---Handle request to get all or specific company
---@type RequestPathHandler
local function HandleGetCompanies(session)
  local companyGuid = session.pathComponents[2]
  local filters = SplitString(session.queryComponents.filters)
  local limit = tonumber(session.queryComponents.limit)

  local company = GetCompanies(companyGuid, filters, limit)

  if companyGuid and #company == 0 then
    return json.stringify { message = string.format("Company with %s GUID not found", companyGuid) }, nil, 404
  end

  return json.stringify { data = company }
end

return {
  HandleGetCompanies = HandleGetCompanies
}
