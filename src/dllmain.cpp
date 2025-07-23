#include "dllmain.h"

#include <Mod/CppUserModBase.hpp>
#include <DynamicOutput/DynamicOutput.hpp>
#include <Unreal/UObjectGlobals.hpp>
#include <Unreal/UObject.hpp>
#include <Unreal/UScriptStruct.hpp>
#include <Unreal/Property/FStructProperty.hpp>
#include <Unreal/Property/FStrProperty.hpp>
#include <Unreal/Property/FNameProperty.hpp>
#include <Unreal/Property/FTextProperty.hpp>
#include <Unreal/Property/NumericPropertyTypes.hpp>
#include <Unreal/Property/FBoolProperty.hpp>
#include <Unreal/AGameModeBase.hpp>
#include <LuaMadeSimple/LuaMadeSimple.hpp>
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
	//ModIntendedSDKVersion = STR("2.6");

	Output::send<LogLevel::Verbose>(STR("[{}] mod loaded\n"), ModName);
}

auto MotorTownMods::on_unreal_init() -> void
{
	// Init API server
	auto server = Webserver::Get();
}

static void get_variable_as_table(FProperty* property, UObject* data, LuaMadeSimple::Lua::Table& table)
{
	if (property)
	{
		auto propName = to_string(property->GetName());
		if (auto _prop = CastField<FStrProperty>(property))
		{
			table.add_pair(propName.c_str(), to_string(_prop->GetPropertyValue(data).GetCharArray()).c_str());
		}
		else if (auto _prop = CastField<FNameProperty>(property))
		{
			//auto& name = _prop->GetPropertyValue(data);
			//const auto str = name.ToString(); // Crashed when accessing ToString function
			//table.add_pair(propName.c_str(), to_string(str).c_str());

			auto propertyValue = property->ContainerPtrToValuePtr<FName>(data);
			const auto str = propertyValue->ToString();
			table.add_pair(propName.c_str(), to_string(str).c_str());
		}
		else if (auto _prop = CastField<FTextProperty>(property))
		{
			table.add_pair(propName.c_str(), to_string(_prop->GetPropertyValue(data).ToString()).c_str());
		}
		else if (auto _prop = CastField<FFloatProperty>(property))
		{
			table.add_pair(propName.c_str(), _prop->GetPropertyValue(data));
		}
		else if (auto _prop = CastField<FDoubleProperty>(property))
		{
			table.add_pair(propName.c_str(), _prop->GetPropertyValue(data));
		}
		else if (auto _prop = CastField<FIntProperty>(property))
		{
			table.add_pair(propName.c_str(), _prop->GetPropertyValue(data));
		}
		else if (auto _prop = CastField<FInt64Property>(property))
		{
			table.add_pair(propName.c_str(), _prop->GetPropertyValue(data));
		}
		else if (auto _prop = CastField<FByteProperty>(property))
		{
			table.add_pair(propName.c_str(), static_cast<int>(_prop->GetPropertyValue(data)));
		}
		else if (auto _prop = CastField<FBoolProperty>(property))
		{
			table.add_pair(propName.c_str(), false);
		}
		else
		{
			std::wstring propWName = to_wstring(property->GetName());
			std::wstring propClass = to_wstring(property->GetClass().GetName());
			ModStatics::LogOutput<LogLevel::Warning>(L"Unable to parse {} of type {}", propWName, propClass);
		}
	}
}

auto MotorTownMods::on_lua_start(
	LuaMadeSimple::Lua& lua,
	LuaMadeSimple::Lua& main_lua,
	LuaMadeSimple::Lua& async_lua,
	std::vector<LuaMadeSimple::Lua*>& hook_luas) -> void
{
	lua.register_function("ExportStructAsText", [](const LuaMadeSimple::Lua& lua_net) -> int {
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

	lua.register_function("GetObjectVariables", [](const LuaMadeSimple::Lua& _lua) -> int {
		const int stack_size = _lua.get_stack_size();
		if (stack_size < 1)
		{
			_lua.throw_error("Function 'UScriptStruct:GetStructTextItem' cannot be called with 0 parameters.");
		}

		auto& object = _lua.get_userdata<RC::LuaType::UObject>();
		auto ptr = object.get_remote_cpp_object();
		auto table = _lua.prepare_new_table();
		table.set_has_userdata(false);

		if (ptr)
		{
			auto ptrClass = ptr->GetClassPrivate();
			if (stack_size >= 2 && _lua.is_string())
			{
				std::string_view param = _lua.get_string();
				auto prop = ptr->GetPropertyByNameInChain(to_wstring(param).c_str());
				get_variable_as_table(prop, ptr, table);
			}
			else
			{
				for (FProperty* prop = ptrClass->GetPropertyLink(); prop; prop = prop->GetPropertyLinkNext())
				{
					if (prop->GetFullName().contains(ptrClass->GetName()))
					{
						get_variable_as_table(prop, ptr, table);
					}
					else
					{
						break; // Assume the next property link is super properties
					}
				}
			}
		}

		table.make_local();
		return 1;
		});
	lua.register_function("Test", [](const LuaMadeSimple::Lua& _lua) -> int {
		auto& object = _lua.get_userdata<LuaType::UObject>();
		auto object_ptr = object.get_remote_cpp_object();

		if (object_ptr)
		{
			auto name = object_ptr->GetValuePtrByPropertyName<FName>(STR("VehicleKey"));
			if (name)
			{
				const auto str = name->ToString();
				Output::send<LogLevel::Verbose>(STR("value: {}\n"), str);
				_lua.set_string(to_string(str).c_str());
				return 1;
			}
		}
		_lua.set_string("");
		return 1;
		});
}
