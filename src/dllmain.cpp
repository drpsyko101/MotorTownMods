#include "dllmain.h"
#include <Mod/CppUserModBase.hpp>
#include <DynamicOutput/DynamicOutput.hpp>
#include <Unreal/UObjectGlobals.hpp>
#include <Unreal/UObject.hpp>
#include <Unreal/AGameModeBase.hpp>
#include "webserver.h"
#include "statics.h"

using namespace RC;
using namespace RC::Unreal;

MotorTownMods::MotorTownMods()
	: CppUserModBase()
{
	ModName = *ModStatics::GetModName();
	ModVersion = *ModStatics::GetVersion();
	ModDescription = STR("Mods for Motor Town and Motor Town dedicated server");
	ModAuthors = STR("drpsyko101");
	// Do not change this unless you want to target a UE4SS version
	// other than the one you're currently building with somehow.
	//ModIntendedSDKVersion = STR("2.6");

	Webserver* server = Webserver::Get();

	Output::send<LogLevel::Verbose>(STR("{} mod loaded\n"), ModName);
}

auto MotorTownMods::on_unreal_init() -> void 
{
	// You are allowed to use the 'Unreal' namespace in this function and anywhere else after this function has fired.
	auto Object = UObjectGlobals::StaticFindObject<UObject*>(nullptr, nullptr, STR("/Script/CoreUObject.Object"));
	Output::send<LogLevel::Verbose>(STR("Object Name: {}\n"), Object->GetFullName());
}
