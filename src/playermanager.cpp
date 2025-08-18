#include "playermanager.h"
#include "helper.h"

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

bool PlayerManager::IsMatchingRequest(const http::request<http::string_body>& req) const
{
	if (req.method() == http::verb::get && req.target() == "/players")
	{
		return true;
	}
	return false;
}

bool PlayerManager::IsMatchingRequest(const json::object& req) const
{
	if (req.contains("action") && req.at("action").as_string() == "getPlayerLocation") return true;
	return false;
}

json::object PlayerManager::GetResponseJson(const http::request<http::string_body>& req, http::status& statusCode)
{
	json::object response_json;
	if (req.method() == http::verb::get && req.target().starts_with("/players"))
	{
		// return all players
		if (req.target() == "/players")
		{
			response_json["data"] = GetPlayerStates();
			statusCode = http::status::ok;
		}
		// TODO: return specific player
	}

	return response_json;
}

json::object PlayerManager::GetResponseJson(const json::object& req)
{
	json::object obj;
	if (req.contains("action") && req.at("action").as_string() == "getPlayerLocation")
	{
		json::array arr;
		auto playerStates = GetPlayerStates();
		if (playerStates.is_array())
		{
			for (auto& state : playerStates.as_array())
			{
				if (state.is_object())
				{
					json::object player;
					player["Location"] = state.as_object().at("Location");
					player["UniqueID"] = state.as_object().at("UniqueID");
					arr.push_back(player);
				}
			}
		}
		obj["data"] = arr;
	}
	obj["status"] = "success";
	return obj;
}

boost::json::value PlayerManager::GetPlayerStates() const
{
	boost::json::array val;
	UObject* obj = GameHelper::get()->GetGameState();
	if (obj)
	{
		auto&  players = *obj->GetValuePtrByPropertyNameInChain<TArray<UObject*>>(STR("PlayerArray"));
		for (UObject* player : players)
		{
			auto out = ModStatics::ObjectToJson(player, L"", L"MotorTownPlayerState", 0);

			auto guid = player->GetPropertyByNameInChain(STR("UniqueID"));
			auto guidValue = guid->ContainerPtrToValuePtr<void>(player);
			FString guidString;

			guid->ExportTextItem(guidString, guidValue, nullptr, player, 0);

			out["UniqueID"] = to_string(guidString.GetCharArray()).c_str();

			val.push_back(out);
		}
	}
	else
	{
		ModStatics::LogOutput<LogLevel::Warning>(L"Invalid GameState");
	}
	return val;
}
