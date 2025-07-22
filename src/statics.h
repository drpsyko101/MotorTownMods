#pragma once

#include <string>
// Workaround against multiple check definitions
#pragma push_macro("check")
#undef check
#include <boost/json.hpp>
#pragma pop_macro("check")

#include <string>
#include <Unreal/FString.hpp>
#include <Unreal/Transform.hpp>
#include <Unreal/UnrealCoreStructs.hpp>

using namespace RC;
using namespace RC::Unreal;

// Unreal struct base
// Structs inherited from this base should not be used to infer
// value from container/property directy, as the base game
// might change the struct at any time.
struct FStructBase
{
	FStructBase() {};
	FStructBase(UStruct* propertyStruct, void* data);
	virtual ~FStructBase() {};

	virtual boost::json::object ToJson() const;
};

struct FMTCharacterId : public FStructBase
{
	FString UniqueNetId;
	FGuid CharacterGuid;

	FMTCharacterId();
	FMTCharacterId(UStruct* propertyStruct, void* data);

	virtual boost::json::object ToJson() const override;
};

struct FMTShadowedInt64 : public FStructBase
{
	int64 BaseValue = 0;
	int64 ShadowedValue = 0;

	FMTShadowedInt64();
	FMTShadowedInt64(UStruct* propertyStruct, void* data);

	virtual boost::json::object ToJson() const override;
};

struct FMTRoute : public FStructBase
{
	FString RouteName;
	TArray<FTransform> Waypoints;

	FMTRoute();
	FMTRoute(UStruct* propertyStruct, void* data);

	virtual boost::json::object ToJson() const override;
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

	// Convert FGuid to hexadecimal string
	static std::string GuidToString(const FGuid Guid);

	static boost::json::object VectorToJson(const FVector vector);

	static boost::json::object RotatorToJson(const FRotator rotation);

	static boost::json::object QuatToJson(const FQuat rotation);

	static boost::json::object TransformToJson(FTransform transform);

	// Check if mod is running on wine
	static bool IsRunningOnWine();

	// Get webhook URL for external callback
	static const std::string GetWebhookUrl();

	static boost::json::object ObjectToJson(UObject* Object);
};
