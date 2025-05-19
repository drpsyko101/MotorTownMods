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

static json::object EventPlayerToJson(FMTEventPlayer eventPlayer)
{
	json::object obj;
	obj["CharacterId"] = ModStatics::CharacterIdToJson(eventPlayer.CharacterId);
	obj["PlayerName"] = to_string(eventPlayer.PlayerName.GetCharArray());
	obj["Rank"] = eventPlayer.Rank;
	obj["SectionIndex"] = eventPlayer.SectionIndex;
	obj["Laps"] = eventPlayer.Laps;
	obj["bDisqualified"] = eventPlayer.bDisqualified;
	obj["bFinished"] = eventPlayer.bFinished;
	obj["bWrongVehicle"] = eventPlayer.bWrongVehicle;
	obj["bWrongEngine"] = eventPlayer.bWrongEngine;
	obj["LastSectionTotalTimeSeconds"] = eventPlayer.LastSectionTotalTimeSeconds;

	json::array arr;
	for (const float& lapTime : eventPlayer.LapTimes)
	{
		arr.push_back(lapTime);
	}
	obj["LapTimes"] = arr;
	obj["BestLapTime"] = eventPlayer.BestLapTime;
	obj["Reward_RacingExp"] = eventPlayer.Reward_RacingExp;
	obj["Reward_Money"] = ModStatics::ShadowedIntToJson(eventPlayer.Reward_Money);
	return obj;
}

static json::object RaceEventSetupToJson(FMTRaceEventSetup eventSetup)
{
	json::object obj;
	obj["Route"] = ModStatics::RouteToJson(eventSetup.Route);
	obj["NumLaps"] = eventSetup.NumLaps;
	json::array arr;
	for (const FName& key : eventSetup.VehicleKeys)
	{
		arr.push_back(to_string(key.ToString()).c_str());
	}
	obj["VehicleKeys"] = arr;

	json::array arr2;
	for (const FName& key : eventSetup.EngineKeys)
	{
		arr.push_back(to_string(key.ToString()).c_str());
	}
	obj["EngineKeys"] = arr2;

	return obj;
}

static json::object EventToJson(FMTEvent event)
{
	json::object obj;
	obj["EventName"] = to_string(event.EventName.GetCharArray());
	obj["EventGuid"] = ModStatics::GuidToString(event.EventGuid);
	obj["EventType"] = event_type_to_string(event.EventType);
	obj["State"] = event_state_to_string(event.State);
	obj["InCountdown"] = event.bInCountdown;
	//obj["OwnerCharacterId"] = ModStatics::CharacterIdToJson(*event.OwnerCharacterId);

	//json::array arr;
	//for (const FMTEventPlayer& player : Players)
	//{
	//	arr.push_back(player.create_json_object());
	//}
	//obj["Players"] = arr;
	//obj["RaceSetup"] = RaceSetup.create_json_object();

	return obj;
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
			[](UnrealScriptFunctionCallableContext& context, void* data) {
				// Skip on machines that runs on wine
				if (const char* wineEnv = getenv("WINEDLLOVERRIDES"))
				{
					return;
				}

				// TODO: Broadcast new event to webhook
				Output::send<LogLevel::Verbose>(STR("Getting event property...\n"));
				if (FStructProperty* event = static_cast<FStructProperty*>(
					context.TheStack.Node()->GetPropertyByNameInChain(STR("Event"))))
				{
					Output::send<LogLevel::Verbose>(STR("Getting event struct...\n"));
					if (UStruct* eventStruct = event->GetStruct())
					{
						Output::send<LogLevel::Verbose>(STR("Getting event data...\n"));
						if (void* a = event->ContainerPtrToValuePtr<void>(context.TheStack.Locals()))
						{
							Output::send<LogLevel::Verbose>(STR("Getting event name property...\n"));
							if (FProperty* name = eventStruct->GetPropertyByNameInChain(STR("EventName")))
							{
								Output::send<LogLevel::Verbose>(STR("Getting event name value...\n"));
								if (FString* eventName = name->ContainerPtrToValuePtr<FString>(a))
								{
									Output::send<LogLevel::Verbose>(
										STR("New event {} created\n"),
										eventName->GetCharArray());
								}
							}
						}
					}
				}
			},
			nullptr);
	}

}

bool EventManager::is_request_match(http::request<http::string_body> req)
{
	if (req.target().starts_with("/events"))
	{
		return true;

	}

	return false;
}

json::object EventManager::get_response(http::request<http::string_body> req)
{
	json::object res;
	// Return all events
	if (req.method() == http::verb::get && req.target() == "/events")
	{
		json::array arr;
		for (const FMTEvent& event : get_events())
		{
			arr.push_back(EventToJson(event));
		}
		res["data"] = arr;
	}
	return res;
}

std::vector<FMTEvent> EventManager::get_events()
{
	std::vector<FMTEvent> events;
	std::vector<UObject*> objs;
	UObjectGlobals::FindAllOf(STR("MTEventSystem"), objs);
	for (UObject* obj : objs)
	{
		Output::send<LogLevel::Verbose>(STR("Processing {}\n"), obj->GetFullName());
		if (FMTEventArray* eventProps = obj->GetValuePtrByPropertyNameInChain<FMTEventArray>(
			STR("Net_Events")))
		{
			for (const FMTEvent& event : eventProps->Events)
			{
				Output::send<LogLevel::Verbose>(STR("Found event {}\n"), event.EventName.GetCharArray());
				events.push_back(event);
			}
		}
	}

	return events;
}
