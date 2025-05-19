#include "statics.h"
#include "Helpers/String.hpp"
#include <boost/uuid/uuid_io.hpp>
#include <Unreal/Rotator.hpp>
#include <Unreal/UStruct.hpp>
#include <Unreal/FProperty.hpp>

static boost::json::object vector_to_json(FVector vector)
{
    boost::json::object vec;
    vec["X"] = vector.GetX();
    vec["Y"] = vector.GetY();
    vec["Z"] = vector.GetZ();
    return vec;
}

static boost::json::object rotator_to_json(FQuat rotation)
{
    boost::json::object vec;
    vec["X"] = rotation.GetX();
    vec["Y"] = rotation.GetY();
    vec["Z"] = rotation.GetZ();
    return vec;
}

static boost::json::object transform_to_json(FTransform transform)
{
    boost::json::object obj;
    obj["Translation"] = vector_to_json(transform.GetTranslation());
    obj["Rotation"] = rotator_to_json(transform.GetRotation());
    obj["Scale"] = vector_to_json(transform.GetScale3D());
    return obj;
}

std::wstring ModStatics::ParseJsonObject(boost::json::object object)
{
    return L"{}";
}

std::string ModStatics::GuidToString(const FGuid Guid)
{
    return std::format("{}{}{}{}", Guid.A, Guid.B, Guid.C, Guid.D);
}

const char* ModStatics::GetWebhookUrl()
{
    return getenv("API_WEBHOOK_URL");
}

FMTCharacterId::FMTCharacterId()
{
}

FMTCharacterId::FMTCharacterId(UStruct* propertyStruct, void* data)
    : FMTCharacterId()
{
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
        arr.push_back(transform_to_json(transform));
    }
    obj["Waypoints"] = arr;
    return obj;
}
