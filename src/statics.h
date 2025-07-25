#pragma once

#include <string>
#include <DynamicOutput/Output.hpp>

constexpr std::wstring logLevelToString(RC::LogLevel::LogLevel level) {
	switch (level) {
	case RC::LogLevel::Default: return L"DEFAULT";
	case RC::LogLevel::Normal: return L"NORMAL";
	case RC::LogLevel::Verbose: return L"VERBOSE";
	case RC::LogLevel::Warning: return L"WARNING";
	case RC::LogLevel::Error: return L"ERROR";
	default: return L"UNKNOWN";
	}
}

class ModStatics
{
public:
	ModStatics() {}
	~ModStatics() {}

	// Get current mod name
	static std::wstring GetModName() { return L"MotorTownMods"; }

	// Get current mod version
	static std::wstring GetVersion() { return L"0.1.0"; }

	// Get webhook URL for external callback
	static const std::string GetWebhookUrl();

	// Primary template for the wrapper function
	template<RC::LogLevel::LogLevel Level, typename ...Args>
	inline static auto LogOutput(std::wstring format, Args ...args) -> void
	{
		// Create the formatted message using ostringstream to avoid std::format issues
		std::wstring formatted_message;
		if constexpr (sizeof...(args) > 0) {
			try {
				// Use vformat with make_wformat_args for runtime formatting
				formatted_message = fmt::vformat(fmt::detail::to_string_view(format), fmt::make_format_args<fmt::buffer_context<wchar_t>>(args...));
			}
			catch (...) {
				// Fallback if formatting fails
				formatted_message = format + L" [FORMAT ERROR]";
			}
		}
		else {
			formatted_message = format;
		}

		// Remove trailing newline if present for cleaner prefix formatting
		if (!formatted_message.empty() && formatted_message.back() == L'\n') {
			formatted_message.pop_back();
		}

		std::wstring test = L"LogTest";

		// Create the prefixed format string
		std::wstring prefixed_format = L"[" + GetModName() + L"] " + logLevelToString(Level) + L": " + formatted_message + L"\n";

		RC::Output::send<Level>(prefixed_format);
	}
};
