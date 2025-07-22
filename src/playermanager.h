#pragma once

#include <Unreal/UnrealCoreStructs.hpp>
#include "webroute.h"
#include "statics.h"
#include <memory>

using namespace RC;
using namespace RC::Unreal;
using namespace std;

struct MotorTownPlayerState : public FStructBase
{
	FString PlayerName;
	int32 GridIndex = -1;
	bool IsHost = false;
	bool IsAdmin = false;
	float BestLapTime = 0.f;
	TArray<int32> Levels;
	FVector CustomDestinationAbsoluteLocation;
	FVector Location;
	FName VehicleKey;

	virtual json::object ToJson() const override;
};

class PlayerManager : public Route
{
public:
	PlayerManager();
	virtual bool IsMatchingRequest(http::request<http::string_body> req) override;
	virtual json::object GetResponseJson(http::request<http::string_body> req) override;

private:
	std::list<MotorTownPlayerState> GetPlayerLocations();
};
