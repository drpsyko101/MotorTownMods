#pragma once

#include <Unreal/UnrealCoreStructs.hpp>
#include "webroute.h"
#include <memory>

using namespace RC;
using namespace RC::Unreal;
using namespace std;

struct MotorTownPlayerState {
	std::wstring PlayerName = L"";
	int32_t GridIndex = -1;
	bool IsHost = false;
	bool IsAdmin = false;
	float BestLapTime = 0.0f;
	std::vector<int32_t> Levels = { 0,0,0,0,0 };
	double CustomDestinationAbsoluteLocation[3] = { 0.f, 0.f, 0.f };
	double Location[3] = { 0.f, 0.f, 0.f };
	std::string VehicleKey = "";

	json::object create_json_object() const;
};

class PlayerManager : public Route
{
public:
	PlayerManager();
	virtual bool is_request_match(http::request<http::string_body> req) override;
	virtual json::object get_response(http::request<http::string_body> req) override;

private:
	std::list<MotorTownPlayerState> get_player_locations();
};
