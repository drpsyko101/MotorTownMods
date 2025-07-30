#include "dllmain.h"

#include <Mod/CppUserModBase.hpp>
#include <LuaType/LuaUObject.hpp>

#include "webserver.h"
#include "statics.h"

using namespace RC;
using namespace RC::Unreal;

MotorTownMods::MotorTownMods()
	: CppUserModBase()
{
	ModName = ModStatics::GetModName();
	ModVersion = ModStatics::GetVersion();
	ModDescription = STR("Mods for Motor Town and Motor Town dedicated server");
	ModAuthors = STR("drpsyko101");
	// Do not change this unless you want to target a UE4SS version
	// other than the one you're currently building with somehow.
	// ModIntendedSDKVersion = STR("2.6");

	Output::send<LogLevel::Verbose>(STR("[{}] mod loaded\n"), ModName);
}

auto MotorTownMods::on_unreal_init() -> void
{
	// Init API server
	auto server = Webserver::Get();
}

auto MotorTownMods::on_lua_start(
	LuaMadeSimple::Lua& lua,
	LuaMadeSimple::Lua& main_lua,
	LuaMadeSimple::Lua& async_lua,
	std::vector<LuaMadeSimple::Lua*>& hook_luas) -> void
{
	lua.register_function(
		"ExportStructAsText",
		[](const LuaMadeSimple::Lua& lua_net) -> int
		{
			int32_t stack_size = lua_net.get_stack_size();

			if (stack_size <= 1)
			{
				lua_net.throw_error("Function 'UScriptStruct:GetStructTextItem' cannot be called with 1 parameters.");
			}

			auto& object = lua_net.get_userdata<RC::LuaType::UObject>();
			auto propName = lua_net.get_string();
			auto ptr = object.get_remote_cpp_object();
			if (ptr)
			{
				auto uniqueIdProp = static_cast<FStructProperty*>(ptr->GetPropertyByNameInChain(to_wstring(propName).c_str()));
				if (uniqueIdProp)
				{
					auto uniqueIdStruct = uniqueIdProp->GetStruct();
					auto uniqueId = uniqueIdProp->ContainerPtrToValuePtr<void>(ptr);

					FString uniqueIdString;
					uniqueIdProp->ExportTextItem(uniqueIdString, uniqueId, nullptr, ptr, 0);
					lua_net.set_string(to_string(uniqueIdString.GetCharArray()));
					return 1;
				}
			}
			lua_net.set_string("");

			return 1;
		});

	lua.register_function(
		"GetObjectVariables",
		[](const LuaMadeSimple::Lua& _lua) -> int
		{
			const int stack_size = _lua.get_stack_size();
			if (stack_size < 1)
			{
				_lua.throw_error("Function 'UScriptStruct:GetStructTextItem' cannot be called with 0 parameters.");
			}

			// Get the UOject from the 1st parameter
			auto& object = _lua.get_userdata<RC::LuaType::UObject>();
			auto ptr = object.get_remote_cpp_object();

			std::wstring propertyName, className;
			int32 depth = 2;

			// Parse parameter values
			if (_lua.is_integer(3)) depth = _lua.get_integer(3);
			if (_lua.is_string(2)) className = to_wstring(_lua.get_string(2));
			if (_lua.is_string()) propertyName = to_wstring(_lua.get_string());

			for (int i = 0; i < _lua.get_stack_size(); i++)
			{
				_lua.discard_value();
			}

			auto table = _lua.prepare_new_table();
			table.set_has_userdata(false);

			if (ptr)
			{
				auto ptrClass = ptr->GetClassPrivate();
				if (!propertyName.empty())
				{
					auto prop = ptr->GetPropertyByNameInChain(propertyName.c_str());
					if (prop)
					{
						// Allow object conversion only when parameter name is specified
						ModStatics::ExportPropertyAsTable(prop, ptr, table, PropertyType::None, true, depth);
					}
					else
					{
						_lua.throw_error("Property name " + to_string(propertyName) + " invalid");
					}
				}
				else
				{
					for (FProperty* prop = ptrClass->GetPropertyLink(); prop; prop = prop->GetPropertyLinkNext())
					{
						if (className.empty())
						{
							className = ptrClass->GetName();
						}

						// Crude way to check the owner class since FProperty::GetOwnerClass isn't supported
						if (prop->GetFullName().contains(className))
						{
							ModStatics::ExportPropertyAsTable(prop, ptr, table, PropertyType::None, false, depth);
						}
					}
				}
			}

			table.make_local();
			return 1;
		});

	lua.register_function(
		"NativeSleep",
		[](const LuaMadeSimple::Lua& _lua)
		{
			if (!_lua.is_integer())
			{
				_lua.throw_error("Sleep function only accept an integer parameter.");
			}

			const int duration = _lua.get_integer();
			Sleep(duration);
			return 1;
		});
}
