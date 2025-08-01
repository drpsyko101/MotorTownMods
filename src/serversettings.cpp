#include "serversettings.h"

#include <Unreal/UObjectGlobals.hpp>
#include <Unreal/UObject.hpp>
#include <Unreal/Property/FArrayProperty.hpp>
#include <Unreal/Property/FStructProperty.hpp>
#include <Unreal/Core/Containers/ScriptArray.hpp>
#include <Unreal/UScriptStruct.hpp>

static const char* vehicleConfigPath = "/config/spawn/vehicle";

static std::string VehicleSpawnTypeToString(const EMTAIVehicleSpawnType spawnType)
{
	switch (spawnType)
	{
	case EMTAIVehicleSpawnType::TowRequest:
		return "TowRequest";
	case EMTAIVehicleSpawnType::TowRequest_Rescue:
		return "TowRequest_Rescue";
	case EMTAIVehicleSpawnType::TowRequest_Delivery:
		return "TowRequest_Delivery";
	case EMTAIVehicleSpawnType::Getaway:
		return "Getaway";
	default:
		return "None";
	}
}

static std::string VehicleTypeToString(const EMTVehicleType vehicleType)
{
	switch (vehicleType)
	{
	case EMTVehicleType::Kart:
		return "Kart";
	case EMTVehicleType::Small:
		return "Small";
	case EMTVehicleType::Pickup:
		return "Pickup";
	case EMTVehicleType::Bus:
		return "Bus";
	case EMTVehicleType::Truck:
		return "Truck";
	case EMTVehicleType::SemiTractor:
		return "SemiTractor";
	case EMTVehicleType::SemiTrailer:
		return "SemiTrailer";
	case EMTVehicleType::SmallTrailer:
		return "SmallTrailer";
	case EMTVehicleType::Motorhome:
		return "Motorhome";
	case EMTVehicleType::Caravan:
		return "Caravan";
	case EMTVehicleType::HeavyMachinery:
		return "HeavyMachinery";
	case EMTVehicleType::Bike:
		return "Bike";
	case EMTVehicleType::Racecar:
		return "Racecar";
	default:
		return "None";
	}
}

static std::string ScheduleTypeToString(const EMTTimeOfDayScheduleType scheduleType)
{
	switch (scheduleType)
	{
	case EMTTimeOfDayScheduleType::BusPassengerSpawnMultiplayer:
		return "BusPassengerSpawnMultiplayer";
	case EMTTimeOfDayScheduleType::SchoolBusPassengerSpawnMultiplayer:
		return "SchoolBusPassengerSpawnMultiplayer";
	case EMTTimeOfDayScheduleType::Count:
		return "Count";
	default:
		return "None";
	}
}

ServerSettings::ServerSettings()
{
}

bool ServerSettings::IsMatchingRequest(http::request<http::string_body> req)
{
	if (req.target().starts_with(vehicleConfigPath))
	{
		return true;
	}
	return false;
}

json::object ServerSettings::GetResponseJson(http::request<http::string_body> req, http::status& statusCode)
{
	json::object obj;
	if (req.target() == vehicleConfigPath)
	{
		if (req.method() == http::verb::get)
		{
			json::array arr;
			for (const FMTAIVehicleSpawnSetting& data : GetVehicleSpawnSettings())
			{
				arr.push_back(data.ToJson());
			}
			obj["data"] = arr;
			statusCode = http::status::ok;
			return obj;
		}
	}
	return obj;
}

std::vector<FMTAIVehicleSpawnSetting> ServerSettings::GetVehicleSpawnSettings() const
{
	std::vector<FMTAIVehicleSpawnSetting> out_arr;
	std::vector<UObject*> objs;
	UObjectGlobals::FindAllOf(STR("MTAIVehicleSpawnSystem"), objs);
	for (UObject* obj : objs)
	{
		auto paramName = STR("SpawnSettings");
		if (FScriptArray* scrArr = obj->GetValuePtrByPropertyNameInChain<FScriptArray>(
			paramName))
		{
			auto arr = StaticCast<FArrayProperty*>(obj->GetPropertyByNameInChain(paramName));
			const int32_t elemSize = arr->GetInner()->GetElementSize();
			auto str = StaticCast<FStructProperty*>(arr->GetInner());
			for (int32_t i = 0; i < scrArr->Num(); i++)
			{
				const int32 offset = i * elemSize;
				auto elem = static_cast<uint8*>(scrArr->GetData()) + offset;
				FMTAIVehicleSpawnSetting setting(str->GetStruct(), elem);
				out_arr.push_back(setting);
			}
		}
	}

	return out_arr;
}

FMTAIVehicleSpawnSetting::FMTAIVehicleSpawnSetting()
	: SpawnType(EMTAIVehicleSpawnType::None)
	, CountMultiplierScheduleType(EMTTimeOfDayScheduleType::None)
{
}

FMTAIVehicleSpawnSetting::FMTAIVehicleSpawnSetting(UStruct* propertyStruct, void* data)
	: FMTAIVehicleSpawnSetting()
{
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("SettingKey")))
	{
		SettingKey = *prop->ContainerPtrToValuePtr<FName>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("SpawnType")))
	{
		SpawnType = *prop->ContainerPtrToValuePtr<EMTAIVehicleSpawnType>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("VehicleKey")))
	{
		VehicleKey = *prop->ContainerPtrToValuePtr<FName>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("VehicleTypes")))
	{
		VehicleTypes = *prop->ContainerPtrToValuePtr<TArray<EMTVehicleType>>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("bSpawnAIController")))
	{
		bSpawnAIController = *prop->ContainerPtrToValuePtr<bool>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("bIsTrafficVehicle")))
	{
		bIsTrafficVehicle = *prop->ContainerPtrToValuePtr<bool>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("bSpawnRoadSide")))
	{
		bSpawnRoadSide = *prop->ContainerPtrToValuePtr<bool>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("bDespawnIfPlayersAreFar")))
	{
		bDespawnIfPlayersAreFar = *prop->ContainerPtrToValuePtr<bool>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("bAllowCloseToPlayer")))
	{
		bAllowCloseToPlayer = *prop->ContainerPtrToValuePtr<bool>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("bAllowCloseToOtherVehicle")))
	{
		bAllowCloseToOtherVehicle = *prop->ContainerPtrToValuePtr<bool>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("bDespawnIfNotMoveForLong")))
	{
		bDespawnIfNotMoveForLong = *prop->ContainerPtrToValuePtr<bool>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("MaxLifetimeSeconds")))
	{
		MaxLifetimeSeconds = *prop->ContainerPtrToValuePtr<float>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("MaxCount")))
	{
		MaxCount = *prop->ContainerPtrToValuePtr<int32>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("MinCount")))
	{
		MinCount = *prop->ContainerPtrToValuePtr<int32>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("bUseNPCVehicleDensity")))
	{
		bUseNPCVehicleDensity = *prop->ContainerPtrToValuePtr<bool>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("bUseNPCPoliceDensity")))
	{
		bUseNPCPoliceDensity = *prop->ContainerPtrToValuePtr<bool>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("SpawnOverMinCountCoolDownTimeSeconds")))
	{
		SpawnOverMinCountCoolDownTimeSeconds = *prop->ContainerPtrToValuePtr<float>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("CountMultiplierScheduleType")))
	{
		CountMultiplierScheduleType = *prop->ContainerPtrToValuePtr<EMTTimeOfDayScheduleType>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("MinDistanceFromRoad")))
	{
		MinDistanceFromRoad = *prop->ContainerPtrToValuePtr<float>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("MaxDistanceFromRoad")))
	{
		MaxDistanceFromRoad = *prop->ContainerPtrToValuePtr<float>(data);
	}
	if (FProperty* prop = propertyStruct->GetPropertyByNameInChain(STR("bIncludeTrailer")))
	{
		bIncludeTrailer = *prop->ContainerPtrToValuePtr<bool>(data);
	}
}

json::object FMTAIVehicleSpawnSetting::ToJson() const
{
	json::object obj;
	obj["SettingKey"] = to_string(SettingKey.ToString());
	obj["SpawnType"] = VehicleSpawnTypeToString(SpawnType);
	obj["VehicleKey"] = to_string(VehicleKey.ToString());
	json::array arr;
	for (const EMTVehicleType& type : VehicleTypes)
	{
		arr.push_back(VehicleTypeToString(type).c_str());
	}
	obj["VehicleTypes"] = arr;
	obj["bSpawnAIController"] = bSpawnAIController;
	obj["bIsTrafficVehicle"] = bIsTrafficVehicle;
	obj["bSpawnRoadSide"] = bSpawnRoadSide;
	obj["bDespawnIfPlayersAreFar"] = bDespawnIfPlayersAreFar;
	obj["bAllowCloseToPlayer"] = bAllowCloseToPlayer;
	obj["bAllowCloseToOtherVehicle"] = bAllowCloseToOtherVehicle;
	obj["bDespawnIfNotMoveForLong"] = bDespawnIfNotMoveForLong;
	obj["MaxLifetimeSeconds"] = MaxLifetimeSeconds;
	obj["MaxCount"] = MaxCount;
	obj["MinCount"] = MinCount;
	obj["bUseNPCVehicleDensity"] = bUseNPCVehicleDensity;
	obj["bUseNPCPoliceDensity"] = bUseNPCPoliceDensity;
	obj["SpawnOverMinCountCoolDownTimeSeconds"] = SpawnOverMinCountCoolDownTimeSeconds;
	obj["CountMultiplierScheduleType"] = ScheduleTypeToString(CountMultiplierScheduleType);
	obj["MinDistanceFromRoad"] = MinDistanceFromRoad;
	obj["MaxDistanceFromRoad"] = MaxDistanceFromRoad;
	obj["bIncludeTrailer"] = bIncludeTrailer;
	return obj;
}
