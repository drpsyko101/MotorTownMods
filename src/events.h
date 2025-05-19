#pragma once

#include "webroute.h"

#include "statics.h"
#include <Unreal/FString.hpp>
#include <Unreal/UnrealCoreStructs.hpp>

using namespace RC;
using namespace RC::Unreal;

enum class EMTEventType {
	None = 0,
	Race,
};

enum class EMTEventState {
	None = 0,
	Ready,
	InProgress,
	Finished,
};

struct FMTEventPlayer
{
	FMTCharacterId CharacterId;
	FString PlayerName;
	void* PC;
	int32 Rank;
	int32 SectionIndex;
	int32 Laps;
	bool bDisqualified;
	bool bFinished;
	bool bWrongVehicle;
	bool bWrongEngine;
	float LastSectionTotalTimeSeconds;
	TArray<float> LapTimes;
	float BestLapTime;
	int32 Reward_RacingExp;
	FMTShadowedInt64 Reward_Money;

	json::object ToJson() const;
};

struct FMTRaceEventSetup
{
	FMTRoute Route;
	int32 NumLaps;
	TArray<FName> VehicleKeys;
	TArray<FName> EngineKeys;

	FMTRaceEventSetup();
	FMTRaceEventSetup(UStruct* propertyStruct, void* data);

	json::object ToJson() const;
};

// Basic struct for initial parse
struct FMTEvent
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

	json::object ToJson() const;
};

struct FMTEventArray
{
	TArray<FMTEvent> Events;
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