#include "statics.h"
#include <Unreal/UObjectGlobals.hpp>
#include <Unreal/UObject.hpp>
#include <Unreal/UScriptStruct.hpp>
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
#include <Unreal/Property/FSetProperty.hpp>
#include <LuaType/LuaUObject.hpp>
#include "Helpers/String.hpp"
#include <boost/uuid/uuid_io.hpp>
#include <Unreal/Rotator.hpp>
#include <Unreal/UStruct.hpp>
#include <Unreal/UClass.hpp>
#include <windows.h>
#include <stdio.h>

// Workaround against multiple check definitions
#pragma push_macro("check")
#undef check
#include <boost/algorithm/string.hpp>
#pragma pop_macro("check")

std::string ModStatics::GuidToString(const FGuid Guid)
{
	uint32_t dec[4] = { Guid.A, Guid.B, Guid.C, Guid.D };
	std::stringstream ss;
	for (auto elem : dec)
	{
		ss << std::hex << elem;
	}

	return boost::to_upper_copy<std::string>(ss.str());
}

FGuid ModStatics::StringToGuid(const std::string Guid)
{
	std::vector<uint32_t> guids;
	FGuid guid;
	for (int i = 0; i < 4; i++) {
		std::string segment = Guid.substr(i * 8, 8);
		guids.push_back(static_cast<unsigned int>(std::stoul(segment, nullptr, 16)));
	}
	guid.A = guids[0];
	guid.B = guids[1];
	guid.C = guids[2];
	guid.D = guids[3];
	return FGuid();
}

boost::json::object ModStatics::VectorToJson(const FVector vector)
{
	boost::json::object vec;
	vec["X"] = vector.X();
	vec["Y"] = vector.Y();
	vec["Z"] = vector.Z();
	return vec;
}

boost::json::object ModStatics::RotatorToJson(const FRotator rotation)
{
	boost::json::object vec;
	vec["X"] = rotation.GetRoll();
	vec["Y"] = rotation.GetPitch();
	vec["Z"] = rotation.GetYaw();
	return vec;
}

boost::json::object ModStatics::QuatToJson(const FQuat rotation)
{
	boost::json::object vec;
	vec["X"] = rotation.GetX();
	vec["Y"] = rotation.GetY();
	vec["Z"] = rotation.GetZ();
	return vec;
}

boost::json::object ModStatics::TransformToJson(FTransform transform)
{
	boost::json::object obj;
	obj["Translation"] = VectorToJson(transform.GetTranslation());
	obj["Rotation"] = QuatToJson(transform.GetRotation());
	obj["Scale"] = VectorToJson(transform.GetScale3D());
	return obj;
}

bool ModStatics::IsRunningOnWine()
{
	typedef const char* (CDECL* wine_get_version_t)(void);
	wine_get_version_t pwine_get_version;

	HMODULE hntdll = GetModuleHandleA("ntdll.dll");
	if (!hntdll) return false;

	pwine_get_version = reinterpret_cast<wine_get_version_t>(
		GetProcAddress(hntdll, "wine_get_version"));
	if (pwine_get_version)
	{
		return true;
	}

	return false;
}

int ModStatics::GetLogLevel()
{
	const auto lvl = std::getenv("MOD_SERVER_LOG_LEVEL");
	if (lvl) return std::atoi(lvl);

	return 2;
}

int ModStatics::GetLogLevel()
{
	const auto lvl = std::getenv("MOD_SERVER_LOG_LEVEL");
	if (lvl) return std::atoi(lvl);

	return 2;
}

const std::string ModStatics::GetWebhookUrl()
{
	std::string test = getenv("MOD_WEBHOOK_URL");
	return getenv("MOD_WEBHOOK_URL");
}

void ModStatics::ExportPropertyAsTable(
	FProperty* property,
	void* data,
	Lua::Table& table,
	const PropertyType propertyType,
	const int32 depth)
{
	if (!property) return;

	// Limit recursive depth search
	std::vector<int> empty;
	if (depth < 0)
	{
		throw std::format_error("Depth limit reached");
	}

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
			table.add_key(std::to_string(propertyValue));
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
			table.add_key(std::to_string(propertyValue));
			break;
		default:
			table.add_pair(propName.c_str(), propertyValue);
		}
	}
	else if (property->IsA<FIntProperty>() || property->IsA<FInt64Property>() || property->IsA<FUInt32Property>() || property->IsA<FInt8Property>() || property->IsA<FInt16Property>())
	{
		const auto propertyValue = *property->ContainerPtrToValuePtr<int>(data);
		switch (propertyType)
		{
		case PropertyType::Array:
			table.add_value(propertyValue);
			break;
		case PropertyType::Map:
			table.add_key(std::to_string(propertyValue));
			break;
		default:
			table.add_pair(propName.c_str(), propertyValue);
		}
	}
	else if (property->IsA<FEnumProperty>() || property->IsA<FByteProperty>())
	{
		const auto propertyValueRaw = *property->ContainerPtrToValuePtr<uint8>(data);
		const int propertyValue = static_cast<int>(propertyValueRaw);
		switch (propertyType)
		{
		case PropertyType::Array:
			table.add_value(propertyValue);
			break;
		case PropertyType::Map:
			table.add_key(std::to_string(propertyValue).c_str());
			break;
		default:
			table.add_pair(propName.c_str(), propertyValue);
		}
	}
	else if (property->IsA<FUInt16Property>())
	{
		const auto propertyValueRaw = *property->ContainerPtrToValuePtr<uint16>(data);
		const int propertyValue = static_cast<int>(propertyValueRaw);
		switch (propertyType)
		{
		case PropertyType::Array:
			table.add_value(propertyValue);
			break;
		case PropertyType::Map:
			table.add_key(std::to_string(propertyValue).c_str());
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
		if (propertyType == PropertyType::Map)
			throw std::format_error("Unable to set struct as TMap key");

		auto _prop = static_cast<FStructProperty*>(property);
		auto _struct = _prop->GetStruct();
		auto structName = _struct->GetName();

		if (structName == STR("Vector"))
		{

			auto propertyValue = property->ContainerPtrToValuePtr<FVector>(data);
			if (propertyValue)
			{
				if (propertyType != PropertyType::Array)
					table.add_key(propName.c_str());

				auto inner_table = table.get_lua_instance().prepare_new_table();
				inner_table.add_pair("X", propertyValue->GetX());
				inner_table.add_pair("Y", propertyValue->GetY());
				inner_table.add_pair("Z", propertyValue->GetZ());
				inner_table.make_local();

				if (propertyType != PropertyType::Array)
					table.fuse_pair();
			}
		}
		else if (structName == STR("Rotator"))
		{
			auto propertyValue = property->ContainerPtrToValuePtr<FRotator>(data);

			if (propertyType != PropertyType::Array)
				table.add_key(propName.c_str());

			auto inner_table = table.get_lua_instance().prepare_new_table();
			inner_table.add_pair("Pitch", propertyValue->GetPitch());
			inner_table.add_pair("Roll", propertyValue->GetRoll());
			inner_table.add_pair("Yaw", propertyValue->GetYaw());
			inner_table.make_local();

			if (propertyType != PropertyType::Array)
				table.fuse_pair();
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

			if (propertyType != PropertyType::Array)
				table.add_key(propName.c_str());

			if (propertyValue && structProp)
			{
				auto inner_table = table.get_lua_instance().prepare_new_table();
				for (FProperty* innerProp = structProp->GetStruct()->GetPropertyLink(); innerProp; innerProp = innerProp->GetPropertyLinkNext())
				{
					ExportPropertyAsTable(innerProp, propertyValue, inner_table, PropertyType::None, depth);
				}
				inner_table.make_local();
			}

			if (propertyType != PropertyType::Array)
				table.fuse_pair();
		}
	}
	else if (property->IsA<FArrayProperty>())
	{
		if (propertyType == PropertyType::Map)
			throw std::format_error("Unable to set array as TMap key");
		if (propertyType == PropertyType::Array)
			throw std::format_error("Unable to set array within an array");

		auto _prop = static_cast<FArrayProperty*>(property);
		auto propertyValue = property->ContainerPtrToValuePtr<FScriptArray>(data);

		table.add_key(propName.c_str());
		auto innerTable = table.get_lua_instance().prepare_new_table();

		if (!propertyValue || !propertyValue->GetData())
		{
			innerTable.vector_to_table(empty);
			innerTable.make_local();
			table.fuse_pair();
			return;
		}

		auto innerProp = _prop->GetInner();
		const int32 elemSize = innerProp->GetElementSize();
		const int32 arrayCount = propertyValue->Num();

		if (arrayCount > 0)
		{
			for (int32_t i = 0; i < arrayCount; i++)
			{
				innerTable.add_key(i + 1);
				const int32 offset = i * elemSize;
				auto elem = static_cast<uint8*>(propertyValue->GetData()) + offset;
				try
				{
					ExportPropertyAsTable(innerProp, elem, innerTable, PropertyType::Array, depth);
				}
				catch (const std::exception&)
				{
					auto emptyInnerTable = innerTable.get_lua_instance().prepare_new_table();
					emptyInnerTable.vector_to_table(empty);
					emptyInnerTable.make_local();
					innerTable.fuse_pair();
					break;
				}
				innerTable.fuse_pair();
			}
		}
		else
		{
			innerTable.vector_to_table(empty);
		}
		innerTable.make_local();
		table.fuse_pair();
	}
	else if (property->IsA<FObjectProperty>())
	{
		if (propertyType == PropertyType::Map)
			throw std::format_error("Unable to set object as TMap key");
		if (propertyType == PropertyType::Array)
			throw std::format_error("Unable to explicitly iterate array");

		auto propertyValue = *property->ContainerPtrToValuePtr<UObject*>(data);

		if (propertyValue)
		{
			auto propertyClass = propertyValue->GetClassPrivate();
			if (propertyType != PropertyType::Array)
				table.add_key(propName.c_str());

			auto innerTable = table.get_lua_instance().prepare_new_table();
			try
			{
				for (FProperty* innerProp = propertyClass->GetPropertyLink(); innerProp; innerProp = innerProp->GetPropertyLinkNext())
				{
					ExportPropertyAsTable(innerProp, propertyValue, innerTable, PropertyType::None, depth - 1);
				}
			}
			catch (std::exception&)
			{
				innerTable.vector_to_table(empty);
			}
			innerTable.make_local();

			if (propertyType != PropertyType::Array)
				table.fuse_pair();
		}
	}
	else if (property->IsA<FMapProperty>())
	{
		if (propertyType == PropertyType::Map)
			throw std::format_error("Unable to set TMap as TMap key");
		if (propertyType == PropertyType::Array)
			throw std::format_error("Unable to iterate TMap");

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
				auto layout = Unreal::FScriptMap::GetScriptLayout(
					keyProp->GetSize(),
					keyProp->GetMinAlignment(),
					valueProp->GetSize(),
					valueProp->GetMinAlignment());

				for (int32 i = 0; i < mapSize; i++)
				{
					auto elem = static_cast<uint8*>(propertyValue->GetData(i, layout));
					try
					{
						ExportPropertyAsTable(keyProp, elem, innerTable, PropertyType::Map, depth);
					}
					catch (std::exception& err)
					{
						LogOutput<LogLevel::Verbose>(
							L"Unable to parse TMap {} with key type {}: {}",
							propWName,
							keyProp->GetClass().GetName(),
							to_wstring(err.what()));

						innerTable.vector_to_table(empty);
						break;
					}
					try
					{
						ExportPropertyAsTable(valueProp, elem, innerTable, PropertyType::Array, depth);
					}
					catch (const std::exception& e)
					{
						LogOutput<LogLevel::Verbose>(L"Unable to parse TMap value: {}", to_wstring(e.what()));
						auto emptyInnerTable = innerTable.get_lua_instance().prepare_new_table();
						emptyInnerTable.vector_to_table(empty);
						emptyInnerTable.make_local();
						innerTable.fuse_pair();
						break;
					}
					innerTable.fuse_pair();
				}
			}
			else
			{
				innerTable.vector_to_table(empty);
			}
			innerTable.make_local();
			table.fuse_pair();
		}
		else
		{
			LogOutput<LogLevel::Verbose>(L"Unable to parse {} of type {}", propWName, propClass);
		}
	}
	else if (property->IsA<FSetProperty>())
	{
		if (propertyType == PropertyType::Map)
			throw std::format_error("Unable to set TSet as TMap key");
		if (propertyType == PropertyType::Array)
			throw std::format_error("Unable to set TSet as array");

		auto setProp = static_cast<FSetProperty*>(property);
		auto setValue = property->ContainerPtrToValuePtr<void>(data);

		table.add_key(propName.c_str());
		auto innerTable = table.get_lua_instance().prepare_new_table();
		if (!setProp || !setValue)
		{
			innerTable.vector_to_table(empty);
			innerTable.make_local();
			table.fuse_pair();
			return;
		}

		auto innerProp = setProp->GetElementProp();

		FScriptSetHelper helper(setProp, setValue);

		if (helper.Num() > 0)
		{
			for (int32 i = 0; i < helper.Num(); i++)
			{
				if (helper.IsValidIndex(i))
				{
					innerTable.add_key(i + 1);
					uint8* elemPtr = helper.GetElementPtr(i);
					try
					{
						ExportPropertyAsTable(innerProp, elemPtr, innerTable, PropertyType::Array, depth);
					}
					catch (std::exception&)
					{
						auto emptyInnerTable = innerTable.get_lua_instance().prepare_new_table();
						emptyInnerTable.vector_to_table(empty);
						emptyInnerTable.make_local();
						innerTable.fuse_pair();
						break;
					}
					innerTable.fuse_pair();
				}
			}
		}
		else
		{
			innerTable.vector_to_table(empty);
		}
		innerTable.make_local();
		table.fuse_pair();
	}
	else
	{
		if (propertyType == PropertyType::Map)
			throw std::format_error("Unable to set anything as TMap key");
		LogOutput<LogLevel::Verbose>(L"Unable to parse {} of type {}", propWName, propClass);
	}
}

boost::json::object ModStatics::ObjectToJson(UObject* Object, const std::wstring Field, std::wstring ClassName, const int depth)
{
	boost::json::object obj;

	auto objClass = Object->GetClassPrivate();
	if (!Field.empty())
	{
		auto Property = Object->GetPropertyByNameInChain(Field.c_str());
		PropertyToJson(Property, Object, obj, depth);
	}
	else
	{
		for (FProperty* Property = objClass->GetPropertyLink(); Property; Property = Property->GetPropertyLinkNext())
		{
			if (ClassName.empty()) ClassName = objClass->GetName();
			if (Property->GetFullName().contains(ClassName))
			{
				PropertyToJson(Property, Object, obj, depth);
			}
		}
	}

	return obj;
}

boost::json::object ModStatics::StructToJson(UStruct* Object, void* Data)
{
	boost::json::object obj;
	if (Object)
	{
		for (FProperty* prop = Object->GetPropertyLink(); prop; prop = prop->GetPropertyLinkNext())
		{
			PropertyToJson(prop, Data, obj);
		}
	}
	return obj;
}

void ModStatics::PropertyToJson(FProperty* Property, void* Data, boost::json::object& Object, const int depth)
{
	if (depth < 0) return;

	std::string propName = to_string(Property->GetName().c_str());
	if (Property->IsA<FStrProperty>())
	{
		auto value = Property->ContainerPtrToValuePtr<FString>(Data);
		Object[propName] = to_string(value->GetCharArray());
	}
	else if (Property->IsA<FNameProperty>())
	{
		auto value = Property->ContainerPtrToValuePtr<FName>(Data);
		Object[propName] = to_string(value->ToString());
	}
	else if (Property->IsA<FTextProperty>())
	{
		auto value = Property->ContainerPtrToValuePtr<FText>(Data);
		Object[propName] = to_string(value->ToString());
	}
	else if (Property->IsA<FFloatProperty>())
	{
		const float value = *Property->ContainerPtrToValuePtr<float>(Data);
		Object[propName] = value;
	}
	else if (Property->IsA<FDoubleProperty>())
	{
		const double value = *Property->ContainerPtrToValuePtr<double>(Data);
		Object[propName] = value;
	}
	else if (Property->IsA<FBoolProperty>())
	{
		const bool value = *Property->ContainerPtrToValuePtr<bool>(Data);
		Object[propName] = value;
	}
	else if (Property->IsA<FIntProperty>() || Property->IsA<FInt64Property>() || Property->IsA<FUInt32Property>() || Property->IsA<FInt8Property>() || Property->IsA<FInt16Property>())
	{
		const int value = *Property->ContainerPtrToValuePtr<int>(Data);
		Object[propName] = value;
	}
	else if (Property->IsA<FEnumProperty>() || Property->IsA<FByteProperty>())
	{
		const uint8 value = *Property->ContainerPtrToValuePtr<uint8>(Data);
		Object[propName] = static_cast<int>(value);
	}
	else if (Property->IsA<FStructProperty>())
	{
		auto _prop = static_cast<FStructProperty*>(Property);
		auto _struct = _prop->GetStruct();
		auto structName = _struct->GetName();

		if (structName == STR("Vector"))
		{
			const auto value = *Property->ContainerPtrToValuePtr<FVector>(Data);
			Object[propName] = ModStatics::VectorToJson(value);
		}
		else if (structName == STR("Rotator"))
		{
			const auto value = *Property->ContainerPtrToValuePtr<FRotator>(Data);
			Object[propName] = ModStatics::RotatorToJson(value);
		}
		else if (structName == STR("Guid"))
		{
			FString value;
			auto propertyValue = Property->ContainerPtrToValuePtr<void>(Data);
			Property->ExportTextItem(value, propertyValue, nullptr, static_cast<UObject*>(Data), 0);
			Object[propName] = to_string(value.GetCharArray());
		}
		else
		{
			auto propertyValue = Property->ContainerPtrToValuePtr<void>(Data);
			auto structProp = static_cast<FStructProperty*>(Property);

			if (propertyValue && structProp)
			{
				boost::json::object innerObject;
				try
				{
					for (FProperty* innerProp = structProp->GetStruct()->GetPropertyLink(); innerProp; innerProp = innerProp->GetPropertyLinkNext())
					{
						PropertyToJson(innerProp, propertyValue, innerObject, depth);
					}
				}
				catch (std::exception&) {}

				Object[propName] = innerObject;
			}
		}
	}
	else if (Property->IsA<FArrayProperty>())
	{
		auto _prop = StaticCast<FArrayProperty*>(Property);
		auto propertyValue = Property->ContainerPtrToValuePtr<FScriptArray>(Data);
		auto innerProp = _prop->GetInner();
		const int32 elemSize = innerProp->GetElementSize();
		const int32 arrayCount = propertyValue->Num();
		boost::json::array array;

		try
		{
			for (int32_t i = 0; i < arrayCount; i++)
			{
				const int32 offset = i * elemSize;
				auto elem = static_cast<uint8*>(propertyValue->GetData()) + offset;
				boost::json::value val;
				PropertyToJson(innerProp, elem, val, depth);
				array.push_back(val);
			}
		}
		catch (std::exception&) {}

		Object[propName] = array;
	}
	else if (Property->IsA<FSetProperty>())
	{
		auto setProp = StaticCast<FSetProperty*>(Property);
		auto setValue = Property->ContainerPtrToValuePtr<void>(Data);
		auto innerProp = setProp->GetElementProp();
		boost::json::array array;

		FScriptSetHelper helper(setProp, setValue);

		try
		{
			for (int32 i = 0; i < helper.Num(); i++)
			{
				if (helper.IsValidIndex(i))
				{
					uint8* elemPtr = helper.GetElementPtr(i);
					boost::json::value val;
					PropertyToJson(innerProp, elemPtr, val, depth);
					array.push_back(val);
				}
			}
		}
		catch (std::exception&) {}

		Object[propName] = array;
	}
	else if (Property->IsA<FMapProperty>())
	{
		auto innerProp = StaticCast<FMapProperty*>(Property);
		auto propertyValue = Property->ContainerPtrToValuePtr<FScriptMap>(Data);

		if (innerProp && propertyValue)
		{
			const int32 mapSize = propertyValue->GetMaxIndex();
			auto keyProp = innerProp->GetKeyProp();
			auto valueProp = innerProp->GetValueProp();
			auto layout = Unreal::FScriptMap::GetScriptLayout(
				keyProp->GetSize(),
				keyProp->GetMinAlignment(),
				valueProp->GetSize(),
				valueProp->GetMinAlignment());
			boost::json::array innerArray;

			try
			{
				for (int32 i = 0; i < mapSize; i++)
				{
					auto elem = static_cast<uint8*>(propertyValue->GetData(i, layout));

					std::string field;
					PropertyToJson(keyProp, elem, field);

					boost::json::value val;
					PropertyToJson(valueProp, elem, val, depth);

					boost::json::object innerObject;
					innerObject[field] = val;
					innerArray.push_back(innerObject);
				}
			}
			catch (std::exception&) {}

			Object[propName] = innerArray;
		}
	}
	else if (Property->IsA<FObjectProperty>())
	{
		auto propertyValue = *Property->ContainerPtrToValuePtr<UObject*>(Data);

		if (propertyValue)
		{
			auto propertyClass = propertyValue->GetClassPrivate();
			boost::json::object innerObject;
			try
			{
				for (FProperty* innerProp = propertyClass->GetPropertyLink(); innerProp; innerProp = innerProp->GetPropertyLinkNext())
				{
					PropertyToJson(innerProp, propertyValue, innerObject, depth - 1);
				}
			}
			catch (std::exception& e)
			{
				LogOutput<LogLevel::Verbose>(L"Failed to parse property {}: {}", to_wstring(propName), to_wstring(e.what()));
			}
			Object[propName] = innerObject;
		}
	}
	else
	{
		auto propClass = Property->GetClass().GetName();
		throw(std::format_error("Unable to parse property " + propName + " of type " + to_string(propClass)));
	}
}

void ModStatics::PropertyToJson(FProperty* Property, void* Data, boost::json::value& Object, const int depth)
{
	if (depth < 0) return;

	if (Property->IsA<FStrProperty>())
	{
		auto value = Property->ContainerPtrToValuePtr<FString>(Data);
		Object = to_string(value->GetCharArray());
	}
	else if (Property->IsA<FNameProperty>())
	{
		auto value = Property->ContainerPtrToValuePtr<FName>(Data);
		Object = to_string(value->ToString());
	}
	else if (Property->IsA<FTextProperty>())
	{
		auto value = Property->ContainerPtrToValuePtr<FText>(Data);
		Object = to_string(value->ToString());
	}
	else if (Property->IsA<FFloatProperty>())
	{
		const float value = *Property->ContainerPtrToValuePtr<float>(Data);
		Object = value;
	}
	else if (Property->IsA<FDoubleProperty>())
	{
		const double value = *Property->ContainerPtrToValuePtr<double>(Data);
		Object = value;
	}
	else if (Property->IsA<FBoolProperty>())
	{
		const bool value = *Property->ContainerPtrToValuePtr<bool>(Data);
		Object = value;
	}
	else if (Property->IsA<FIntProperty>() || Property->IsA<FInt64Property>() || Property->IsA<FUInt32Property>() || Property->IsA<FInt8Property>() || Property->IsA<FInt16Property>())
	{
		const int value = *Property->ContainerPtrToValuePtr<int>(Data);
		Object = value;
	}
	else if (Property->IsA<FEnumProperty>() || Property->IsA<FByteProperty>())
	{
		const uint8 value = *Property->ContainerPtrToValuePtr<uint8>(Data);
		Object = static_cast<int>(value);
	}
	else if (Property->IsA<FStructProperty>())
	{
		auto _prop = static_cast<FStructProperty*>(Property);
		auto _struct = _prop->GetStruct();
		auto structName = _struct->GetName();

		if (structName == STR("Vector"))
		{
			const auto value = *Property->ContainerPtrToValuePtr<FVector>(Data);
			Object = ModStatics::VectorToJson(value);
		}
		else if (structName == STR("Rotator"))
		{
			const auto value = *Property->ContainerPtrToValuePtr<FRotator>(Data);
			Object = ModStatics::RotatorToJson(value);
		}
		else if (structName == STR("Guid"))
		{
			FString value;
			auto propertyValue = Property->ContainerPtrToValuePtr<void>(Data);
			Property->ExportTextItem(value, propertyValue, nullptr, static_cast<UObject*>(Data), 0);
			Object = to_string(value.GetCharArray());
		}
		else
		{
			auto propertyValue = Property->ContainerPtrToValuePtr<void>(Data);
			auto structProp = static_cast<FStructProperty*>(Property);

			if (propertyValue && structProp)
			{
				boost::json::object innerObject;

				try
				{
					for (FProperty* innerProp = structProp->GetStruct()->GetPropertyLink(); innerProp; innerProp = innerProp->GetPropertyLinkNext())
					{
						PropertyToJson(innerProp, propertyValue, innerObject, depth);
					}
				}
				catch (std::exception&) {}

				Object = innerObject;
			}
		}
	}
	else if (Property->IsA<FArrayProperty>())
	{
		auto _prop = StaticCast<FArrayProperty*>(Property);
		auto propertyValue = Property->ContainerPtrToValuePtr<FScriptArray>(Data);
		auto innerProp = _prop->GetInner();
		const int32 elemSize = innerProp->GetElementSize();
		const int32 arrayCount = propertyValue->Num();
		boost::json::array array;

		try
		{
			for (int32_t i = 0; i < arrayCount; i++)
			{
				const int32 offset = i * elemSize;
				auto elem = static_cast<uint8*>(propertyValue->GetData()) + offset;
				boost::json::value val;
				PropertyToJson(innerProp, elem, val, depth);
				array.push_back(val);
			}
		}
		catch (std::exception&) {}

		Object = array;
	}
	else if (Property->IsA<FSetProperty>())
	{
		auto setProp = StaticCast<FSetProperty*>(Property);
		auto setValue = Property->ContainerPtrToValuePtr<void>(Data);
		auto innerProp = setProp->GetElementProp();
		boost::json::array array;

		FScriptSetHelper helper(setProp, setValue);

		try
		{
			for (int32 i = 0; i < helper.Num(); i++)
			{
				if (helper.IsValidIndex(i))
				{
					uint8* elemPtr = helper.GetElementPtr(i);
					boost::json::value val;
					PropertyToJson(innerProp, elemPtr, val, depth);
					array.push_back(val);
				}
			}
		}
		catch (std::exception&) {}

		Object = array;
	}
	else if (Property->IsA<FMapProperty>())
	{
		auto innerProp = StaticCast<FMapProperty*>(Property);
		auto propertyValue = Property->ContainerPtrToValuePtr<FScriptMap>(Data);

		if (innerProp && propertyValue)
		{
			const int32 mapSize = propertyValue->GetMaxIndex();
			auto keyProp = innerProp->GetKeyProp();
			auto valueProp = innerProp->GetValueProp();
			auto layout = Unreal::FScriptMap::GetScriptLayout(
				keyProp->GetSize(),
				keyProp->GetMinAlignment(),
				valueProp->GetSize(),
				valueProp->GetMinAlignment());
			boost::json::array innerArray;

			try
			{
				for (int32 i = 0; i < mapSize; i++)
				{
					auto elem = static_cast<uint8*>(propertyValue->GetData(i, layout));

					std::string field;
					PropertyToJson(keyProp, elem, field);

					boost::json::value val;
					PropertyToJson(valueProp, elem, val, depth);

					boost::json::object innerObject;
					innerObject[field] = val;
					innerArray.push_back(innerObject);
				}
			}
			catch (std::exception&) {}

			Object = innerArray;
		}
	}
	else if (Property->IsA<FObjectProperty>())
	{
		auto propertyValue = *Property->ContainerPtrToValuePtr<UObject*>(Data);

		if (propertyValue)
		{
			auto propertyClass = propertyValue->GetClassPrivate();
			boost::json::object innerObject;
			try
			{
				for (FProperty* innerProp = propertyClass->GetPropertyLink(); innerProp; innerProp = innerProp->GetPropertyLinkNext())
				{
					PropertyToJson(innerProp, propertyValue, innerObject, depth - 1);
				}
			}
			catch (std::exception& e)
			{
				auto errMsg = to_wstring(e.what());
				//LogOutput<LogLevel::Verbose>(L"Failed to parse value: {}", errMsg);
			}
			Object = innerObject;
		}
	}
	else
	{
		auto propClass = Property->GetClass().GetName();
		throw(std::format_error("Unable to parse value of type " + to_string(propClass)));
	}
}

void ModStatics::PropertyToJson(FProperty* Property, void* Data, std::string& Object)
{
	if (Property->IsA<FStrProperty>())
	{
		auto value = Property->ContainerPtrToValuePtr<FString>(Data);
		Object = to_string(value->GetCharArray());
	}
	else if (Property->IsA<FNameProperty>())
	{
		auto value = Property->ContainerPtrToValuePtr<FName>(Data);
		Object = to_string(value->ToString());
	}
	else if (Property->IsA<FTextProperty>())
	{
		auto value = Property->ContainerPtrToValuePtr<FText>(Data);
		Object = to_string(value->ToString());
	}
	else if (Property->IsA<FFloatProperty>())
	{
		const float value = *Property->ContainerPtrToValuePtr<float>(Data);
		Object = value;
	}
	else if (Property->IsA<FDoubleProperty>())
	{
		const double value = *Property->ContainerPtrToValuePtr<double>(Data);
		Object = value;
	}
	else if (Property->IsA<FBoolProperty>())
	{
		const bool value = *Property->ContainerPtrToValuePtr<bool>(Data);
		Object = value;
	}
	else if (Property->IsA<FIntProperty>() || Property->IsA<FInt64Property>() || Property->IsA<FUInt32Property>() || Property->IsA<FInt8Property>() || Property->IsA<FInt16Property>())
	{
		const int value = *Property->ContainerPtrToValuePtr<int>(Data);
		Object = value;
	}
	else if (Property->IsA<FEnumProperty>() || Property->IsA<FByteProperty>())
	{
		const uint8 value = *Property->ContainerPtrToValuePtr<uint8>(Data);
		Object = static_cast<int>(value);
	}
	else
	{
		auto propClass = Property->GetClass().GetName();
		throw(std::format_error("Unable to set field of type " + to_string(propClass)));
	}
}
