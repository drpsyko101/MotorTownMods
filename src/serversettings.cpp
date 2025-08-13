#include "serversettings.h"

#include <Unreal/UObjectGlobals.hpp>
#include <Unreal/UObject.hpp>
#include <Unreal/Property/FArrayProperty.hpp>
#include <Unreal/Property/FStructProperty.hpp>
#include <Unreal/Core/Containers/ScriptArray.hpp>
#include <Unreal/UScriptStruct.hpp>

static const char* vehicleConfigPath = "/config/spawn/vehicle";

ServerSettings::ServerSettings()
{
}

bool ServerSettings::IsMatchingRequest(http::request<http::string_body> req)
{
	if (req.target().starts_with(vehicleConfigPath))
	{
		return true;
	}
	return false;
}

json::object ServerSettings::GetResponseJson(http::request<http::string_body> req, http::status& statusCode)
{
	json::object obj;
	if (req.target() == vehicleConfigPath)
	{
		if (req.method() == http::verb::get)
		{
			obj["data"] = GetVehicleSpawnSettings();
			statusCode = http::status::ok;
			return obj;
		}
	}
	return obj;
}

boost::json::value ServerSettings::GetVehicleSpawnSettings() const
{
	return boost::json::value();
}
