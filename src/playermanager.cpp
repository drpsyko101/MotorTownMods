#include "playermanager.h"

#include <Unreal/UObjectGlobals.hpp>
#include <Unreal/UObject.hpp>
#include <Unreal/UClass.hpp>
#include <Unreal/AActor.hpp>
#include <Unreal/UFunction.hpp>
#include <DynamicOutput/DynamicOutput.hpp>
#include <regex>

static std::wstring gameStatePath = STR("/Script/MotorTown.MotorTownGameState");

PlayerManager::PlayerManager()
	: Route()
{
}

bool PlayerManager::IsMatchingRequest(http::request<http::string_body> req)
{
	if (req.method() == http::verb::get && req.target() == "/players")
	{
		return true;
	}
	return false;
}

json::object PlayerManager::GetResponseJson(http::request<http::string_body> req)
{
	json::object response_json;
	if (req.method() == http::verb::get && req.target().starts_with("/players"))
	{
		// return all players
		if (req.target() == "/players")
		{
			json::array arr;
			for (const auto& data : GetPlayerLocations())
			{
				arr.push_back(data.CreateJson());
			}
			response_json["data"] = arr;
		}
		// TODO: return specific player
	}

	return response_json;
}

std::list<MotorTownPlayerState> PlayerManager::GetPlayerLocations()
{
	std::list<MotorTownPlayerState> playerStates;
	map<std::wstring, FVector> locs;
	std::vector<UObject*> objs;
	UObjectGlobals::FindAllOf(
		STR("MotorTownPlayerState"),
		objs);

	for (UObject* obj : objs)
	{
		MotorTownPlayerState playerState;
		FString playerName = FString(STR(""));
		if (UFunction* getPlayerName = obj->GetFunctionByNameInChain(
			STR("GetPlayerName")))
		{
			obj->ProcessEvent(getPlayerName, &playerName);
			playerState.PlayerName = playerName.GetCharArray();
		}

		if (FVector* location = obj->GetValuePtrByPropertyNameInChain<FVector>(
			STR("Location")))
		{
			playerState.Location[0] = location->X();
			playerState.Location[1] = location->Y();
			playerState.Location[2] = location->Z();
		}

		if (int32* grid = obj->GetValuePtrByPropertyNameInChain<int32>(
			STR("GridIndex")))
		{
			playerState.GridIndex = *grid;
		}

		if (bool* isHost = obj->GetValuePtrByPropertyNameInChain<bool>(
			STR("bIsHost")))
		{
			playerState.IsHost = *isHost;
		}

		if (bool* isAdmin = obj->GetValuePtrByPropertyNameInChain<bool>(
			STR("bIsAdmin")))
		{
			playerState.IsAdmin = *isAdmin;
		}

		if (float* bestLap = obj->GetValuePtrByPropertyNameInChain<float>(
			STR("BestLapTime")))
		{
			playerState.BestLapTime = *bestLap;
		}

		if (TArray<int32>* levels = obj->GetValuePtrByPropertyNameInChain<TArray<int32>>(
			STR("Levels")))
		{
			playerState.Levels.clear();
			for (const auto& a : *levels)
			{
				playerState.Levels.push_back(a);
			}
		}

		if (FName* key = obj->GetValuePtrByPropertyNameInChain<FName>(
			STR("VehicleKey")))
		{
			playerState.VehicleKey = to_string(key->ToString());
		}

		playerStates.push_back(playerState);

		// Deallocate current obj pointer
		free(obj);
	}

	objs.clear();

	return playerStates;
}

json::object MotorTownPlayerState::CreateJson() const
{
	json::object elem;
	elem["PlayerName"] = to_string(PlayerName);
	elem["GridIndex"] = GridIndex;
	elem["IsHost"] = IsHost;
	elem["IsAdmin"] = IsAdmin;
	elem["BestLapTime"] = BestLapTime;
	json::array arr;
	for (const auto& lvl : Levels)
	{
		arr.push_back(lvl);
	}
	elem["Levels"] = arr;
	json::object vec;
	vec["X"] = Location[0];
	vec["Y"] = Location[1];
	vec["Z"] = Location[2];
	elem["Location"] = vec;
	elem["VehicleKey"] = VehicleKey;
	return elem;
}
