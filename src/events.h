#pragma once

#include "webroute.h"

#include "statics.h"
#include <Unreal/FString.hpp>
#include <Unreal/UnrealCoreStructs.hpp>

using namespace RC;
using namespace RC::Unreal;

enum class EMTEventType {
	None,
	Race,
};

enum class EMTEventState {
	None,
	Ready,
	InProgress,
	Finished,
};

struct FMTEventPlayer : public FStructBase
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

	FMTEventPlayer();
	FMTEventPlayer(UStruct* propertyStruct, void* data);

	virtual json::object ToJson() const override;
};

struct FMTRaceEventSetup : public FStructBase
{
	FMTRoute Route;
	int32 NumLaps = 0;
	TArray<FName> VehicleKeys;
	TArray<FName> EngineKeys;

	FMTRaceEventSetup();
	FMTRaceEventSetup(UStruct* propertyStruct, void* data);

	virtual json::object ToJson() const override;
};

// Basic struct for initial parse
struct FMTEvent : public FStructBase
{
	FString EventName;
	FGuid EventGuid;
	EMTEventType EventType;
	EMTEventState State;
	bool bInCountdown;
	FMTCharacterId OwnerCharacterId;
	TArray<FMTEventPlayer> Players;
	FMTRaceEventSetup RaceSetup;

	FMTEvent();
	FMTEvent(const FMTEvent& data);
	// ThreadSafe overload to use in GameThread
	FMTEvent(UStruct* propertyStruct, void* data);

	virtual json::object ToJson() const override;
};

class EventManager : public Route
{
	FMTEvent ev;
public:
	EventManager();
	virtual bool IsMatchingRequest(http::request<http::string_body> req) override;
	virtual json::object GetResponseJson(http::request<http::string_body> req) override;

private:
	std::vector<FMTEvent> GetEvents();
};
