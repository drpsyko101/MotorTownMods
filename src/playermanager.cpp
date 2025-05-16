#include "playermanager.h"
#include <Unreal/UObjectGlobals.hpp>
#include <Unreal/UObject.hpp>
#include <DynamicOutput/DynamicOutput.hpp>

PlayerManager::PlayerManager()
	: Route()
{
}

bool PlayerManager::is_request_match(http::request<http::string_body> req)
{
	if (req.method() == http::verb::get && req.target() == "/players")
	{
		return true;
	}
	return false;
}

json::object PlayerManager::get_response(http::request<http::string_body> req)
{
	json::object response_json;
	if (req.method() == http::verb::get && req.target() == "/players")
	{
		json::array arr;
		for (const auto& data : get_player_locations())
		{
			json::object elem;
			json::object vec;
			vec["X"] = data.second.X();
			vec["Y"] = data.second.Y();
			vec["Z"] = data.second.Z();
			elem["PlayerName"] = data.first;
			elem["Location"] = vec;
			arr.push_back(elem);
		}
		response_json["data"] = arr;
	}

	return response_json;
}

map<string, FVector> PlayerManager::get_player_locations()
{
	map<string, FVector> locs;

	vector<UObject*> objs;
	UObjectGlobals::FindObjects(
		STR("/Script/MotorTown.MotorTownPlayerState"), 
		STR("MotorTownPlayerState"), 
		objs);

	for (UObject* obj : objs)
	{
		FString playerName;
		static FName funcName = FName(STR("GetPlayerName"), FNAME_Add);
		UFunction* getPlayerName = obj->GetFunctionByNameInChain(funcName);
		if (getPlayerName)
		{
			Output::send<LogLevel::Verbose>(STR("GetPlayerName function found\n"));
			obj->ProcessEvent(getPlayerName, &playerName);
		}
		FVector* location = obj->GetValuePtrByPropertyNameInChain<FVector>(STR("Location"));


		if (location)
		{
			std::wstring ws(playerName.GetCharArray());
			locs[string(ws.begin(), ws.end())] = *location;
		}
	}

	return locs;
}
