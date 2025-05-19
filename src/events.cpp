#include "events.h"

#include <Unreal/UObjectGlobals.hpp>
#include <Unreal/UFunction.hpp>
#include <Unreal/UFunctionStructs.hpp>
#include <Unreal/UStruct.hpp>
#include <Unreal/UScriptStruct.hpp>
#include <Unreal/FProperty.hpp>
#include <Unreal/Property/FStructProperty.hpp>
#include <Unreal/Property/FArrayProperty.hpp>
#include <Unreal/UObject.hpp>
#include <Unreal/FField.hpp>
#include <Unreal/Script.hpp>
#include <Unreal/Core/Containers/ScriptArray.hpp>
#include <DynamicOutput/DynamicOutput.hpp>
#include <boost/uuid/uuid_io.hpp>
#include <bit>

using namespace RC;
using namespace RC::Unreal;

static const char* event_type_to_string(EMTEventType eventType)
{
	switch (eventType)
	{
	case EMTEventType::Race:
		return "Race";
	default:
		return "None";
	}
}

static const char* event_state_to_string(EMTEventState eventState)
{
	switch (eventState)
	{
	case EMTEventState::Ready:
		return "Ready";
	case EMTEventState::InProgress:
		return "InProgress";
	case EMTEventState::Finished:
		return "Finished";
	default:
		return "None";
	}
}

EventManager::EventManager()
{
	if (UFunction* serverAddEvent = UObjectGlobals::StaticFindObject<UFunction*>(
		nullptr,
		nullptr,
		STR("/Script/MotorTown.MotorTownPlayerController:ServerAddEvent")))
	{
		UObjectGlobals::RegisterHook(
			serverAddEvent,
			[](...) {},
			[&](UnrealScriptFunctionCallableContext& context, void* contextData) {
				// Skip on machines that runs on wine
				if (const char* wineEnv = getenv("WINEDLLOVERRIDES"))
				{
					return;
				}

				if (FStructProperty* event = static_cast<FStructProperty*>(
					context.TheStack.Node()->GetPropertyByNameInChain(STR("Event"))))
				{
					if (UStruct* eventStruct = event->GetStruct())
					{
						if (void* data = event->ContainerPtrToValuePtr<void>(context.TheStack.Locals()))
						{
							FMTEvent newEvent(eventStruct, data);
							Output::send<LogLevel::Verbose>(
								STR("[{}] New event {} created\n"),
								ModStatics::GetModName(),
								newEvent.EventName.GetCharArray());

							if (const char* url = ModStatics::GetWebhookUrl())
							{
								// TODO: Broadcast new event to webhook
							}
						}
					}
				}
			},
			nullptr);
	}

}

bool EventManager::IsMatchingRequest(http::request<http::string_body> req)
{
	if (req.target().starts_with("/events"))
	{
		return true;
	}

	return false;
}

json::object EventManager::GetResponseJson(http::request<http::string_body> req)
{
	json::object res;
	// Return all events
	if (req.method() == http::verb::get && req.target() == "/events")
	{
		json::array arr;
		for (const FMTEvent& event : GetEvents())
		{
			arr.push_back(event.ToJson());
		}
		res["data"] = arr;
	}
	return res;
}

std::vector<FMTEvent> EventManager::GetEvents()
{
	std::vector<FMTEvent> events;
	std::vector<UObject*> objs;
	UObjectGlobals::FindAllOf(STR("MTEventSystem"), objs);
	for (UObject* obj : objs)
	{
		Output::send<LogLevel::Verbose>(STR("Processing {}\n"), obj->GetFullName());
		if (FScriptArray* props = obj->GetValuePtrByPropertyNameInChain<FScriptArray>(STR("Events")))
		{
			auto arr = StaticCast<FArrayProperty*>(obj->GetPropertyByNameInChain(STR("Events")));
			for (int32_t i = 0; i < props->Num(); i++)
			{
			}
		}
	}

	return events;
}

FMTEvent::FMTEvent()
	: EventType(EMTEventType::None)
	, State(EMTEventState::None)
	, bInCountdown(false)
{
}

FMTEvent::FMTEvent(const FMTEvent& data)
	: FMTEvent()
{
	EventName = data.EventName;
	EventGuid = data.EventGuid;
	EventType = data.EventType;
	State = data.State;
	bInCountdown = data.bInCountdown;
}

FMTEvent::FMTEvent(UStruct* propertyStruct, void* data)
	: FMTEvent()
{
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("EventName")))
	{
		EventName = *name->ContainerPtrToValuePtr<FString>(data);
	}
	if (FProperty* guid = propertyStruct->GetPropertyByNameInChain(STR("EventGuid")))
	{
		EventGuid = *guid->ContainerPtrToValuePtr<FGuid>(data);
	}
	if (FProperty* type = propertyStruct->GetPropertyByNameInChain(STR("EventType")))
	{
		EventType = *type->ContainerPtrToValuePtr<EMTEventType>(data);
	}
	if (FProperty* state = propertyStruct->GetPropertyByNameInChain(STR("State")))
	{
		State = *state->ContainerPtrToValuePtr<EMTEventState>(data);
	}
	if (FProperty* cd = propertyStruct->GetPropertyByNameInChain(STR("State")))
	{
		bInCountdown = *cd->ContainerPtrToValuePtr<bool>(data);
	}
	if (FStructProperty* owner = StaticCast<FStructProperty*>(
		propertyStruct->GetPropertyByNameInChain(STR("OwnerCharacterId"))))
	{
		void* ownerData = owner->ContainerPtrToValuePtr<void>(data);
		OwnerCharacterId = FMTCharacterId(owner->GetStruct(), ownerData);
	}
	if (FArrayProperty* playersProp = StaticCast<FArrayProperty*>(
		propertyStruct->GetPropertyByNameInChain(STR("Players"))))
	{
		void* playersData = playersProp->ContainerPtrToValuePtr<void>(data);
		if (auto players = playersProp->ContainerPtrToValuePtr<TArray<UStruct*>>(data))
		{
			Output::send<LogLevel::Verbose>(STR("Found {} player(s)\n"), players->Num());
			for (auto* player : *players)
			{
				if (auto playerName = player->GetPropertyByNameInChain(STR("PlayerName")))
				{
					auto name = playerName->ContainerPtrToValuePtr<FString>(playersData);
					Output::send<LogLevel::Verbose>(STR("PlayerName: {}\n"), name->GetCharArray());
				}
			}
		}
	}
	if (FStructProperty* race = StaticCast<FStructProperty*>(
		propertyStruct->GetPropertyByNameInChain(STR("RaceSetup"))))
	{
		void* raceData = race->ContainerPtrToValuePtr<void>(data);
		RaceSetup = FMTRaceEventSetup(race->GetStruct(), raceData);
	}
}

json::object FMTEvent::ToJson() const
{
	json::object obj;
	obj["EventName"] = to_string(EventName.GetCharArray());
	obj["EventGuid"] = ModStatics::GuidToString(EventGuid);
	obj["EventType"] = event_type_to_string(EventType);
	obj["State"] = event_state_to_string(State);
	obj["InCountdown"] = bInCountdown;
	obj["OwnerCharacterId"] = OwnerCharacterId.ToJson();

	json::array arr;
	for (const FMTEventPlayer& player : Players)
	{
		arr.push_back(player.ToJson());
	}
	obj["Players"] = arr;
	obj["RaceSetup"] = RaceSetup.ToJson();

	return obj;
}

json::object FMTEventPlayer::ToJson() const
{
	json::object obj;
	obj["CharacterId"] = CharacterId.ToJson();
	obj["PlayerName"] = to_string(PlayerName.GetCharArray());
	obj["Rank"] = Rank;
	obj["SectionIndex"] = SectionIndex;
	obj["Laps"] = Laps;
	obj["bDisqualified"] = bDisqualified;
	obj["bFinished"] = bFinished;
	obj["bWrongVehicle"] = bWrongVehicle;
	obj["bWrongEngine"] = bWrongEngine;
	obj["LastSectionTotalTimeSeconds"] = LastSectionTotalTimeSeconds;

	json::array arr;
	for (const float& lapTime : LapTimes)
	{
		arr.push_back(lapTime);
	}
	obj["LapTimes"] = arr;
	obj["BestLapTime"] = BestLapTime;
	obj["Reward_RacingExp"] = Reward_RacingExp;
	obj["Reward_Money"] = Reward_Money.ToJson();
	return obj;
}

FMTRaceEventSetup::FMTRaceEventSetup()
{
}

FMTRaceEventSetup::FMTRaceEventSetup(UStruct* propertyStruct, void* data)
	: FMTRaceEventSetup()
{
	if (FStructProperty* route = StaticCast<FStructProperty*>(
		propertyStruct->GetPropertyByNameInChain(STR("Route"))))
	{
		void* routeData = route->ContainerPtrToValuePtr<void>(data);
		Route = FMTRoute(route->GetStruct(), routeData);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("NumLaps")))
	{
		NumLaps = *name->ContainerPtrToValuePtr<int32>(data);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("VehicleKeys")))
	{
		VehicleKeys = *name->ContainerPtrToValuePtr<TArray<FName>>(data);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("EngineKeys")))
	{
		EngineKeys = *name->ContainerPtrToValuePtr<TArray<FName>>(data);
	}
}

json::object FMTRaceEventSetup::ToJson() const
{
	json::object obj;
	obj["Route"] = Route.ToJson();
	obj["NumLaps"] = NumLaps;
	json::array arr;
	for (const FName& key : VehicleKeys)
	{
		arr.push_back(to_string(key.ToString()).c_str());
	}
	obj["VehicleKeys"] = arr;

	json::array arr2;
	for (const FName& key : EngineKeys)
	{
		arr.push_back(to_string(key.ToString()).c_str());
	}
	obj["EngineKeys"] = arr2;

	return obj;
}
