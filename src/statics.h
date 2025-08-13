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

static std::map<LogLevel::LogLevel, int> levels = {
	{ LogLevel::Error, 0 },
	{ LogLevel::Warning, 1 },
	{ LogLevel::Normal, 2 },
	{ LogLevel::Default, 2 },
	{ LogLevel::Verbose, 3 }
};

constexpr std::wstring logLevelToString(LogLevel::LogLevel level)
{
	switch (level)
	{
	case LogLevel::Default:
		return L"INFO";
	case LogLevel::Normal:
		return L"INFO";
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

struct FMTCharacterId
{
	FString UniqueNetId;
	FGuid CharacterGuid;
};

struct FMTShadowedInt64
{
	int64 BaseValue = 0;
	int64 ShadowedValue = 0;
};

struct FMTRoute
{
	FString RouteName;
	TArray<FTransform> Waypoints;
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

	static int GetLogLevel();

	// Convert FGuid to hexadecimal string
	static std::string GuidToString(const FGuid Guid);

	static boost::json::object VectorToJson(const FVector vector);

	static boost::json::object RotatorToJson(const FRotator rotation);

	static boost::json::object QuatToJson(const FQuat rotation);

	static boost::json::object TransformToJson(FTransform transform);

	// Check if mod is running on wine
	static bool IsRunningOnWine();

	static int GetLogLevel();

	// Convert string to FGuid
	static FGuid StringToGuid(const std::string Guid);

	// Get webhook URL for external callback
	static const std::string GetWebhookUrl();

	// Primary template for the wrapper function
	template <LogLevel::LogLevel Level = LogLevel::Default, typename... Args>
	inline static auto LogOutput(std::wstring format, Args... args) -> void
	{
		// Limit output log to the given level
		const int lvl = GetLogLevel();
		if (levels[Level] > lvl) return;

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
		const int32 depth = 0);

	static boost::json::object ObjectToJson(UObject* Object, const std::wstring Field = L"", std::wstring ClassName = L"", const int depth = 1);
	static boost::json::object StructToJson(UStruct* Object, void* Data);

private:
	static void PropertyToJson(FProperty* Property, void* Data, boost::json::object& Object, const int depth = 1);
	static void PropertyToJson(FProperty* Property, void* Data, boost::json::value& Object, const int depth = 1);
	static void PropertyToJson(FProperty* Property, void* Data, std::string& Object);
};
