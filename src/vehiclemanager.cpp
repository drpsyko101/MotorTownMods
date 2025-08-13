#include "vehiclemanager.h"
#include "helper.h"

#include <Unreal/UObjectGlobals.hpp>
#include <Unreal/UObject.hpp>
#include <Unreal/UClass.hpp>
#include <Unreal/AActor.hpp>
#include <Unreal/UFunction.hpp>
#include <DynamicOutput/DynamicOutput.hpp>
#include <regex>

VehicleManager::VehicleManager()
	: Route()
{
}

bool VehicleManager::IsMatchingRequest(http::request<http::string_body> req)
{
	return req.method() == http::verb::get && req.target() == "/vehicles";
}

json::object VehicleManager::GetResponseJson(http::request<http::string_body> req, http::status& statusCode)
{
	json::object data;
	json::array arr;

	UObject* gameState = GameHelper::get()->GetGameState();
	if (gameState)
	{
		auto& vehicles = *gameState->GetValuePtrByPropertyName<TArray<UObject*>>(STR("Vehicles"));

		int index = 0;
		for (UObject* vehicle : vehicles)
		//if (auto vehicle = vehicles[100])
		{
			ModStatics::LogOutput<LogLevel::Verbose>(L"vehicleIndex: {}", index);
			arr.push_back(ModStatics::ObjectToJson(vehicle, L"", L"/Script/MotorTown.MTVehicle", 0));
			index++;
		}
	}

	data["data"] = arr;
	return data;
}
