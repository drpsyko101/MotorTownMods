local UEHelpers = require("UEHelpers")
local webhook = require("Webclient")
local json = require("JsonParser")
local cargo = require("CargoManager")

---Convert FMTVehicleColorSlot to JSON serializable table
---@param slot FMTVehicleColorSlot
local function ColorSlotToTable(slot)
  return {
    DefaultColor = ColorToTable(slot.DefaultColor),
    DisplayName = slot.DisplayName:ToString(),
    bUseColorAlpha = slot.bUseColorAlpha
  }
end

---Convert FMTVehicleColor to JSON serializable table
---@param color FMTVehicleColor
local function VehicleColorToTable(color)
  local data = {}

  data.Colors = {}
  color.Colors:ForEach(function(key, value)
    data.Colors[key:get():ToString()] = ColorToTable(value:get())
  end)

  return data
end

---Convert FMTVehicleColorSlot to JSON serializable table
---@param slot FMTVehicleColorSlot
local function VehicleColorSlotToTable(slot)
  return {
    DefaultColor = ColorToTable(slot.DefaultColor),
    DisplayName = slot.DisplayName:ToString(),
    bUseColorAlpha = slot.bUseColorAlpha
  }
end

---Convert FMTVehiclePartIntake to JSON serializable table
---@param intake FMTVehiclePartIntake
local function VehicleIntakeToTable(intake)
  return {
    BaseRPMRatio = intake.BaseRPMRatio,
    IntakeSpeedEfficencyMultiplier = intake.IntakeSpeedEfficencyMultiplier,
    Slope = intake.Slope
  }
end

---Converts FMTVehiclePartTurbocharger to JSON serializable table
---@param turbo FMTVehiclePartTurbocharger
local function VehicleTurboToTable(turbo)
  local data = {}

  data.bIsValid = turbo.bIsValid
  data.BaseTorqueMultiplier = turbo.BaseTorqueMultiplier
  data.TorqueMultiplier = turbo.TorqueMultiplier
  data.TurbineAspectRatio = turbo.TurbineAspectRatio
  data.IntakePressureMultiplier = turbo.IntakePressureMultiplier
  data.HeatingMultiplier = turbo.HeatingMultiplier
  data.FuelConsumptionMultiplier = turbo.FuelConsumptionMultiplier
  data.TurbineWeight = turbo.TurbineWeight

  return data
end

---Converts FMTTirePhysicsParams to JSON serializable table
---@param tire FMTTirePhysicsParams
local function TirePhysicsToTable(tire)
  return {
    PatchLengthCoefficient = tire.PatchLengthCoefficient,
    StaticMu = tire.StaticMu,
    SlidingMu = tire.SlidingMu,
    SpringX = tire.SpringX,
    SpringY = tire.SpringY,
    DampingX = tire.DampingX,
    DampingY = tire.DampingY,
    CoolDownSpeed = tire.CoolDownSpeed,
    WarmUpSpeed = tire.WarmUpSpeed,
    WearRate = tire.WearRate,
    SmokeRate = tire.SmokeRate,
    MaxWeightKg = tire.MaxWeightKg,
    BrushCount = tire.BrushCount,
    OffroadFriction = tire.OffroadFriction,
    RollingResistanceCoeff = tire.RollingResistanceCoeff,
    RollingResistanceCoeffV1 = tire.RollingResistanceCoeffV1,
  }
end

---Converts FMTVehiclePartTire to JSON serializable table
---@param tire FMTVehiclePartTire
local function VehicleTireToTable(tire)
  return {
    TirePhysicsDataAsset = {
      TirePhysicsParams = TirePhysicsToTable(tire.TirePhysicsDataAsset.TirePhysicsParams)
    },
    TirePhysicsDataAsset_BikeRear = {
      TirePhysicsParams = TirePhysicsToTable(tire.TirePhysicsDataAsset_BikeRear.TirePhysicsParams)
    },
    bIsDualRearWheel = tire.bIsDualRearWheel
  }
end

---Converts FMTVehiclePartAero to JSON serializable table
---@param aero FMTVehiclePartAero
local function VehicleAeroToTable(aero)
  local data = {}

  -- data.Mesh = aero.Mesh
  -- data.SkelealMesh = aero.SkelealMesh
  data.bUseCustomSocket = aero.bUseCustomSocket
  data.CustomSocketName = aero.CustomSocketName:ToString()
  data.ComponentTags = {}
  aero.ComponentTags:ForEach(function(index, element)
    table.insert(data.ComponentTags, element:get():ToString())
  end)

  return data
end

---Converts FMTVehiclePartCargoBed to JSON serializable table
---@param cargo FMTVehiclePartCargoBed
local function VehicleCargoBedToTable(cargo)
  return {
    CargoSpaceLocation = VectorToTable(cargo.CargoSpaceLocation),
    CargoSpaceSize = VectorToTable(cargo.CargoSpaceSize),
    CargoSpaceType = cargo.CargoSpaceType,
    bFixCargo = cargo.bFixCargo,
    bUnlimitedHeight = cargo.bUnlimitedHeight,
    DumpVolume = cargo.DumpVolume,
  }
end

---Converts FMTVehiclePartBrakePad to JSON serializable table
---@param brake FMTVehiclePartBrakePad
local function VehicleBrakePadToTable(brake)
  return {
    HeatingMultiplier = brake.HeatingMultiplier,
    CoolingMultiplier = brake.CoolingMultiplier,
    FadeTemperature = brake.FadeTemperature,
    WearMultiplier = brake.WearMultiplier,
  }
end

---Convert FVehiclePartRow to JSON serializable table
---@param row FVehiclePartRow
local function VehiclePartRowToTable(row)
  local data = {}

  data.Name = row.Name:ToString()

  data.Name2 = {}
  data.Name2.Texts = {}
  row.Name2.Texts:ForEach(function(index, element)
    table.insert(data.Name2.Texts, element:get():ToString())
  end)

  data.Desciption = row.Desciption:ToString()
  data.Cost = row.Cost
  data.bIsHidden = row.bIsHidden
  data.MassKg = row.MassKg
  data.AirDragMultiplier = row.AirDragMultiplier
  data.TrailerAirDragMultiplier = row.TrailerAirDragMultiplier
  data.AeroLift = row.AeroLift
  data.FrontAeroLift = row.FrontAeroLift
  data.RearAeroLift = row.RearAeroLift
  data.FrontDamageMultiplier = row.FrontDamageMultiplier
  data.PartType = row.PartType
  data.GameplayTags = GameplayTagContainerToString(row.GameplayTags)

  data.VehicleTypes = {} ---@type number[]
  row.VehicleTypes:ForEach(function(index, element)
    table.insert(data.VehicleTypes, element:get())
  end)

  data.TruckClasses = {} ---@type number[]
  row.TruckClasses:ForEach(function(index, element)
    table.insert(data.TruckClasses, element:get())
  end)

  data.VehicleRowGameplayTagQuery = GameplayTagQueryToTable(row.VehicleRowGameplayTagQuery)

  data.LevelRequirementToBuy = {}
  row.LevelRequirementToBuy:ForEach(function(key, value)
    data.LevelRequirementToBuy[key:get()] = value:get()
  end)

  data.VehicleKeys = {} ---@type string[]
  row.VehicleKeys:ForEach(function(index, element)
    table.insert(data.VehicleKeys, element:get():ToString())
  end)

  data.OverrideAllowedVehicleKeys = {} ---@type string[]
  row.OverrideAllowedVehicleKeys:ForEach(function(index, element)
    table.insert(data.OverrideAllowedVehicleKeys, element:get():ToString())
  end)

  data.Slots = {} ---@type number[]
  row.Slots:ForEach(function(index, element)
    table.insert(data.Slots, element:get())
  end)

  data.BodyMaterialNames = {}
  row.BodyMaterialNames:ForEach(function(key, value)
    data.BodyMaterialNames[key:get():ToString()] = value:get():ToString()
  end)

  data.ColorSlots = {}
  row.ColorSlots:ForEach(function(key, value)
    data.ColorSlots[key:get()] = VehicleColorSlotToTable(value:get())
  end)

  data.DecalableMaterialSlotNames = {} ---@type string[]
  row.DecalableMaterialSlotNames:ForEach(function(index, element)
    table.insert(data.DecalableMaterialSlotNames, element:get():ToString())
  end)

  -- data.EngineAsset = row.EngineAsset
  -- data.TransmissionAsset = row.TransmissionAsset
  -- data.LSDAsset = row.LSDAsset
  data.FinalDriveRatio = row.FinalDriveRatio
  data.Intake = VehicleIntakeToTable(row.Intake)
  data.CoolantRadiator = {
    CoolantWaterInLiter = row.CoolantRadiator.CoolantWaterInLiter,
    CoolingPower = row.CoolantRadiator.CoolingPower
  }
  data.Turbocharger = VehicleTurboToTable(row.Turbocharger)
  data.Tire = VehicleTireToTable(row.Tire)
  data.SuspensionSpring = {
    SpringRateMultiplier = row.SuspensionSpring.SpringRateMultiplier
  }
  data.SuspensionDamper = {
    BoundDampingRateMultiplier = row.SuspensionDamper.BoundDampingRateMultiplier,
    ReboundDampingRateMultiplier = row.SuspensionDamper.ReboundDampingRateMultiplier
  }
  data.SuspensionRideHeight = {
    RideHeightChange = row.SuspensionRideHeight.RideHeightChange
  }
  data.AntiRollBar = {
    AntiRollBarRateMultiplier = row.AntiRollBar.AntiRollBarRateMultiplier
  }
  data.Aero = VehicleAeroToTable(row.Aero)
  -- data.Headlight = row.Headlight
  data.TrailerHitch = {
    ConnectionType = row.TrailerHitch.ConnectionType
  }
  data.CargoBed = VehicleCargoBedToTable(row.CargoBed)
  data.RoofRack = {
    CargoSpaceLocation = VectorToTable(row.RoofRack.CargoSpaceLocation),
    CargoSpaceSize = VectorToTable(row.RoofRack.CargoSpaceSize)
  }
  -- data.Wheel = row.Wheel
  data.WheelSpacer = {
    Space = row.WheelSpacer.Space
  }
  data.BrakePad = VehicleBrakePadToTable(row.BrakePad)
  data.AngleKit = {
    AngleIncreaseInDegree = row.AngleKit.AngleIncreaseInDegree
  }
  data.BrakePower = {
    BrakePowerMultiplier = row.BrakePower.BrakePowerMultiplier
  }
  data.Winch = {
    MaxForceKg = row.Winch.MaxForceKg,
    MaxLength = row.Winch.MaxLength
  }
  data.Taxi = {
    TaxiType = row.Taxi.TaxiType
  }
  data.ItemInventory = {
    NumSlots = row.ItemInventory.NumSlots
  }
  data.FuelTank = {
    row.FuelTank.FuelLiter
  }

  return data
end

---Convert AMTWinch to JSON serializable table
---@param winch UMTWinchComponent
local function WinchToTable(winch)
  if not winch:IsValid() then return {} end

  local data = {}

  -- data.InteractableComponent = winch.InteractableComponent
  -- data.CableComponent = winch.CableComponent
  -- data.MotorSoundComponent = winch.MotorSoundComponent
  -- data.AxleMeshComponent = winch.AxleMeshComponent
  -- data.HookMeshComponent = winch.HookMeshComponent
  -- data.RopeCrackingSoundComponent = winch.RopeCrackingSoundComponent
  data.Net_WinchPartKey = winch.Net_WinchPartKey:ToString()
  data.Net_WinchPartSlot = winch.Net_WinchPartSlot
  data.PartRow = VehiclePartRowToTable(winch.PartRow)
  -- data.Net_HookActor = winch.Net_HookActor
  -- data.Net_ControllerActor = winch.Net_ControllerActor
  data.Net_bAttached = winch.Net_bAttached
  -- data.Net_AttachedActor = winch.Net_AttachedActor
  -- data.Net_AttachedComponent = winch.Net_AttachedComponent
  data.Net_AttachedLocation = VectorToTable(winch.Net_AttachedLocation)
  data.Net_AttachTransformSpace = winch.Net_AttachTransformSpace
  data.Net_Length = winch.Net_Length
  data.Net_WinchControl = winch.Net_WinchControl
  data.Net_bNotEnoughForce = winch.Net_bNotEnoughForce

  return data
end

---Converts UMTTowRequestComponent to JSON serializable table
---@param tow UMTTowRequestComponent
local function TowRequestCompToTable(tow)
  local data = {}

  if not tow:IsValid() then return {} end

  -- data.DestinationActor = tow.DestinationActor
  -- data.Marker = tow.Marker
  data.Net_StartLocation = VectorToTable(tow.Net_StartLocation)
  data.Net_DestinationAbsoluteLocation = VectorToTable(tow.Net_DestinationAbsoluteLocation)
  data.Net_Payment = tow.Net_Payment
  data.Net_bArrived = tow.Net_bArrived
  data.Net_TowRequestFlags = tow.Net_TowRequestFlags
  data.Net_LastWreckerPC = GetPlayerGuid(tow.Net_LastWreckerPC)
  data.Net_PoliceTowingVehicleDriverCharacterGuid = GuidToString(tow.Net_PoliceTowingVehicleDriverCharacterGuid)
  data.LastWrecker = tow.LastWrecker.Net_VehicleId

  return data
end

---Converts FMHTransmissionGear to JSON serializable table
---@param gear FMHTransmissionGear
local function TransGearToTable(gear)
  return {
    GearRatio = gear.GearRatio,
    Inertia = gear.Inertia,
    Name = gear.Name:ToString(),
  }
end

---Converts FMHTransmissionProperty to JSON serializable table
---@param trans FMHTransmissionProperty
local function TransPropertyToTable(trans)
  local data = {}

  data.Type = trans.Type
  data.ClutchType = trans.ClutchType

  data.Gears = {}
  trans.Gears:ForEach(function(index, element)
    table.insert(data.Gears, TransGearToTable(element:get()))
  end)

  data.DefaultGearIndex = trans.DefaultGearIndex
  data.ShiftTimeSeconds = trans.ShiftTimeSeconds
  data.AutoShiftComportRPM = trans.AutoShiftComportRPM
  data.TorqueConvertorStallRPM = trans.TorqueConvertorStallRPM
  data.TorqueConvertorStallRatioPower = trans.TorqueConvertorStallRatioPower
  data.TorqueConvertorTorqueRate = trans.TorqueConvertorTorqueRate
  data.CVT_InputRPMRange = Vector2DToTable(trans.CVT_InputRPMRange)
  data.CVT_ClutchRPMRange = Vector2DToTable(trans.CVT_ClutchRPMRange)
  data.CVT_ClutchCurvePow = trans.CVT_ClutchCurvePow
  data.CVT_GearRatios = Vector2DToTable(trans.CVT_GearRatios)
  -- data.GearGrindingSound = trans.GearGrindingSound

  return data
end

---Converts UMTDriveShaftComponent to JSON serializable table
---@param drive UMTDriveShaftComponent
local function DriveShaftToTable(drive)
  if not drive:IsValid() then return {} end

  return {
    TransmissionComponentName = drive.TransmissionComponentName:ToString(),
    Inertia = drive.Inertia,
    TransmissionComponent = {
      CurrentGear = drive.TransmissionComponent.CurrentGear,
      TransmissionProperty = TransPropertyToTable(drive.TransmissionComponent.TransmissionProperty)
    }
  }
end

---Converts FMTConstraintCollisionLock to JSON serializable table
---@param constraint FMTConstraintCollisionLock
local function ConstraintCollisionToTable(constraint)
  local data = {}

  data.CollisionComponentNames = {} ---@type string[]
  constraint.CollisionComponentNames:ForEach(function(index, element)
    table.insert(data, element:get():ToString())
  end)

  data.UnlockDirection = constraint.UnlockDirection

  return data
end

---Converts FMTConstraintRangeConfig to JSON serializable table
---@param constraint FMTConstraintRangeConfig
local function ConstraintRangeToTable(constraint)
  return {
    LinearLimitRange = Vector2DToTable(constraint.LinearLimitRange),
    TwistLimitDegrees = Vector2DToTable(constraint.TwistLimitDegrees),
    bAngularRotationOffset = constraint.bAngularRotationOffset,
    AngularRotationOffsetStart = RotatorToTable(constraint.AngularRotationOffsetStart),
    AngularRotationOffsetEnd = RotatorToTable(constraint.AngularRotationOffsetEnd),
  }
end

---Converts UMTConstraintComponent to JSON serializable table
---@param constraint UMTConstraintComponent
local function ConstraintToTable(constraint)
  if not constraint:IsValid() then return {} end

  local data = {}

  data.bDisableSimulationOnTerm1 = constraint.bDisableSimulationOnTerm1
  data.bDisableSimulationOnTerm2 = constraint.bDisableSimulationOnTerm2
  data.bOverridePos1 = constraint.bOverridePos1
  data.OverridePos1 = VectorToTable(constraint.OverridePos1)
  data.bOverridePos2 = constraint.bOverridePos2
  data.OverridePos2 = VectorToTable(constraint.OverridePos2)
  data.bHydraulic = constraint.bHydraulic
  data.bPTOHydraulic = constraint.bPTOHydraulic
  data.bLinearHydraulic = constraint.bLinearHydraulic
  data.bAngularHydraulic = constraint.bAngularHydraulic
  data.LinearSpeed = constraint.LinearSpeed
  data.LinearPositionStrength = constraint.LinearPositionStrength
  data.LinearVelocityStrength = constraint.LinearVelocityStrength
  data.LinearMaxForce = constraint.LinearMaxForce
  data.bLimitLinearRange = constraint.bLimitLinearRange
  data.LimitLinearRange = Vector2DToTable(constraint.LimitLinearRange)
  data.AngularSpeed = constraint.AngularSpeed
  data.AngularPositionStrength = constraint.AngularPositionStrength
  data.AngularVelocityStrength = constraint.AngularVelocityStrength
  data.AngularMaxForce = constraint.AngularMaxForce

  data.CollisionLocks = {}
  constraint.CollisionLocks:ForEach(function(index, element)
    table.insert(data.CollisionLocks, ConstraintCollisionToTable(element:get()))
  end)

  data.RangeConfigs = {}
  constraint.RangeConfigs:ForEach(function(index, element)
    table.insert(data.RangeConfigs, ConstraintRangeToTable(element:get()))
  end)

  -- data.HydraulicSound = constraint.HydraulicSound
  data.DisableCollisionComponentNames = {}
  constraint.DisableCollisionComponentNames:ForEach(function(index, element)
    table.insert(data.DisableCollisionComponentNames, element:get():ToString())
  end)

  -- data.DisableCollisionComponents = constraint.DisableCollisionComponents
  -- data.Net_BodyLocalMovements = constraint.Net_BodyLocalMovements
  -- data.HydraulicAudioComponent = constraint.HydraulicAudioComponent
  data.Net_HydraulicControl = constraint.Net_HydraulicControl
  data.Net_TargetPosition = constraint.Net_TargetPosition

  return data
end

---Converts UMTStrapComponent to JSON serializable table
---@param strap UMTStrapComponent
local function StrapCompToTable(strap)
  if not strap:IsValid() then return {} end

  local data = {}

  data.Net_Cargo = strap.Net_Cargo.Net_CargoKey:ToString()
  -- data.Net_Wheel = strap.Net_Wheel -- cyclic dependency
  -- data.Net_TargetComponent = strap.Net_TargetComponent
  -- data.Net_TowingComponent = strap.Net_TowingComponent
  data.Net_TowedVehicle = strap.Net_TowedVehicle.Net_VehicleId
  data.Net_Transform = TransformToTable(strap.Net_Transform)
  data.Constraint = ConstraintToTable(strap.Constraint)
  -- data.RopeMeshComponents = strap.RopeMeshComponents
  -- data.BuckleComponents = strap.BuckleComponents

  return data
end

---Converts UMTDifferentialComponent to JSON serializable table
---@param diff UMTDifferentialComponent
local function DiffToTable(diff)
  if not diff:IsValid() then return {} end

  return {
    LSDSlotName = diff.LSDSlotName:ToString(),
    LSDSlotIndex = diff.LSDSlotIndex,
    TransmissionComponentName = diff.TransmissionComponentName:ToString(),
    DifferentialComponentName = diff.DifferentialComponentName:ToString(),
    LinkGearRatio = diff.LinkGearRatio,
    Inertia = diff.Inertia,
    bAllowLockableLSD = diff.bAllowLockableLSD,
    -- TransmissionComponent = diff.TransmissionComponent,
    -- DifferentialComponent = diff.DifferentialComponent,
    DataAsset = diff.DataAsset:IsValid() and {
      LSDType = diff.DataAsset.LSDType,
      ClutchPackAccel = diff.DataAsset.ClutchPackAccel,
      ClutchPackBrake = diff.DataAsset.ClutchPackBrake,
    } or nil
  }
end

---Converts UMHWheelComponent to JSON serializable table
---@param wheel UMHWheelComponent
local function WheelCompToTable(wheel)
  if not wheel:IsValid() then return {} end

  local data = {}

  data.WheelSlotIndex = wheel.WheelSlotIndex

  data.WheelFlags = {} ---@type number[]
  wheel.WheelFlags:ForEach(function(index, element)
    table.insert(data.WheelFlags, element:get())
  end)

  data.DriveShaftComponentName = wheel.DriveShaftComponentName:ToString()
  data.DifferentialComponentName = wheel.DifferentialComponentName:ToString()
  data.LinkGearRatio = wheel.LinkGearRatio
  data.TirePhysicsData = {
    TirePhysicsParams = TirePhysicsToTable(wheel.TirePhysicsData.TirePhysicsParams)
  }
  data.BrushTirePhysics = {
    ContactPatchLength = wheel.BrushTirePhysics.ContactPatchLength,
    ContactPatchStaticLength = wheel.BrushTirePhysics.ContactPatchStaticLength
  }
  data.Inertia = wheel.Inertia
  data.SpringStroke = wheel.SpringStroke
  data.SpringLength = wheel.SpringLength
  data.SpringK = wheel.SpringK
  data.SpringBoundDamping = wheel.SpringBoundDamping
  data.SpringReboundDamping = wheel.SpringReboundDamping
  data.bSteer = wheel.bSteer
  data.bReverseSteer = wheel.bReverseSteer
  data.bSteerBy5thWheel = wheel.bSteerBy5thWheel
  data.bTagAxleSteer = wheel.bTagAxleSteer
  data.SteerBy5thWheelPivotX = wheel.SteerBy5thWheelPivotX
  data.TagAxleSteerPivotX = wheel.TagAxleSteerPivotX
  data.MaxSteeringAngleDegree = wheel.MaxSteeringAngleDegree
  data.MaxSteeringAngleDegreePerSeconds = wheel.MaxSteeringAngleDegreePerSeconds
  data.DisableSteeringSpeedKPH = wheel.DisableSteeringSpeedKPH
  data.CasterDegree = wheel.CasterDegree
  data.KingpinOffset = wheel.KingpinOffset
  data.KingpinAngle = wheel.KingpinAngle
  data.HandleBarOffset = wheel.HandleBarOffset
  data.BrakeRatio = wheel.BrakeRatio
  data.bHandBrake = wheel.bHandBrake
  data.TreadWidthOverride = wheel.TreadWidthOverride
  data.UnsprungMassMassFromBodyMultiplier = wheel.UnsprungMassMassFromBodyMultiplier
  data.DriveShaftComponent = DriveShaftToTable(wheel.DriveShaftComponent)
  data.DifferentialComponent = DiffToTable(wheel.DifferentialComponent)
  -- data.SkidSoundComponent = wheel.SkidSoundComponent
  -- data.RoadNoiseSoundComponent = wheel.RoadNoiseSoundComponent
  -- data.SurfaceSoundComponent = wheel.SurfaceSoundComponent
  -- data.SurfaceEnvSoundComponent = wheel.SurfaceEnvSoundComponent
  -- data.BrakeSoundComponent = wheel.BrakeSoundComponent
  -- data.SurfaceLoopNC = wheel.SurfaceLoopNC
  -- data.SurfaceLoopNS = wheel.SurfaceLoopNS
  -- data.BrakeSmokeEffect = wheel.BrakeSmokeEffect
  -- data.InteractableComponent = wheel.InteractableComponent
  data.Strap = StrapCompToTable(wheel.Strap)
  -- data.ContactSurfaceSound = wheel.ContactSurfaceSound
  -- data.SurfaceEnvSound = wheel.SurfaceEnvSound

  return data
end

---Converts UMTTowingComponent to JSON serializable table
---@param tow UMTTowingComponent
local function TowCompToTable(tow)
  if not tow:IsValid() then return {} end

  local data = {}

  data.HookType = tow.HookType
  -- data.HookSound = tow.HookSound
  -- data.UnhookSound = tow.UnhookSound
  -- data.InteractableComponent = tow.InteractableComponent
  data.Strap = StrapCompToTable(tow.Strap)
  -- data.DisableCollisionComponents = tow.DisableCollisionComponents

  return data
end

---Converts UMTVehicleAttachmentPartComponent to JSON serializable table
---@param comp UMTVehicleAttachmentPartComponent
local function VehicleAttachmentPartCompToTable(comp)
  if not comp:IsValid() then return {} end

  return {
    Net_PartKey = comp.Net_PartKey,
    Net_PartSlot = comp.Net_PartSlot
  }
end

---Converts FMTVehicleCargoPartAndSlot to JSON serializable table
---@param cargo FMTVehicleCargoPartAndSlot
local function VehicleCargoPartToTable(cargo)
  return {
    CargoSpace = cargo.CargoSpace,
    Slot = cargo.Slot
  }
end

---Converts UMTPoliceVehicleComponent to JSON serializable table
---@param police UMTPoliceVehicleComponent
local function PoliceVehicleCompToTable(police)
  if not police:IsValid() then return {} end

  local data = {}

  data.Server_PendingTicketSuspects = {}
  police.Server_PendingTicketSuspects:ForEach(function(index, element)
    table.insert(
      data.Server_PendingTicketSuspects,
      GuidToString(element:get().Net_MTPlayerState.CharacterGuid)
    )
  end)

  return data
end

---Converts FMotorTownAIDriverSetting to JSON serializable table
---@param ai FMotorTownAIDriverSetting
local function AIDriverSettingToTable(ai)
  return {
    BrakingG = ai.BrakingG,
    LateralG = ai.LateralG,
    RaceBrakingG = ai.RaceBrakingG,
    RaceLateralG = ai.RaceLateralG
  }
end

---Converts FMTAntiRollBarParams to JSON serializable table
---@param rollbar FMTAntiRollBarParams
local function AntiRollbarToTable(rollbar)
  return {
    Wheel0Name = rollbar.Wheel0Name:ToString(),
    Wheel1Name = rollbar.Wheel1Name:ToString(),
    SpringK = rollbar.SpringK,
    SpringD = rollbar.SpringD,
  }
end

---Converts FMTVehicleSuspensionParams to JSON serializable table
---@param sus FMTVehicleSuspensionParams
local function VehicleSuspensionParamToTable(sus)
  return {
    WheelSlotIndex = sus.WheelSlotIndex,
    ComponentName = sus.ComponentName:ToString(),
    SuspensionType = sus.SuspensionType,
    WheelHubBoneName = sus.WheelHubBoneName:ToString(),
    TrailArmBoneName = sus.TrailArmBoneName:ToString(),
    TrailArmAxleSocketName = sus.TrailArmAxleSocketName:ToString(),
  }
end

---Converts FMTVehiclePistonParams to JSON serializable table
---@param piston FMTVehiclePistonParams
local function VehiclePistonParamToTable(piston)
  return {
    ComponentName = piston.ComponentName:ToString(),
    BaseComponentName = piston.BaseComponentName:ToString(),
    TargetComponentName = piston.TargetComponentName:ToString(),
    BaseSocketName = piston.BaseSocketName:ToString(),
    TargetSocketName = piston.TargetSocketName:ToString(),
  }
end

---Convert FMTVehicleDiffLockingState to JSON serializable table
---@param diff FMTVehicleDiffLockingState
local function VehicleDiffLockingStateToTable(diff)
  local data = {}

  data.Name = diff.Name:ToString()

  data.Differentials = {}
  diff.Differentials:ForEach(function(key, value)
    data.Differentials[key:get():ToString()] = value:get()
  end)

  data.GearRatio = diff.GearRatio
  data.bDisableBrakeTCS = diff.bDisableBrakeTCS

  return data
end

---Convert FMTVehicleLiftAxle to JSON serializable table
---@param axle FMTVehicleLiftAxle
local function VehicleLiftAxleToTable(axle)
  local data = {}

  data.Name = axle.Name:ToString()
  data.WheelIndexToHeight = {}
  axle.WheelIndexToHeight:ForEach(function(key, value)
    data.WheelIndexToHeight[key:get()] = value:get()
  end)

  return data
end

---Convert FMTVehicleWheelAxle to JSON serializable table
---@param axle FMTVehicleWheelAxle
local function VehicleWheelAxleToTable(axle)
  local data = {}

  data.AxleIndex = axle.AxleIndex
  data.WheelIndices = {} ---@type number[]
  axle.WheelIndices:ForEach(function(index, element)
    table.insert(data.WheelIndices, element:get())
  end)
  data.LocationX = axle.LocationX

  return data
end

---Convert FMTNetWheelHotState to JSON serializable table
---@param state FMTNetWheelHotState
local function NetWheelHotStateToTable(state)
  return {
    BrakeTemperature = state.BrakeTemperature,
    BrakeCoreTemperature = state.BrakeCoreTemperature,
    TireCoreTemperature = state.TireCoreTemperature,
    TireBrushTemperature = state.TireBrushTemperature,
  }
end

---Convert FMTVehicleColdState to JSON serializable table
---@param state FMTVehicleColdState
local function VehicleColdStateToTable(state)
  local data = {}

  data.DriveMode = state.DriveMode

  data.ToggleFunctions = {} ---@type boolean[]
  state.ToggleFunctions:ForEach(function(index, element)
    table.insert(data.ToggleFunctions, element:get())
  end)

  data.TurnSignal = state.TurnSignal
  data.HeadLightMode = state.HeadLightMode
  data.SirenIndex = state.SirenIndex
  data.bIsAIDriving = state.bIsAIDriving
  data.bStoppedInParkingSpace = state.bStoppedInParkingSpace
  data.bHorn = state.bHorn
  data.bAcceptTaxiPassenger = state.bAcceptTaxiPassenger

  data.RemovedWheels = {} ---@type number[]
  state.RemovedWheels:ForEach(function(index, element)
    table.insert(data.RemovedWheels, element:get())
  end)

  data.DiffLockIndex = state.DiffLockIndex

  data.LiftedAxleIndices = {} ---@type number[]
  state.LiftedAxleIndices:ForEach(function(index, element)
    table.insert(data.LiftedAxleIndices, element:get())
  end)

  data.LastLocationsInRoad = {}
  state.LastLocationsInRoad:ForEach(function(index, element)
    table.insert(data.LastLocationsInRoad, {
      Location = VectorToTable(element:get().Location),
      Rotation = RotatorToTable(element:get().Rotation),
    })
  end)

  return data
end

---Convert FMTVehicleState to JSON serializable table
---@param state FMTVehicleState
local function VehicleStateToTable(state)
  local data = {}

  data.Fuel = state.Fuel
  data.Condition = state.Condition
  data.OdoMeterKm = state.OdoMeterKm
  data.Wheels = {} ---@type table[]
  state.Wheels:ForEach(function(index, element)
    table.insert(data.Wheels, NetWheelHotStateToTable(element:get()))
  end)
  data.LiftAxleProgresses = {} ---@type number[]
  state.LiftAxleProgresses:ForEach(function(index, element)
    table.insert(data.LiftAxleProgresses, element:get())
  end)

  return data
end

---Convert FMTVehicleOwnerSetting to JSON serializable table
---@param setting FMTVehicleOwnerSetting
local function VehicleOwnerSettingToTable(setting)
  local data = {}

  data.bLocked = setting.bLocked
  data.DriveAllowedPlayers = setting.DriveAllowedPlayers

  data.LevelRequirementsToDrive = {} ---@type number[]
  setting.LevelRequirementsToDrive:ForEach(function(index, element)
    table.insert(data.LevelRequirementsToDrive, element:get())
  end)

  data.VehicleOwnerProfitShare = setting.VehicleOwnerProfitShare

  return data
end

---Convert FMTNetEngineHotState to JSON serializable table
---@param engine FMTNetEngineHotState
local function NetEngineHotStateToTable(engine)
  return {
    bStarterOn = engine.bStarterOn,
    bIgnitionOn = engine.bIgnitionOn,
    CurrentRPM = engine.CurrentRPM,
    CoolantTemp = engine.CoolantTemp,
    RegenBrake = engine.RegenBrake,
    JakeBrake = engine.JakeBrake,
  }
end

---Convert FMTVehicleCustomization to JSON serializable table
---@param custom FMTVehicleCustomization
local function VehicleCustomizationToTable(custom)
  local data = {}

  data.BodyMaterialIndex = custom.BodyMaterialIndex

  data.BodyColors = {}
  custom.BodyColors:ForEach(function(index, element)
    table.insert(data.BodyColors, {
      MaterialSlotName = element:get().MaterialSlotName:ToString(),
      Color = ColorToTable(element:get().Color),
    })
  end)

  return data
end

---Convert FMTVehicleDecalLayer to JSON serializable table
---@param decal FMTVehicleDecalLayer
local function VehicleDecalLayerToTable(decal)
  return {
    DecalKey = decal.DecalKey:ToString(),
    Color = ColorToTable(decal.Color),
    Position = Vector2DToTable(decal.Position),
    Rotation = RotatorToTable(decal.Rotation),
    DecalScale = decal.DecalScale,
    Stretch = decal.Stretch,
    Coverage = decal.Coverage,
    Flags = decal.Flags,
  }
end

---Convert FMTVehicleDecal to JSON serializable table
---@param decal FMTVehicleDecal
local function VehicleDecalToTable(decal)
  local data = {}

  decal.DecalLayers:ForEach(function(index, element)
    table.insert(data, VehicleDecalLayerToTable(element:get()))
  end)

  return {
    DecalLayers = data,
  }
end

---Convert FMTVehiclePart to JSON serializable table
---@param part FMTVehiclePart
local function VehiclePartToTable(part)
  local data = {}

  data.ID = part.ID
  data.Key = part.Key:ToString()
  data.Slot = part.Slot
  data.Damage = part.Damage

  data.FloatValues = {} ---@type number[]
  part.FloatValues:ForEach(function(index, element)
    table.insert(data.FloatValues, element:get())
  end)

  data.Int64Values = {} ---@type number[]
  part.Int64Values:ForEach(function(index, element)
    table.insert(data.Int64Values, element:get())
  end)

  data.StringValues = {} ---@type string[]
  part.StringValues:ForEach(function(index, element)
    table.insert(data.StringValues, element:get():ToString())
  end)

  data.VectorValues = {} ---@type table[]
  part.VectorValues:ForEach(function(index, element)
    table.insert(data.VectorValues, VectorToTable(element:get()))
  end)

  data.ItemInventory = ItemInventoryToTable(part.ItemInventory)

  return data
end

---Convert FMTVehicleAINetState to JSON serializable table
---@param state FMTVehicleAINetState
local function VehicleAINetStateToTable(state)
  local data = {}

  data.CrossroadId = state.CrossroadId
  data.LastCrossRoadId = state.LastCrossRoadId
  data.CrossroadEnterTimeSeconds = state.CrossroadEnterTimeSeconds

  data.CrossRoadNodeIndices = {} ---@type number[]
  state.CrossRoadNodeIndices:ForEach(function(index, element)
    table.insert(data.CrossRoadNodeIndices, element:get())
  end)

  return data
end

---Convert AMotorTownRoad to JSON serializable table
---@param road AMotorTownRoad
local function MotorTownRoadToTable(road)
  if not road:IsValid() then return {} end

  local data = {}

  data.RoadType = road.RoadType
  data.CourseKey = road.CourseKey:ToString()
  data.LaneWidth = road.LaneWidth
  data.NumForwardLanes = road.NumForwardLanes
  data.NumBackwardLanes = road.NumBackwardLanes
  data.bCopyFromLandscape = road.bCopyFromLandscape
  data.CopyFromLandscapeWidthMultiplier = road.CopyFromLandscapeWidthMultiplier
  data.RoadFlags = road.RoadFlags
  data.SpeedLimitKPH = road.SpeedLimitKPH

  data.ExcludeConnectionRoads = {} ---@type string[]
  road.ExcludeConnectionRoads:ForEach(function(index, element)
    table.insert(data.ExcludeConnectionRoads, element:get().CourseKey:ToString())
  end)

  data.MaxRoadSideTowDistance = road.MaxRoadSideTowDistance
  -- data.Spline = road.Spline
  -- data.SplineBounds = road.SplineBounds

  return data
end

---Convert FMTLaptimeModule to JSON serializable table
---@param time FMTLaptimeModule
local function LaptimeModuleToTable(time)
  local data = {}

  data.Courses = {}
  time.Courses:ForEach(function(key, value)
    data.Courses[key:get():ToString()] = {
      NumSections = value:get().NumSections
    }
  end)
  data.CourseRoad = MotorTownRoadToTable(time.CourseRoad)
  data.OverlappedRaceSection = time.OverlappedRaceSection:IsValid() and {
    CourseName = time.OverlappedRaceSection.CourseName:ToString(),
    RaceSectionIndex = time.OverlappedRaceSection.RaceSectionIndex,
    bIsStopBox = time.OverlappedRaceSection.bIsStopBox
  } or nil

  return data
end

---Convert FMTVehicleHookParams to JSON serializable table
---@param param FMTVehicleHookParams
local function VehicleHookParamToTable(param)
  return {
    HookType = param.HookType,
    HookSocketName = param.HookSocketName:ToString(),
    -- HookComponent = param.HookComponent,
    HookLocation = VectorToTable(param.HookLocation),
  }
end

---Convert UMTVehicleCargoSpaceComponent to JSON serializable table
---@param cargoSpace UMTVehicleCargoSpaceComponent
local function VehicleCargoSpaceCompToTable(cargoSpace)
  if not cargoSpace:IsValid() then return {} end

  local data = {}

  data.CargoSpaceType = cargoSpace.CargoSpaceType
  data.bFixCargo = cargoSpace.bFixCargo
  data.bUnlimitedHeight = cargoSpace.bUnlimitedHeight
  data.DumpVolume = cargoSpace.DumpVolume
  data.DumpCargoSurfaceSlopeYAngleDegree = cargoSpace.DumpCargoSurfaceSlopeYAngleDegree
  data.bAllowPutdownCargoByInteraction = cargoSpace.bAllowPutdownCargoByInteraction
  -- data.InteractableComponent = cargo.InteractableComponent
  -- data.DumpMeshComponent = cargo.DumpMeshComponent
  -- data.DummyCargoInteractable = cargo.DummyCargoInteractable

  data.Net_Cargos = {}
  cargoSpace.Net_Cargos:ForEach(function(index, element)
    table.insert(data.Net_Cargos, cargo.CargoToTable(element:get()))
  end)

  data.Net_DroppedCargos = {}
  cargoSpace.Net_DroppedCargos:ForEach(function(index, element)
    table.insert(data.Net_DroppedCargos, cargo.CargoToTable(element:get()))
  end)

  data.Net_BoxExtent = VectorToTable(cargoSpace.Net_BoxExtent)
  data.Net_LoadedItemType = cargoSpace.Net_LoadedItemType
  data.Net_LoadedItemVolume = cargoSpace.Net_LoadedItemVolume
  data.Net_CargoSpaceRuntimeFlags = cargoSpace.Net_CargoSpaceRuntimeFlags

  data.DroppedCargoCandidates = {}
  cargoSpace.DroppedCargoCandidates:ForEach(function(key, value)
    data.DroppedCargoCandidates[key:get().Net_CargoKey:ToString()] = value:get()
  end)

  data.Net_CarryingVehicles = {}
  cargoSpace.Net_CarryingVehicles:ForEach(function(index, element)
    table.insert(data.Net_CarryingVehicles, element:get().Net_VehicleId)
  end)

  data.OverlappedVehicles = {}
  cargoSpace.OverlappedVehicles:ForEach(function(index, element)
    table.insert(data.OverlappedVehicles, element:get().Net_VehicleId)
  end)

  return data
end

---Convert AMTVehicle to JSON serializable table
---@param vehicle AMTVehicle
local function VehicleToTable(vehicle)
  local data = {}

  -- data.DefaultVehicleFeatures = vehicle.DefaultVehicleFeatures
  data.ExControls = {}
  vehicle.ExControls:ForEach(function(index, element)
    table.insert(data.ExControls, element:get())
  end)

  -- data.BodyMaterials = vehicle.BodyMaterials
  -- data.BodyMaterialList = vehicle.BodyMaterialList
  data.BodyMaterialName = vehicle.BodyMaterialName:ToString()

  data.BodyMaterialNames = {} ---@type string[]
  vehicle.BodyMaterialNames:ForEach(function(index, element)
    table.insert(data.BodyMaterialNames, element:get():ToString())
  end)

  data.DecalableMaterialSlotNames = {} ---@type string[]
  vehicle.DecalableMaterialSlotNames:ForEach(function(index, element)
    table.insert(data.DecalableMaterialSlotNames, element:get():ToString())
  end)

  data.BodyColorMaterialSlotNames = {}
  vehicle.BodyColorMaterialSlotNames:ForEach(function(key, value)
    data.BodyColorMaterialSlotNames[key:get():ToString()] = value:get():ToString()
  end)

  data.ColorSlots = {}
  vehicle.ColorSlots:ForEach(function(key, value)
    data.ColorSlots[key:get():ToString()] = ColorSlotToTable(value:get())
  end)

  data.BodyColors = {}
  vehicle.BodyColors:ForEach(function(index, element)
    table.insert(data.BodyColors, VehicleColorToTable(element:get()))
  end)
  -- data.BusComponentClass = vehicle.BusComponentClass
  -- data.RootBody = vehicle.RootBody
  -- data.Mesh = vehicle.Mesh
  -- data.SteeringWheel = vehicle.SteeringWheel
  data.Wheels = {}
  vehicle.Wheels:ForEach(function(index, element)
    table.insert(data.Wheels, WheelCompToTable(element:get()))
  end)
  -- data.EngineComponent = vehicle.EngineComponent
  -- data.CargoSpaceInteractableComponent = vehicle.CargoSpaceInteractableComponent
  -- data.DrivingInput = vehicle.DrivingInput
  -- data.HornAudioComponent = vehicle.HornAudioComponent
  -- data.SirenAudioComponent = vehicle.SirenAudioComponent
  -- data.BackupBeepAudioComponent = vehicle.BackupBeepAudioComponent
  -- data.RefuelAudioComponent = vehicle.RefuelAudioComponent
  -- data.AirHydraulicAudioComponent = vehicle.AirHydraulicAudioComponent
  -- data.WindNoiseAudioComponent = vehicle.WindNoiseAudioComponent
  -- data.AirHydraulicSound = vehicle.AirHydraulicSound
  -- data.DriverSeatInteractionSphereComponent = vehicle.DriverSeatInteractionSphereComponent
  -- data.DriverSeatInteractableComponent = vehicle.DriverSeatInteractableComponent
  -- data.PassengerSeatInteractionSphereComponent = vehicle.PassengerSeatInteractionSphereComponent
  -- data.PassengerSeatInteractableComponent = vehicle.PassengerSeatInteractableComponent
  -- data.NavModifierComponent = vehicle.NavModifierComponent
  -- data.Dashboard = vehicle.Dashboard
  -- data.CameraSpringArm = vehicle.CameraSpringArm
  -- data.TrailCamera = vehicle.TrailCamera
  -- data.CockpitCamera = vehicle.CockpitCamera
  -- data.LOD1DisableTickComponents = vehicle.LOD1DisableTickComponents
  -- data.LOD2DisableTickComponents = vehicle.LOD2DisableTickComponents
  -- data.LOD2UnregisterComponents = vehicle.LOD2UnregisterComponents
  -- data.LOD3UnregisterComponents = vehicle.LOD3UnregisterComponents
  -- data.LOD4UnregisterComponents = vehicle.LOD4UnregisterComponents
  -- data.TransmissionComponent = vehicle.TransmissionComponent
  data.Differentials = {}
  vehicle.Differentials:ForEach(function(index, element)
    table.insert(data.Differentials, DiffToTable(element:get()))
  end)
  -- data.Seats = vehicle.Seats
  -- data.MirrorComponents = vehicle.MirrorComponents
  -- data.Doors = vehicle.Doors
  -- data.CargoSpaces = vehicle.CargoSpaces
  -- data.TaxiComponent = vehicle.TaxiComponent
  -- data.Net_BusComponent = vehicle.Net_BusComponent
  -- data.TruckComponent = vehicle.TruckComponent
  -- data.WreckerComponent = vehicle.WreckerComponent
  -- data.TrailerComponent = vehicle.TrailerComponent
  -- data.Headlights = vehicle.Headlights
  -- data.TailLights = vehicle.TailLights
  -- data.ReverseLights = vehicle.ReverseLights
  -- data.BlinkerLights = vehicle.BlinkerLights
  -- data.EmegencyLights = vehicle.EmegencyLights
  -- data.Constraints = vehicle.Constraints
  -- data.ForkliftTiltConstraint = vehicle.ForkliftTiltConstraint
  -- data.ForkliftLiftConstraints = vehicle.ForkliftLiftConstraints
  -- data.ForkliftForkLeftConstraint = vehicle.ForkliftForkLeftConstraint
  -- data.ForkliftForkRightConstraint = vehicle.ForkliftForkRightConstraint

  data.Winches = {}
  vehicle.Winches:ForEach(function(index, element)
    table.insert(data.Winches, WinchToTable(element:get()))
  end)

  data.TowRequestComponent = TowRequestCompToTable(vehicle.TowRequestComponent)
  data.TowingComponent = TowCompToTable(vehicle.TowingComponent)
  -- data.PartSlots = vehicle.PartSlots
  -- data.InteriorLights = vehicle.InteriorLights
  -- data.TaxiRoofSign = vehicle.TaxiRoofSign
  data.RearSpoiler = vehicle.RearSpoiler:IsValid() and {
    Net_PartKey = vehicle.RearSpoiler.Net_PartKey:ToString(),
    Net_PartSlot = vehicle.RearSpoiler.Net_PartSlot
  } or nil
  data.RearWing = vehicle.RearWing:IsValid() and {
    Net_PartKey = vehicle.RearWing.Net_PartKey:ToString(),
    Net_PartSlot = vehicle.RearWing.Net_PartSlot
  } or nil
  -- data.AeroParts = vehicle.AeroParts
  data.AttachmentParts = {}
  vehicle.AttachmentParts:ForEach(function(key, value)
    data.AttachmentParts[key:get()] = VehicleAttachmentPartCompToTable(value:get())
  end)

  data.AttachmentPartsComponents = {}
  vehicle.AttachmentPartsComponents:ForEach(function(index, element)
    data.AttachmentPartsComponents[index] = VehicleAttachmentPartCompToTable(element:get())
  end)

  data.Net_RoofRackParts = {}
  vehicle.Net_RoofRackParts:ForEach(function(index, element)
    data.Net_RoofRackParts[index] = VehicleCargoPartToTable(element:get())
  end)

  data.Net_CargoBedParts = {}
  vehicle.Net_CargoBedParts:ForEach(function(index, element)
    data.Net_CargoBedParts[index] = VehicleCargoPartToTable(element:get())
  end)

  data.Server_Winches = {}
  vehicle.Server_Winches:ForEach(function(key, value)
    data.Server_Winches[key:get()] = WinchToTable(value:get())
  end)

  data.TrailerHitch = vehicle.TrailerHitch:IsValid() and {
    ConnectionType = vehicle.TrailerHitch.ConnectionType
  } or nil
  data.PoliceComponent = PoliceVehicleCompToTable(vehicle.PoliceComponent)
  data.SellerComponent = vehicle.SellerComponent:IsValid() and {
    Marker = VectorToTable(vehicle.SellerComponent.Marker:K2_GetActorLocation())
  } or nil
  -- data.CraneComponent = vehicle.CraneComponent
  -- data.GetawayComponent = vehicle.GetawayComponent
  -- data.DecalComponent = vehicle.DecalComponent
  -- data.TankerFuelPumpComponent = vehicle.TankerFuelPumpComponent
  data.GameplayTagContainer = GameplayTagContainerToString(vehicle.GameplayTagContainer)
  -- data.StaticMeshDefaultTransforms = vehicle.StaticMeshDefaultTransforms
  data.bForSale = vehicle.bForSale
  data.bDrivable = vehicle.bDrivable
  data.bHasSteeringWheel = vehicle.bHasSteeringWheel
  data.bHasDriverSeat = vehicle.bHasDriverSeat
  data.bHasPassengerSeat = vehicle.bHasPassengerSeat
  data.AIDriverSetting = AIDriverSettingToTable(vehicle.AIDriverSetting)
  data.bIsOpenAir = vehicle.bIsOpenAir
  data.DefaultDrivingMode = vehicle.DefaultDrivingMode
  data.MaxSteeringAngleDegree = vehicle.MaxSteeringAngleDegree
  data.ParallelSteering = vehicle.ParallelSteering
  data.OptimalSlipAngleDegree = vehicle.OptimalSlipAngleDegree
  data.SteeringOffsetX = vehicle.SteeringOffsetX
  data.MaxSteeringWheelAngleDegree = vehicle.MaxSteeringWheelAngleDegree
  data.BrakeTorqueMultiplier = vehicle.BrakeTorqueMultiplier
  data.BrakeTemperatureMass = vehicle.BrakeTemperatureMass
  data.KeyboardSteerSpeed = vehicle.KeyboardSteerSpeed
  data.KeyboardSteerReturnSpeed = vehicle.KeyboardSteerReturnSpeed

  data.AntiRollBars = {}
  vehicle.AntiRollBars:ForEach(function(index, element)
    table.insert(data.AntiRollBars, AntiRollbarToTable(element:get()))
  end)

  data.Suspensions = {}
  vehicle.Suspensions:ForEach(function(index, element)
    table.insert(data.Suspensions, VehicleSuspensionParamToTable(element:get()))
  end)

  data.Pistons = {}
  vehicle.Pistons:ForEach(function(index, element)
    table.insert(data.Pistons, VehiclePistonParamToTable(element:get()))
  end)

  data.FuelTankCapacityInLiter = vehicle.FuelTankCapacityInLiter
  data.AirDragCoeff = vehicle.AirDragCoeff
  data.AeroLiftCoeff = Vector2DToTable(vehicle.AeroLiftCoeff)
  data.AeroLiftCoeff_Front = vehicle.AeroLiftCoeff_Front
  data.AeroLiftCoeff_Rear = vehicle.AeroLiftCoeff_Rear
  data.AirDragFrontalAreaMultiplier = vehicle.AirDragFrontalAreaMultiplier

  data.DiffLockings = {}
  vehicle.DiffLockings:ForEach(function(index, element)
    table.insert(data.DiffLockings, VehicleDiffLockingStateToTable(element:get()))
  end)

  data.LiftAxles = {}
  vehicle.LiftAxles:ForEach(function(index, element)
    table.insert(data.LiftAxles, VehicleLiftAxleToTable(element:get()))
  end)

  data.ControlSettings = {
    SteeringAssistMinSpeed = Vector2DToTable(vehicle.ControlSettings.SteeringAssistMinSpeed),
    SteeringSpeedInComfort = vehicle.ControlSettings.SteeringSpeedInComfort,
    bRearSteering = vehicle.ControlSettings.bRearSteering
  }
  data.PhysicsSettings = {
    TCSMinWheelSpeed = Vector2DToTable(vehicle.PhysicsSettings.TCSMinWheelSpeed)
  }
  data.bUseSteeringWheelSocketAsPivot = vehicle.bUseSteeringWheelSocketAsPivot
  data.bSteeringAttachedToSkeletalSocket = vehicle.bSteeringAttachedToSkeletalSocket
  data.LimitSteeringByLateralG = vehicle.LimitSteeringByLateralG
  data.bLeanDriver = vehicle.bLeanDriver
  data.BaseLeanForwardDegree = vehicle.BaseLeanForwardDegree
  -- data.HornSound = vehicle.HornSound
  data.HornFadeInSeconds = vehicle.HornFadeInSeconds
  data.HornFadeOutSeconds = vehicle.HornFadeOutSeconds
  -- data.SirenSounds = vehicle.SirenSounds
  -- data.AirBrakeSound = vehicle.AirBrakeSound
  -- data.ParkingBrakeSound = vehicle.ParkingBrakeSound
  -- data.ParkingBrakeReleaseSound = vehicle.ParkingBrakeReleaseSound
  -- data.BackupBeep = vehicle.BackupBeep
  -- data.RefuelingSound = vehicle.RefuelingSound
  data.RefuelSoundFadeInSeconds = vehicle.RefuelSoundFadeInSeconds
  data.RefuelSoundFadeOutSeconds = vehicle.RefuelSoundFadeOutSeconds
  -- data.RefuelingEndSound = vehicle.RefuelingEndSound
  -- data.RattleSound = vehicle.RattleSound
  data.RattleSoundG = vehicle.RattleSoundG
  -- data.WindNoiseSound = vehicle.WindNoiseSound
  data.WindNoiseVolume = vehicle.WindNoiseVolume
  data.Throttle = vehicle.Throttle
  data.Brake = vehicle.Brake
  data.Steer = vehicle.Steer
  data.HandBrake = vehicle.HandBrake
  data.Clutch = vehicle.Clutch
  data.BikeDriverLeaning = RotatorToTable(vehicle.BikeDriverLeaning)
  data.Net_VehicleFlags = vehicle.Net_VehicleFlags

  data.WheelAxles = {}
  vehicle.WheelAxles:ForEach(function(index, element)
    table.insert(data.WheelAxles, VehicleWheelAxleToTable(element:get()))
  end)

  -- data.LocalBoundsComponents = vehicle.LocalBoundsComponents
  -- data.LocalBoundsComponentDefaultTransforms = vehicle.LocalBoundsComponentDefaultTransforms
  -- data.VehicleReplicatedMovement = vehicle.VehicleReplicatedMovement
  -- data.VehicleReplicatedMovements = vehicle.VehicleReplicatedMovements
  data.NetLC_VehicleState = VehicleStateToTable(vehicle.NetLC_VehicleState)
  data.NetLC_ColdState = VehicleColdStateToTable(vehicle.NetLC_ColdState)
  data.NetLC_EngineHotState = NetEngineHotStateToTable(vehicle.NetLC_EngineHotState)
  data.NetLC_EngineColdState = {
    bDisabled = vehicle.NetLC_EngineColdState.bDisabled,
    bOverHeated = vehicle.NetLC_EngineColdState.bOverHeated
  }
  data.NetLC_TransmissionColdState = {
    CurrentGear = vehicle.NetLC_TransmissionColdState.CurrentGear
  }

  data.Net_Seats = {}
  vehicle.Net_Seats:ForEach(function(index, element)
    table.insert(data.Net_Seats, {
      SeatName = element:get().SeatName:ToString(),
      Character = element:get().Character.Net_MTPlayerState:IsValid() and
          GuidToString(element:get().Character.Net_MTPlayerState.CharacterGuid) or nil,
      bHasCharacter = element:get().bHasCharacter
    })
  end)

  data.Net_Cargo = {
    CargoWeightKg = vehicle.Net_Cargo.CargoWeightKg,
    LoadedVolumes = vehicle.Net_Cargo.LoadedVolumes,
    MaxVolumes = vehicle.Net_Cargo.MaxVolumes,
    NumCargo = vehicle.Net_Cargo.NumCargo
  }
  data.Net_VehicleOwnerSetting = VehicleOwnerSettingToTable(vehicle.Net_VehicleOwnerSetting)

  data.Net_VehicleSettings = {}
  vehicle.Net_VehicleSettings:ForEach(function(index, element)
    table.insert(data.Net_VehicleSettings, {
      SettingType = element:get().SettingType,
      Value = SettingValueToTable(element:get().Value)
    })
  end)

  data.Customization = VehicleCustomizationToTable(vehicle.Customization)
  data.Net_Decal = VehicleDecalToTable(vehicle.Net_Decal)
  data.Net_OwnerPlayerState = vehicle.Net_OwnerPlayerState:IsValid() and
      GuidToString(vehicle.Net_OwnerPlayerState.CharacterGuid) or nil
  data.Net_OwnerCharacterId = {
    CharacterGuid = GuidToString(vehicle.Net_OwnerCharacterId.CharacterGuid),
    UniqueNetId = vehicle.Net_OwnerCharacterId.UniqueNetId:ToString()
  }
  data.Net_OwnerCompanyGuid = GuidToString(vehicle.Net_OwnerCompanyGuid)
  data.Net_AccountNickname = vehicle.Net_AccountNickname:ToString()
  data.Net_VehicleId = vehicle.Net_VehicleId
  -- data.Server_OwnerPlayerController = vehicle.Server_OwnerPlayerController

  data.Net_Parts = {}
  vehicle.Net_Parts:ForEach(function(index, element)
    table.insert(data.Net_Parts, VehiclePartToTable(element:get()))
  end)

  -- data.UtilitySlots = vehicle.UtilitySlots
  data.Net_AINetData = VehicleAINetStateToTable(vehicle.Net_AINetData)
  -- data.InternalWindowMaterials = vehicle.InternalWindowMaterials
  -- data.LC_InteractionCandidates = vehicle.LC_InteractionCandidates
  data.Laptime = LaptimeModuleToTable(vehicle.Laptime)
  -- data.TrailerHitchSocketComponent = vehicle.TrailerHitchSocketComponent
  data.CurrentRoad = MotorTownRoadToTable(vehicle.CurrentRoad)

  data.Net_Hooks = {}
  vehicle.Net_Hooks:ForEach(function(index, element)
    local tractor = element:get().Tractor
    local trailer = element:get().Trailer
    table.insert(data.Net_Hooks, {
      Tractor = tractor:IsValid() and tractor.Net_VehicleId or nil,
      Trailer = trailer:IsValid() and trailer.Net_VehicleId or nil,
      TractorParams = VehicleHookParamToTable(element:get().TractorParams),
      TrailerParams = VehicleHookParamToTable(element:get().TrailerParams),
    })
  end)

  data.Net_Tractor = vehicle.Net_Tractor:IsValid() and vehicle.Net_Tractor.Net_VehicleId or nil
  data.Net_MovementOwnerPC = GetPlayerGuid(vehicle.Net_MovementOwnerPC)

  data.Server_TempMovementOwnerPCs = {}
  vehicle.Server_TempMovementOwnerPCs:ForEach(function(index, element)
    table.insert(data.Server_TempMovementOwnerPCs, GetPlayerGuid(element:get()))
  end)

  data.Server_LastMovementOwnerPC = GetPlayerGuid(vehicle.Server_LastMovementOwnerPC)
  data.Net_LastNoMovementOwnerPCServerTimeSeconds = vehicle.Net_LastNoMovementOwnerPCServerTimeSeconds
  data.Net_LastMovementOwnerPCName = vehicle.Net_LastMovementOwnerPCName:ToString()
  data.VehicleOwnerProfitShareMultiplier = vehicle.VehicleOwnerProfitShareMultiplier
  -- data.ExplosionDetector = vehicle.ExplosionDetector
  -- data.Server_GarbageCompress = vehicle.Server_GarbageCompress
  data.Server_LastPlayerController = GetPlayerGuid(vehicle.Server_LastPlayerController)
  -- data.IgnoreCollisionComponents = vehicle.IgnoreCollisionComponents
  data.Net_CarCarrierCargoSpace = VehicleCargoSpaceCompToTable(vehicle.Net_CarCarrierCargoSpace)
  data.Net_CompanyGuid = GuidToString(vehicle.Net_CompanyGuid)
  data.Net_CompanyName = vehicle.Net_CompanyName:ToString()
  -- data.OverlappingActors = vehicle.OverlappingActors
  -- data.AreaVolumes = vehicle.AreaVolumes
  -- data.WaterBodies = vehicle.WaterBodies
  data.Net_PTOThrottle = vehicle.Net_PTOThrottle
  data.Net_bPTOOn = vehicle.Net_bPTOOn

  return data
end

---Get all or selected vehicle state(s)
---@param id number?
---@param fields string[]?
---@param limit number?
local function GetVehicles(id, fields, limit)
  local gameState = GetMotorTownGameState()
  local arr = {} ---@type table[]

  if not gameState:IsValid() then return arr end

  for i = 1, #gameState.Vehicles, 1 do
    local vehicle = VehicleToTable(gameState.Vehicles[i])
    local filtered = {}
    if fields then
      for index, value in ipairs(fields) do
        if vehicle[value] == nil then
          error("Field " .. value .. " does not exist")
        end

        filtered[value] = vehicle[value]
      end
      -- Always returns the delivery point guid
      filtered.Net_VehicleId = vehicle.Net_VehicleId

      -- Returns only the selected guid if valid
      if id and id == vehicle.Net_VehicleId then
        return filtered
      end

      table.insert(arr, filtered)
    else
      table.insert(arr, vehicle)
    end

    -- Limit result if set
    if limit and #arr >= limit then
      return arr
    end
  end

  return arr
end

---Despawn selected vehicle
---@param id number
---@param playerGuid string?
local function DespawnVehicleById(id, playerGuid)
  local gameState = GetMotorTownGameState()

  if not gameState:IsValid() then return false end

  local vehicle = CreateInvalidObject()
  ---@cast vehicle AMTVehicle
  for i = 1, #gameState.Vehicles, 1 do
    if gameState.Vehicles[i].Net_VehicleId == id then
      vehicle = gameState.Vehicles[i]
      break
    end
  end

  if not vehicle:IsValid() then return false end

  for i = 1, #gameState.PlayerArray, 1 do
    local playerState = gameState.PlayerArray[i]
    ---@cast playerState AMotorTownPlayerState

    if playerGuid and playerGuid == GuidToString(playerState.CharacterGuid) then
      local PC = playerState:GetPlayerController()
      ---@cast PC AMotorTownPlayerController

      if PC:IsValid() and playerState.bIsAdmin then
        if playerState.bIsHost then
          PC:ServerDespawnVehicle(vehicle, 0)
          return true
        else
          return webhook.CreateServerRequest(
            "/vehicle/" .. id .. "/despawn",
            json.stringify {
              PlayerGuid = playerGuid
            }
          )
        end
      end
    end
  end
  return false
end

-- Console commands

RegisterConsoleCommandHandler("despawnvehicle", function()
  local actor = GetSelectedActor()

  if not actor:IsValid() then
    LogMsg("No actor selected", "ERROR")
    return false
  end

  local vehicleClass = StaticFindObject("/Script/MotorTown.MTVehicle")
  ---@cast vehicleClass UClass

  if not vehicleClass:IsValid() then
    LogMsg("Vehicle class not found", "ERROR")
    return false
  end

  if not actor:IsA(vehicleClass) then
    LogMsg("Selected actor is not a vehicle", "ERROR")
    return false
  end

  if not actor:IsActorBeingDestroyed() then
    ---@cast actor AMTVehicle

    local vehicleName = actor:GetFullName()
    if DespawnVehicleById(actor.Net_VehicleId, GetPlayerGuid(GetMyPlayerController())) then
      LogMsg("Despawned vehicle: " .. vehicleName)
    end
  end
  return true
end)

RegisterConsoleCommandHandler("setvehicleparam", function(Cmd, CommandParts, Ar)
  if not pcall(function()
        local fields = SplitString(table.remove(CommandParts, 1), ".")
        local value = CommandParts[1]

        if not fields then
          LogMsg("No fields value given.", "ERROR")
          return true
        end

        if value == nil then
          LogMsg("No valid value given.", "ERROR")
          return true
        end

        local PC = GetMyPlayerController()
        if PC:IsValid() then
          local pawn = PC:K2_GetPawn()
          local vehicleClass = StaticFindObject("/Script/MotorTown.MTVehicle")
          ---@cast vehicleClass UClass

          if pawn:IsValid() and pawn:IsA(vehicleClass) then
            RecursiveSetValue(pawn, fields, value)
          end
        end
      end) then
    LogMsg("Failed to change " .. CommandParts[2] .. " field for pawn")
  end

  return true
end)

-- HTTP request handler

---Handle the get vehicles commands
---@type RequestPathHandler
local function HandleGetVehicles(session)
  local id = tonumber(session.pathComponents[2]) or nil
  local fields = SplitString(session.queryComponents.filters, ",")
  local limit = tonumber(session.queryComponents.limit) or nil

  local serverStatus = json.stringify {
    data = GetVehicles(id, fields, limit)
  }
  return serverStatus
end

---Handle vehicle despawn request
---@type RequestPathHandler
local function HandleDespawnVehicle(session)
  local id = tonumber(session.pathComponents[2])
  local content = json.parse(session.content)
  local playerGuid = nil

  if content then
    playerGuid = content.PlayerGuid
  end

  if not id then
    return "Invalid vehicle ID", nil, 400
  end

  if DespawnVehicleById(id, playerGuid) then
    return nil, nil, 204
  else
    return "Failed to despawn vehicle", nil, 400
  end
end

return {
  HandleGetVehicles = HandleGetVehicles,
  HandleDespawnVehicle = HandleDespawnVehicle
}
