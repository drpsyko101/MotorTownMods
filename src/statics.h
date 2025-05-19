#pragma once

// Workaround against multiple check definitions
#pragma push_macro("check")
#undef check
#include <boost/json.hpp>
#pragma pop_macro("check")

#include <string>
#include <boost/uuid/uuid.hpp>
#include <Unreal/FString.hpp>
#include <Unreal/Transform.hpp>
#include <Unreal/UnrealCoreStructs.hpp>

using namespace boost::uuids;
using namespace RC;
using namespace RC::Unreal;

struct FMTCharacterId
{
	FString UniqueNetId;
	FGuid CharacterGuid;

	FMTCharacterId();
	FMTCharacterId(UStruct* propertyStruct, void* data);

	boost::json::object ToJson() const;
};

struct FMTShadowedInt64
{
	int64 BaseValue;
	int64 ShadowedValue;

	boost::json::object ToJson() const;
};

struct FMTRoute
{
	FString RouteName;
	TArray<FTransform> Waypoints;

	FMTRoute();
	FMTRoute(UStruct* propertyStruct, void* data);

	boost::json::object ToJson() const;
};

class ModStatics
{
public:
	ModStatics() {}
	~ModStatics() {}

	// Get current mod name
	static std::wstring GetModName() { return L"MotorTownMods"; }

	// Get current mod version
	static std::wstring GetVersion() { return L"0.1.0"; }

	static std::wstring ParseJsonObject(boost::json::object object);

	static std::string GuidToString(const FGuid Guid);

	static const char* GetWebhookUrl();
};
