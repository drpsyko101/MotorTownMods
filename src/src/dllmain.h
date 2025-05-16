#include <Mod/CppUserModBase.hpp>

using namespace RC;
using namespace RC::Unreal;

class MotorTownMods : public RC::CppUserModBase
{
public:
	MotorTownMods();
	~MotorTownMods() override {};

	auto on_update() -> void override {};

	auto on_unreal_init() -> void override;
};

#define MOTOR_TOWN_MODS_API __declspec(dllexport)
extern "C"
{
	MOTOR_TOWN_MODS_API RC::CppUserModBase* start_mod()
	{
		return new MotorTownMods();
	}

	MOTOR_TOWN_MODS_API void uninstall_mod(RC::CppUserModBase* mod)
	{
		delete mod;
	}
}
