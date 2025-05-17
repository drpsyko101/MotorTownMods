// Workaround against multiple check definitions
#pragma push_macro("check")
#undef check
#include <boost/json.hpp>
#pragma pop_macro("check")

#include <string>

class ModStatics
{
public:
	ModStatics(){}
	~ModStatics(){}

	// Get current mod name
	static std::wstring GetModName() { return L"MotorTownMods"; }

	// Get current mod version
	static std::wstring GetVersion() { return L"0.1.0"; }

	static std::wstring ParseJsonObject(boost::json::object object);
};
