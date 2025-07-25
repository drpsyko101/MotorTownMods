#include "dllmain.h"

#include <Mod/CppUserModBase.hpp>
#include <DynamicOutput/DynamicOutput.hpp>
#include <Unreal/UObjectGlobals.hpp>
#include <Unreal/UObject.hpp>
#include <Unreal/UScriptStruct.hpp>
#include <Unreal/UnrealCoreStructs.hpp>
#include <Unreal/Property/FStructProperty.hpp>
#include <Unreal/Property/FStrProperty.hpp>
#include <Unreal/Property/FNameProperty.hpp>
#include <Unreal/Property/FTextProperty.hpp>
#include <Unreal/Property/NumericPropertyTypes.hpp>
#include <Unreal/Property/FBoolProperty.hpp>
#include <Unreal/Property/FArrayProperty.hpp>
#include <Unreal/Property/FEnumProperty.hpp>
#include <Unreal/Property/FObjectProperty.hpp>
#include <Unreal/Property/FMapProperty.hpp>
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

enum PropertyType {
	None = 0,
	Array,
	Map,
};

static void get_variable_as_table(
	FProperty* property,
	void* data,
	LuaMadeSimple::Lua::Table& table,
	const PropertyType propertyType = PropertyType::None,
	const bool convertObject = false)
{
	if (property)
	{
		auto propName = to_string(property->GetName());
		std::wstring propWName = to_wstring(property->GetName());
		std::wstring propClass = to_wstring(property->GetClass().GetName());
		if (property->IsA<FStrProperty>())
		{
			auto propertyValue = property->ContainerPtrToValuePtr<FString>(data);
			const auto str = propertyValue->GetCharArray();
			switch (propertyType)
			{
			case PropertyType::Array:
				table.add_value(to_string(str).c_str());
				break;
			case PropertyType::Map:
				table.add_key(to_string(str).c_str());
				break;
			default:
				table.add_pair(propName.c_str(), to_string(str).c_str());
			}
		}
		else if (property->IsA<FNameProperty>())
		{
			auto propertyValue = property->ContainerPtrToValuePtr<FName>(data);
			const auto str = propertyValue->ToString();
			switch (propertyType)
			{
			case PropertyType::Array:
				table.add_value(to_string(str).c_str());
				break;
			case PropertyType::Map:
				table.add_key(to_string(str).c_str());
				break;
			default:
				table.add_pair(propName.c_str(), to_string(str).c_str());
			}
		}
		else if (property->IsA<FTextProperty>())
		{
			auto propertyValue = property->ContainerPtrToValuePtr<FText>(data);
			const auto str = propertyValue->ToString();
			switch (propertyType)
			{
			case PropertyType::Array:
				table.add_value(to_string(str).c_str());
				break;
			case PropertyType::Map:
				table.add_key(to_string(str).c_str());
				break;
			default:
				table.add_pair(propName.c_str(), to_string(str).c_str());
			}
		}
		else if (property->IsA<FFloatProperty>())
		{
			const auto propertyValue = *property->ContainerPtrToValuePtr<float>(data);
			switch (propertyType)
			{
			case PropertyType::Array:
				table.add_value(propertyValue);
				break;
			case PropertyType::Map:
				table.add_key(propertyValue);
				break;
			default:
				table.add_pair(propName.c_str(), propertyValue);
			}
		}
		else if (property->IsA<FDoubleProperty>())
		{
			const auto propertyValue = *property->ContainerPtrToValuePtr<double>(data);
			switch (propertyType)
			{
			case PropertyType::Array:
				table.add_value(propertyValue);
				break;
			case PropertyType::Map:
				table.add_key(propertyValue);
				break;
			default:
				table.add_pair(propName.c_str(), propertyValue);
			}
		}
		else if (property->IsA<FIntProperty>() || property->IsA<FEnumProperty>() || property->IsA<FInt64Property>() || property->IsA<FUInt32Property>())
		{
			const auto propertyValue = *property->ContainerPtrToValuePtr<int>(data);
			switch (propertyType)
			{
			case PropertyType::Array:
				table.add_value(propertyValue);
				break;
			case PropertyType::Map:
				table.add_key(propertyValue);
				break;
			default:
				table.add_pair(propName.c_str(), propertyValue);
			}
		}
		else if (property->IsA<FBoolProperty>())
		{
			const auto propertyValue = *property->ContainerPtrToValuePtr<bool>(data);
			switch (propertyType)
			{
			case PropertyType::Array:
				table.add_value(propertyValue);
				break;
			case PropertyType::Map:
				table.add_key(propertyValue);
				break;
			default:
				table.add_pair(propName.c_str(), propertyValue);
			}
		}
		else if (property->IsA<FStructProperty>())
		{
			// Table::add_key only supports char, int, unsigned int
			if (propertyType == PropertyType::Map) throw std::format_error("Unable to set struct as TMap key");

			auto _prop = static_cast<FStructProperty*>(property);
			auto _struct = _prop->GetStruct();
			auto structName = _struct->GetName();

			if (structName == STR("Vector"))
			{

				auto propertyValue = property->ContainerPtrToValuePtr<FVector>(data);
				if (propertyValue)
				{
					if (propertyType != PropertyType::Array) table.add_key(propName.c_str());

					auto inner_table = table.get_lua_instance().prepare_new_table();
					inner_table.add_pair("X", propertyValue->GetX());
					inner_table.add_pair("Y", propertyValue->GetY());
					inner_table.add_pair("Z", propertyValue->GetZ());
					inner_table.make_local();

					if (propertyType != PropertyType::Array) table.fuse_pair();
				}
			}
			else if (structName == STR("Rotator"))
			{
				auto propertyValue = property->ContainerPtrToValuePtr<FRotator>(data);

				if (propertyType != PropertyType::Array) table.add_key(propName.c_str());

				auto inner_table = table.get_lua_instance().prepare_new_table();
				inner_table.add_pair("Pitch", propertyValue->GetPitch());
				inner_table.add_pair("Roll", propertyValue->GetRoll());
				inner_table.add_pair("Yaw", propertyValue->GetYaw());
				inner_table.make_local();

				if (propertyType != PropertyType::Array) table.fuse_pair();
			}
			else if (structName == STR("Guid"))
			{
				FString value;
				auto propertyValue = property->ContainerPtrToValuePtr<void>(data);
				property->ExportTextItem(value, propertyValue, nullptr, static_cast<UObject*>(data), 0);
				switch (propertyType)
				{
				case PropertyType::Array:
					table.add_value(to_string(value.GetCharArray()).c_str());
					break;
				default:
					table.add_pair(propName.c_str(), to_string(value.GetCharArray()).c_str());
				}
			}
			else
			{
				auto propertyValue = property->ContainerPtrToValuePtr<void>(data);
				auto structProp = static_cast<FStructProperty*>(property);

				if (propertyType != PropertyType::Array) table.add_key(propName.c_str());

				if (propertyValue && structProp)
				{
					auto inner_table = table.get_lua_instance().prepare_new_table();
					for (FProperty* innerProp = structProp->GetStruct()->GetPropertyLink(); innerProp; innerProp = innerProp->GetPropertyLinkNext())
					{
						get_variable_as_table(innerProp, propertyValue, inner_table);
					}
					inner_table.make_local();
				}

				if (propertyType != PropertyType::Array) table.fuse_pair();
			}
		}
		else if (property->IsA<FArrayProperty>())
		{
			if (propertyType == PropertyType::Map) throw std::format_error("Unable to set array as TMap key");

			auto _prop = static_cast<FArrayProperty*>(property);
			auto propertyValue = property->ContainerPtrToValuePtr<FScriptArray>(data);
			if (propertyValue)
			{
				auto innerProp = _prop->GetInner();
				const int32 elemSize = innerProp->GetElementSize();
				const int32 arrayCount = propertyValue->Num();

				table.add_key(propName.c_str());
				auto inner_table = table.get_lua_instance().prepare_new_table();

				if (arrayCount > 0)
				{
					for (int32_t i = 0; i < arrayCount; i++)
					{
						inner_table.add_key(i + 1);
						const int32 offset = i * elemSize;
						auto elem = static_cast<uint8*>(propertyValue->GetData()) + offset;
						get_variable_as_table(innerProp, elem, inner_table, PropertyType::Array);
						inner_table.fuse_pair();
					}
				}
				else
				{
					std::vector<int> empty;
					inner_table.vector_to_table(empty);
				}
				inner_table.make_local();
				table.fuse_pair();
			}
		}
		else if (property->IsA<FObjectProperty>())
		{
			if (propertyType == PropertyType::Map) throw std::format_error("Unable to set object as TMap key");
			if (propertyType == PropertyType::Array && !convertObject) throw std::format_error("Unable to explicitly iterate array");

			if (convertObject)
			{
				auto propertyValue = property->ContainerPtrToValuePtr<UObject>(data);
				auto propertyClass = propertyValue->GetClassPrivate();

				if (propertyType != PropertyType::Array) table.add_key(propName.c_str());

				auto innerTable = table.get_lua_instance().prepare_new_table();
				for (FProperty* innerProp = propertyClass->GetPropertyLink(); innerProp; innerProp = innerProp->GetPropertyLinkNext())
				{
					get_variable_as_table(innerProp, propertyValue, innerTable);
				}
				innerTable.make_local();

				if (propertyType != PropertyType::Array) table.fuse_pair();
			}
		}
		else if (property->IsA<FMapProperty>())
		{
			if (propertyType == PropertyType::Map) throw std::format_error("Unable to set TMap as TMap key");
			if (propertyType == PropertyType::Array) throw std::format_error("Unable to iterate TMap");

			auto innerProp = static_cast<FMapProperty*>(property);
			auto propertyValue = property->ContainerPtrToValuePtr<FScriptMap>(data);

			if (innerProp && propertyValue)
			{
				table.add_key(propName.c_str());
				auto innerTable = table.get_lua_instance().prepare_new_table();

				const int32 mapSize = propertyValue->GetMaxIndex();

				if (mapSize > 0)
				{
					auto keyProp = innerProp->GetKeyProp();
					auto valueProp = innerProp->GetValueProp();
					try
					{
						auto layout = Unreal::FScriptMap::GetScriptLayout(
							keyProp->GetSize(),
							keyProp->GetMinAlignment(),
							valueProp->GetSize(),
							valueProp->GetMinAlignment());

						for (int32 i = 0; i < mapSize; i++)
						{
							auto elem = static_cast<uint8*>(propertyValue->GetData(i, layout));
							get_variable_as_table(keyProp, elem, innerTable, PropertyType::Map);
							try
							{
								get_variable_as_table(valueProp, elem, innerTable, PropertyType::Array, convertObject);
							}
							catch (const std::exception& e)
							{
								ModStatics::LogOutput<LogLevel::Warning>(L"Unable to parse TMap value: {}", to_wstring(e.what()));
								std::vector<int> empty;
								auto emptyInnerTable = innerTable.get_lua_instance().prepare_new_table();
								emptyInnerTable.vector_to_table(empty);
							}
							innerTable.fuse_pair();
						}
					}
					catch (std::exception& err)
					{
						ModStatics::LogOutput<LogLevel::Warning>(
							L"Unable to parse TMap {} with key {} value {}: {}",
							propWName,
							keyProp->GetClass().GetName(),
							valueProp->GetClass().GetName(),
							to_wstring(err.what()));

						std::vector<int> empty;
						innerTable.vector_to_table(empty);
					}
				}
				else
				{
					std::vector<int> empty;
					innerTable.vector_to_table(empty);
				}
				innerTable.make_local();
				table.fuse_pair();
			}
			else
			{
				ModStatics::LogOutput<LogLevel::Warning>(L"Unable to parse {} of type {}", propWName, propClass);
			}
		}
		else
		{
			if (propertyType == PropertyType::Map) throw std::format_error("Unable to set anything as TMap key");
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

		// Get the UOject from the 1st parameter
		auto& object = _lua.get_userdata<RC::LuaType::UObject>();
		auto ptr = object.get_remote_cpp_object();

		std::wstring propertyName, className;
		if (_lua.is_string())
		{
			// Set the property name from 2nd parameter
			propertyName = to_wstring(_lua.get_string());
			if (_lua.is_string())
			{
				// Get the class short name from the 3rd paramenter
				className = to_wstring(_lua.get_string());
			}
		}
		else if (_lua.is_nil() && _lua.is_string(2))
		{
			// Get the class short name from the 3rd paramenter if 2nd parameter empty
			className = to_wstring(_lua.get_string(2));
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
					get_variable_as_table(prop, ptr, table, PropertyType::None, true);
				}
				else
				{
					_lua.throw_error("Property name " + to_string(propertyName));
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
					if (prop->GetFullName().contains(className))
					{
						get_variable_as_table(prop, ptr, table);
					}
				}
			}
		}

		table.make_local();
		return 1;
		});
}
