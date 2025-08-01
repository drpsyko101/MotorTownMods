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

std::wstring ModStatics::ParseJsonObject(boost::json::object object)
{
	return L"{}";
}

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
	const bool convertObject,
	const int32 depth)
{
	if (!property) return;

	// Limit recursive depth search
	std::vector<int> empty;
	if (convertObject && depth <= 0)
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
					ExportPropertyAsTable(innerProp, propertyValue, inner_table, PropertyType::None, convertObject, depth);
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
					ExportPropertyAsTable(innerProp, elem, innerTable, PropertyType::Array, convertObject, depth - 1);
				}
				catch (const std::exception&)
				{
					auto emptyInnerTable = innerTable.get_lua_instance().prepare_new_table();
					emptyInnerTable.vector_to_table(empty);
					emptyInnerTable.make_local();
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
		if (propertyType == PropertyType::Array && !convertObject)
			throw std::format_error("Unable to explicitly iterate array");

		if (convertObject)
		{
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
						ExportPropertyAsTable(innerProp, propertyValue, innerTable, PropertyType::None, convertObject, depth - 1);
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
						ExportPropertyAsTable(keyProp, elem, innerTable, PropertyType::Map, convertObject, depth - 1);
					}
					catch (std::exception& err)
					{
						LogOutput<LogLevel::Warning>(
							L"Unable to parse TMap {} with key type {}: {}",
							propWName,
							keyProp->GetClass().GetName(),
							to_wstring(err.what()));

						innerTable.vector_to_table(empty);
						break;
					}
					try
					{
						ExportPropertyAsTable(valueProp, elem, innerTable, PropertyType::Array, convertObject, depth - 1);
					}
					catch (const std::exception& e)
					{
						LogOutput<LogLevel::Warning>(L"Unable to parse TMap value: {}", to_wstring(e.what()));
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
			LogOutput<LogLevel::Warning>(L"Unable to parse {} of type {}", propWName, propClass);
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
						ExportPropertyAsTable(innerProp, elemPtr, innerTable, PropertyType::Array, convertObject, depth - 1);
					}
					catch (std::exception&)
					{
						auto emptyInnerTable = innerTable.get_lua_instance().prepare_new_table();
						emptyInnerTable.vector_to_table(empty);
						emptyInnerTable.make_local();
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
		LogOutput<LogLevel::Warning>(L"Unable to parse {} of type {}", propWName, propClass);
	}
}

boost::json::object ModStatics::ObjectToJson(UObject* Object)
{
	boost::json::object obj;

	auto objClass = Object->GetClassPrivate();
	for (FProperty* Property = objClass->GetPropertyLink(); Property; Property = Property->GetPropertyLinkNext())
	{
		std::string propName = to_string(Property->GetName().c_str());
		if (Property->GetFullName().contains(objClass->GetName()))
		{
			if (auto strProp = CastField<FStrProperty>(Property))
			{
				auto value = strProp->GetPropertyValue(Object).GetCharArray();
				obj[propName] = to_string(value);
			}
			else if (auto floatProp = CastField<FFloatProperty>(Property))
			{
				float value = floatProp->GetPropertyValue(Object);
				obj[propName] = value;
			}
			else if (auto floatProp = CastField<FDoubleProperty>(Property))
			{
				double value = floatProp->GetPropertyValue(Object);
				obj[propName] = value;
			}
			else if (auto boolProp = CastField<FBoolProperty>(Property))
			{
				bool value = boolProp->GetPropertyValue(Object);
				obj[propName] = value;
			}
			else if (auto intProp = CastField<FIntProperty>(Property))
			{
				int value = intProp->GetPropertyValue(Object);
				obj[propName] = value;
			}
			else if (auto nameProp = CastField<FNameProperty>(Property))
			{
				auto value = nameProp->GetPropertyValue(Object).ToString();
				obj[propName] = to_string(value);
			}
			else if (auto textProp = CastField<FTextProperty>(Property))
			{
				auto value = textProp->GetPropertyValue(Object).ToString();
				obj[propName] = to_string(value);
			}
			else if (auto intProp = CastField<FInt64Property>(Property))
			{
				auto value = intProp->GetPropertyValue(Object);
				obj[propName] = value;
			}
			else if (auto intProp = CastField<FByteProperty>(Property))
			{
				auto value = intProp->GetPropertyValue(Object);
				obj[propName] = value;
			break; // Assume anything below to be super props
			}
		}
	}

	return obj;
}

FMTCharacterId::FMTCharacterId()
{
}

FMTCharacterId::FMTCharacterId(UStruct* propertyStruct, void* data)
	: FMTCharacterId()
{
	if (propertyStruct == nullptr || data == nullptr) return;
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("UniqueNetId")))
	{
		UniqueNetId = *name->ContainerPtrToValuePtr<FString>(data);
	}
	if (FProperty* guid = propertyStruct->GetPropertyByNameInChain(STR("CharacterGuid")))
	{
		CharacterGuid = *guid->ContainerPtrToValuePtr<FGuid>(data);
	}
}

boost::json::object FMTCharacterId::ToJson() const
{
	boost::json::object obj;
	obj["UniqueNetId"] = RC::to_string(UniqueNetId.GetCharArray());
	obj["CharacterGuid"] = ModStatics::GuidToString(CharacterGuid);
	return obj;
}

FMTShadowedInt64::FMTShadowedInt64()
{
}

FMTShadowedInt64::FMTShadowedInt64(UStruct* propertyStruct, void* data)
	: FMTShadowedInt64()
{
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("BaseValue")))
	{
		BaseValue = *name->ContainerPtrToValuePtr<int64>(data);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("ShadowedValue")))
	{
		ShadowedValue = *name->ContainerPtrToValuePtr<int64>(data);
	}
}

boost::json::object FMTShadowedInt64::ToJson() const
{
	boost::json::object obj;
	obj["BaseValue"] = BaseValue;
	obj["ShadowedValue"] = ShadowedValue;
	return obj;
}

FMTRoute::FMTRoute()
{
}

FMTRoute::FMTRoute(UStruct* propertyStruct, void* data)
{
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("RouteName")))
	{
		RouteName = *name->ContainerPtrToValuePtr<FString>(data);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("Waypoints")))
	{
		Waypoints = *name->ContainerPtrToValuePtr<TArray<FTransform>>(data);
	}
}

boost::json::object FMTRoute::ToJson() const
{
	boost::json::object obj;
	obj["RouteName"] = RC::to_string(RouteName.GetCharArray());
	boost::json::array arr;
	for (const FTransform& transform : Waypoints)
	{
		arr.push_back(ModStatics::TransformToJson(transform));
	}
	obj["Waypoints"] = arr;
	return obj;
}

FStructBase::FStructBase(UStruct* propertyStruct, void* data)
	: FStructBase()
{
}

boost::json::object FStructBase::ToJson() const
{
	return boost::json::object();
}
