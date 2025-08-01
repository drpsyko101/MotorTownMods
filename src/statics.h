#pragma once

// Workaround against multiple check definitions
#pragma push_macro("check")
#undef check
#include <boost/json.hpp>
#pragma pop_macro("check")

#include <string>
#include <Unreal/FString.hpp>
#include <Unreal/Transform.hpp>
#include <DynamicOutput/Output.hpp>
#include <Unreal/UnrealCoreStructs.hpp>
#include <LuaMadeSimple/LuaMadeSimple.hpp>

using namespace RC;
using namespace RC::Unreal;
using namespace RC::LuaMadeSimple;

constexpr std::wstring logLevelToString(LogLevel::LogLevel level)
{
	switch (level)
	{
	case LogLevel::Default:
		return L"DEFAULT";
	case LogLevel::Normal:
		return L"NORMAL";
	case LogLevel::Verbose:
		return L"VERBOSE";
	case LogLevel::Warning:
		return L"WARNING";
	case LogLevel::Error:
		return L"ERROR";
	default:
		return L"UNKNOWN";
	}
}

enum PropertyType
{
	None = 0,
	Array,
	Map,
};

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

	// Primary template for the wrapper function
	template <LogLevel::LogLevel Level = LogLevel::Verbose, typename... Args>
	inline static auto LogOutput(std::wstring format, Args... args) -> void
	{
		// Create the formatted message using ostringstream to avoid std::format issues
		std::wstring formatted_message;
		if constexpr (sizeof...(args) > 0)
		{
			try
			{
				// Use vformat with make_wformat_args for runtime formatting
				formatted_message = fmt::vformat(
					fmt::detail::to_string_view(format),
					fmt::make_format_args<fmt::buffer_context<wchar_t>>(args...));
			}
			catch (...)
			{
				// Fallback if formatting fails
				formatted_message = format + L" [FORMAT ERROR]";
			}
		}
		else
		{
			formatted_message = format;
		}

		// Remove trailing newline if present for cleaner prefix formatting
		if (!formatted_message.empty() && formatted_message.back() == L'\n')
		{
			formatted_message.pop_back();
		}

		std::wstring test = L"LogTest";

		// Create the prefixed format string
		std::wstring prefixed_format = L"[C++] [" + GetModName() + L"] " + logLevelToString(Level) + L": " + formatted_message + L"\n";

		Output::send<Level>(prefixed_format);
	}

	/**
	 * Convert a property to a Lua table
	 * @param property Reference to the pointer to export
	 * @param data Outer property object, usually the container of the property
	 * @param table Lua table to place the property into
	 */
	static void ExportPropertyAsTable(
		FProperty* property,
		void* data,
		Lua::Table& table,
		const PropertyType propertyType = PropertyType::None,
		const bool convertObject = false,
		const int32 depth = 3);
	static boost::json::object ObjectToJson(UObject* Object);
};
