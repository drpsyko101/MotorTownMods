#pragma once

#include "webroute.h"

#include "statics.h"
#include <Unreal/FString.hpp>
#include <Unreal/UnrealCoreStructs.hpp>

using namespace RC;
using namespace RC::Unreal;

enum class EMTEventType : uint8
{
	None,
	Race,
};

enum class EMTEventState : uint8
{
	None,
	Ready,
	InProgress,
	Finished,
};

struct FMTEventPlayer
{
	FMTCharacterId CharacterId;
	FString PlayerName;
	int32 Rank = -1;
	int32 SectionIndex = -1;
	int32 Laps = 0;
	bool bDisqualified = false;
	bool bFinished = false;
	bool bWrongVehicle = false;
	bool bWrongEngine = false;
	float LastSectionTotalTimeSeconds = 0.f;
	TArray<float> LapTimes;
	float BestLapTime = 0.f;
	int32 Reward_RacingExp = 0;
	FMTShadowedInt64 Reward_Money;
};

struct FMTRaceEventSetup
{
	FMTRoute Route;
	int32 NumLaps = 0;
	TArray<FName> VehicleKeys;
	TArray<FName> EngineKeys;
};

// Basic struct for initial parse
struct FMTEvent
{
	FString EventName;					// 0x0000 (size: 0x10)
	FGuid EventGuid;					// 0x0010 (size: 0x10)
	EMTEventType EventType;				// 0x0020 (size: 0x1)
	EMTEventState State;				// 0x0021 (size: 0x1)
	bool bInCountdown = false;			// 0x0022 (size: 0x1)
	uint8 _pad1[5] = {};
	FMTCharacterId OwnerCharacterId;	// 0x0028 (size: 0x20)
	TArray<FMTEventPlayer> Players;		// 0x0048 (size: 0x10)
	FMTRaceEventSetup RaceSetup;		// 0x0058 (size: 0x48)

	FMTEvent();
	FMTEvent(std::string eventName);
	FMTEvent(const json::object object);
};

class EventManager : public Route
{
	FMTEvent ev;
public:
	EventManager();
	virtual bool IsMatchingRequest(http::request<http::string_body> req) override;
	virtual json::object GetResponseJson(http::request<http::string_body> req, http::status& statusCode) override;

private:
	boost::json::value GetEvents(FGuid eventGuid = FGuid(), const int depth = 0) const;
	bool CreateNewEvent(FMTEvent& Event);
};
