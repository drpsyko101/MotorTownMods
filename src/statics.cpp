#include "statics.h"
#include "Helpers/String.hpp"
#include <boost/uuid/uuid_io.hpp>
#include <Unreal/Rotator.hpp>

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

boost::json::object ModStatics::CharacterIdToJson(const FMTCharacterId charactedId)
{
    boost::json::object obj;
    obj["UniqueNetId"] = RC::to_string(charactedId.UniqueNetId.GetCharArray());
    obj["CharacterGuid"] = ModStatics::GuidToString(charactedId.CharacterGuid);
    return obj;
}

boost::json::object ModStatics::ShadowedIntToJson(const FMTShadowedInt64 shadowedInt)
{
    boost::json::object obj;
    obj["BaseValue"] = shadowedInt.BaseValue;
    obj["ShadowedValue"] = shadowedInt.ShadowedValue;
    return obj;
}

boost::json::object ModStatics::RouteToJson(const FMTRoute route)
{
    boost::json::object obj;
    obj["RouteName"] = RC::to_string(route.RouteName.GetCharArray());
    boost::json::array arr;
    for (const FTransform& transform : route.Waypoints)
    {
        arr.push_back(transform_to_json(transform));
    }
    obj["Waypoints"] = arr;
    return obj;
}
