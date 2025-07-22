#include "statics.h"
#include "Helpers/String.hpp"
#include <boost/uuid/uuid_io.hpp>
#include <Unreal/Rotator.hpp>
#include <Unreal/UStruct.hpp>
#include <Unreal/FProperty.hpp>
#include <windows.h>
#include <stdio.h>

// Workaround against multiple check definitions
#pragma push_macro("check")
#undef check
#include <boost/algorithm/string.hpp>
#pragma pop_macro("check")

std::wstring ModStatics::ParseJsonObject(boost::json::object object)
{
	return L"{}";
}

std::string ModStatics::GuidToString(const FGuid Guid)
{
	uint32_t dec[4] = { Guid.A, Guid.B, Guid.C, Guid.D };
	std::stringstream ss;
	for (auto elem : dec)
	{
		ss << std::hex << elem;
	}

	return boost::to_upper_copy<std::string>(ss.str());
}

boost::json::object ModStatics::VectorToJson(const FVector vector)
{
	boost::json::object vec;
	vec["X"] = vector.X();
	vec["Y"] = vector.Y();
	vec["Z"] = vector.Z();
	return vec;
}

boost::json::object ModStatics::RotatorToJson(const FRotator rotation)
{
	boost::json::object vec;
	vec["X"] = rotation.GetRoll();
	vec["Y"] = rotation.GetPitch();
	vec["Z"] = rotation.GetYaw();
	return vec;
}

boost::json::object ModStatics::QuatToJson(const FQuat rotation)
{
	boost::json::object vec;
	vec["X"] = rotation.GetX();
	vec["Y"] = rotation.GetY();
	vec["Z"] = rotation.GetZ();
	return vec;
}

boost::json::object ModStatics::TransformToJson(FTransform transform)
{
	boost::json::object obj;
	obj["Translation"] = VectorToJson(transform.GetTranslation());
	obj["Rotation"] = QuatToJson(transform.GetRotation());
	obj["Scale"] = VectorToJson(transform.GetScale3D());
	return obj;
}

bool ModStatics::IsRunningOnWine()
{
	typedef const char* (CDECL* wine_get_version_t)(void);
	wine_get_version_t pwine_get_version;

	HMODULE hntdll = GetModuleHandleA("ntdll.dll");
	if (!hntdll) return false;

	pwine_get_version = reinterpret_cast<wine_get_version_t>(
		GetProcAddress(hntdll, "wine_get_version"));
	if (pwine_get_version)
	{
		return true;
	}

	return false;
}

const std::string ModStatics::GetWebhookUrl()
{
	std::string test = getenv("MOD_WEBHOOK_URL");
	return getenv("MOD_WEBHOOK_URL");
}

FMTCharacterId::FMTCharacterId()
{
}

FMTCharacterId::FMTCharacterId(UStruct* propertyStruct, void* data)
	: FMTCharacterId()
{
	if (propertyStruct == nullptr || data == nullptr) return;
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("UniqueNetId")))
	{
		UniqueNetId = *name->ContainerPtrToValuePtr<FString>(data);
	}
	if (FProperty* guid = propertyStruct->GetPropertyByNameInChain(STR("CharacterGuid")))
	{
		CharacterGuid = *guid->ContainerPtrToValuePtr<FGuid>(data);
	}
}

boost::json::object FMTCharacterId::ToJson() const
{
	boost::json::object obj;
	obj["UniqueNetId"] = RC::to_string(UniqueNetId.GetCharArray());
	obj["CharacterGuid"] = ModStatics::GuidToString(CharacterGuid);
	return obj;
}

FMTShadowedInt64::FMTShadowedInt64()
{
}

FMTShadowedInt64::FMTShadowedInt64(UStruct* propertyStruct, void* data)
	: FMTShadowedInt64()
{
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("BaseValue")))
	{
		BaseValue = *name->ContainerPtrToValuePtr<int64>(data);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("ShadowedValue")))
	{
		ShadowedValue = *name->ContainerPtrToValuePtr<int64>(data);
	}
}

boost::json::object FMTShadowedInt64::ToJson() const
{
	boost::json::object obj;
	obj["BaseValue"] = BaseValue;
	obj["ShadowedValue"] = ShadowedValue;
	return obj;
}

FMTRoute::FMTRoute()
{
}

FMTRoute::FMTRoute(UStruct* propertyStruct, void* data)
{
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("RouteName")))
	{
		RouteName = *name->ContainerPtrToValuePtr<FString>(data);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("Waypoints")))
	{
		Waypoints = *name->ContainerPtrToValuePtr<TArray<FTransform>>(data);
	}
}

boost::json::object FMTRoute::ToJson() const
{
	boost::json::object obj;
	obj["RouteName"] = RC::to_string(RouteName.GetCharArray());
	boost::json::array arr;
	for (const FTransform& transform : Waypoints)
	{
		arr.push_back(ModStatics::TransformToJson(transform));
	}
	obj["Waypoints"] = arr;
	return obj;
}

FStructBase::FStructBase(UStruct* propertyStruct, void* data)
	: FStructBase()
{
}

boost::json::object FStructBase::ToJson() const
{
	return boost::json::object();
}
