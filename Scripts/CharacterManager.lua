local cargo = require("CargoManager")
local json = require("JsonParser")
local player = require("PlayerManager")

---Convert item inventory slot to table
---@param item FMTItemInventorySlot
local function ItemInventorySlotToTable(item)
  return {
    Key = item.Key:ToString(),
    NumStack = item.NumStack
  }
end

---Convert passenger component to JSON serializable table
---@param comp UMTPassengerComponent
local function PassengerComponentToTable(comp)
  local data = {}

  if not comp:IsValid() then return json.null end

  -- data.Net_PassengerType = comp.Net_PassengerType
  -- data.Net_BusPassengerParams = comp.Net_BusPassengerParams
  data.Net_StartLocation = VectorToTable(comp.Net_StartLocation)
  data.Net_DestinationLocation = VectorToTable(comp.Net_DestinationLocation)
  data.Net_Distance = comp.Net_Distance
  data.Net_Payment = comp.Net_Payment
  data.Net_PaymentPer100m = comp.Net_PaymentPer100m
  data.Net_PassengerFlags = comp.Net_PassengerFlags
  data.Net_bArrived = comp.Net_bArrived
  -- data.Net_GroupCharacters = comp.Net_GroupCharacters
  -- data.InteractionMeshComponent = comp.InteractionMeshComponent
  -- data.InteractionComponent = comp.InteractionComponent
  data.DestinationActor = comp.DestinationActor:IsValid() and comp.DestinationActor:GetFullName() or json.null
  -- data.PassengerMarker = comp.PassengerMarker
  -- data.DialogueComponent = comp.DialogueComponent
  -- data.DialogueInteractionComponent = comp.DialogueInteractionComponent
  data.Net_ReservedPlayerState = comp.Net_ReservedPlayerState:IsValid() and
      player.PlayerStateToTable(comp.Net_ReservedPlayerState) or json.null
  data.Net_TimeLimitToDestinationFromStart = comp.Net_TimeLimitToDestinationFromStart
  data.Net_TimeLimitToDestination = comp.Net_TimeLimitToDestination
  data.Net_TimeLimitPoint = comp.Net_TimeLimitPoint
  data.Net_LCComfortSatisfaction = comp.Net_LCComfortSatisfaction

  return data
end

---Convert character to JSON serializable table
---@param character AMTCharacter
local function CharacterToTable(character)
  if not character:IsValid() then return json.null end

  local data = {}

  -- data.AbilityComponent = character.AbilityComponent
  -- data.CameraBoom = character.CameraBoom
  -- data.FollowCamera = character.FollowCamera
  -- data.VoiceLineData = character.VoiceLineData
  -- data.InteractionMontages = character.InteractionMontages
  -- data.InteractionFailMontage = character.InteractionFailMontage
  -- data.FirstPersonCamera = character.FirstPersonCamera
  data.Passenger = PassengerComponentToTable(character.Passenger)
  data.Net_GroupPassenger = PassengerComponentToTable(character.Net_GroupPassenger)
  data.BaseTurnRate = character.BaseTurnRate
  data.BaseLookUpRate = character.BaseLookUpRate
  data.Net_Customization = {
    BodyKey = character.Net_Customization.BodyKey:ToString(),
    CostumeBodyKey = character.Net_Customization.CostumeBodyKey:ToString(),
    CostumeItemKey = character.Net_Customization.CostumeItemKey:ToString()
  }
  data.Net_ResidentKey = character.Net_ResidentKey:ToString()
  data.MapIconName = character.MapIconName:ToString()
  -- data.LC_InteractionTarget = character.LC_InteractionTarget
  data.Net_Cargo = character.Net_Cargo:IsValid() and cargo.CargoToTable(character.Net_Cargo) or json.null
  data.Net_HoldingItem = {
    Actor = character.Net_HoldingItem.Actor:IsValid() and character.Net_HoldingItem.Actor:GetFullName() or json.null,
    ItemKey = character.Net_HoldingItem.ItemKey:ToString(),
    QuickSlotIndex = character.Net_HoldingItem.QuickSlotIndex
  }
  data.Net_SeatPositionType = character.Net_SeatPositionType
  -- data.Net_Seat = character.Net_Seat
  -- data.Net_Pose = character.Net_Pose
  data.Net_PoseFlags = character.Net_PoseFlags
  data.Net_CharacterFlags = character.Net_CharacterFlags
  -- data.Net_Buff2 = character.Net_Buff2
  data.GameplayTagContainer = GameplayTagContainerToString(character.GameplayTagContainer)
  data.Net_MTPlayerState = character.Net_MTPlayerState:IsValid() and
      player.PlayerStateToTable(character.Net_MTPlayerState) or json.null
  data.Net_LookRotation = RotatorToTable(character.Net_LookRotation)
  data.Net_bSprint = character.Net_bSprint

  return data
end

-- Handle HTTP requests

---Get all characters currently in-game
local function HandleGetCharacters()
  local data = {}
  local gameState = GetMotorTownGameState()
  if gameState:IsValid() then
    for i = 1, #gameState.Characters, 1 do
      table.insert(data, CharacterToTable(gameState.Characters[i]))
    end
  end
  return json.stringify { data = data }
end

return {
  ItemInventorySlotToTable = ItemInventorySlotToTable,
  HandleGetCharacters = HandleGetCharacters
}
