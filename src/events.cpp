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

	if (UFunction* serverChangeEvent = UObjectGlobals::StaticFindObject<UFunction*>(
		nullptr,
		nullptr,
		STR("/Script/MotorTown.MotorTownPlayerController:ServerChangeEventState")))
	{
		UObjectGlobals::RegisterHook(
			serverChangeEvent,
			[](...) {},
			[&](UnrealScriptFunctionCallableContext& context, void* contextData) {
				// Skip on machines that runs on wine
				if (const char* wineEnv = getenv("WINEDLLOVERRIDES"))
				{
					return;
				}

				FGuid* eventGuid = context.TheStack.Node()->GetValuePtrByPropertyNameInChain<FGuid>(
					STR("EventGuid"));

				EMTEventState* eventState = context.TheStack.Node()->GetValuePtrByPropertyNameInChain<EMTEventState>(
					STR("EventState"));
				if (eventGuid && eventState)
				{
					Output::send<LogLevel::Verbose>(STR("[{}] Event {} state changed to {}\n"),
						ModStatics::GetModName(),
						to_wstring(ModStatics::GuidToString(*eventGuid)),
						to_wstring(event_state_to_string(*eventState)));

					if (const char* url = ModStatics::GetWebhookUrl())
					{
						// TODO: Broadcast new event to webhook
					}
				}
			},
			nullptr);
	}

	if (UFunction* serverChangeEvent = UObjectGlobals::StaticFindObject<UFunction*>(
		nullptr,
		nullptr,
		STR("/Script/MotorTown.MotorTownPlayerController:ServerRemoveEvent")))
	{
		UObjectGlobals::RegisterHook(
			serverChangeEvent,
			[](...) {},
			[&](UnrealScriptFunctionCallableContext& context, void* contextData) {
				// Skip on machines that runs on wine
				if (const char* wineEnv = getenv("WINEDLLOVERRIDES"))
				{
					return;
				}

				if (FGuid* eventGuid = context.TheStack.Node()->GetValuePtrByPropertyNameInChain<FGuid>(
					STR("EventGuid")))
				{
					Output::send<LogLevel::Verbose>(STR("[{}] Event {} state ended\n"),
						ModStatics::GetModName(),
						to_wstring(ModStatics::GuidToString(*eventGuid)));

					if (const char* url = ModStatics::GetWebhookUrl())
					{
						// TODO: Broadcast new event to webhook
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

static uint8* GetData(FScriptArray* ScriptArray, int32 ElementSize, int32 Index)
{
	return static_cast<uint8*>(ScriptArray->GetData()) + Index * ElementSize;
}

std::vector<FMTEvent> EventManager::GetEvents()
{
	std::vector<FMTEvent> out_events;
	std::vector<UObject*> objs;
	UObjectGlobals::FindAllOf(STR("MTEventSystem"), objs);
	for (UObject* obj : objs)
	{
		if (auto props = obj->GetValuePtrByPropertyNameInChain<FScriptArray>(STR("Net_Events")))
		{
			auto arr = StaticCast<FArrayProperty*>(obj->GetPropertyByNameInChain(STR("Net_Events")));
			const int32 elementSize = arr->GetInner()->GetElementSize();
			auto str = static_cast<FStructProperty*>(arr->GetInner());
			for (int32_t i = 0; i < props->Num(); i++)
			{
				const int32 offset = i * elementSize;
				auto elem = static_cast<uint8*>(props->GetData()) + offset;
				FMTEvent event(str->GetStruct(), elem);
				out_events.push_back(event);
			}
		}
	}

	return out_events;
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
	if (FScriptArray* structArr = propertyStruct->GetValuePtrByPropertyNameInChain<FScriptArray>(
		STR("Players")))
	{
		FArrayProperty* arr = StaticCast<FArrayProperty*>(
			propertyStruct->GetPropertyByNameInChain(STR("Players")));
		const int32 elemSize = arr->GetInner()->GetElementSize();
		auto str = static_cast<FStructProperty*>(arr->GetInner());
		for (int32_t i = 0; i < structArr->Num(); i++)
		{
			const int32 offset = i * elemSize;
			auto elem = static_cast<uint8*>(structArr->GetData()) + offset;
			Players.Emplace(str->GetStruct(), elem);
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

FMTEventPlayer::FMTEventPlayer()
{
}

FMTEventPlayer::FMTEventPlayer(UStruct* propertyStruct, void* data)
	: FMTEventPlayer()
{
	if (FStructProperty* owner = StaticCast<FStructProperty*>(
		propertyStruct->GetPropertyByNameInChain(STR("CharacterId"))))
	{
		void* ownerData = owner->ContainerPtrToValuePtr<void>(data);
		CharacterId = FMTCharacterId(owner->GetStruct(), ownerData);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("PlayerName")))
	{
		PlayerName = *name->ContainerPtrToValuePtr<FString>(data);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("Rank")))
	{
		Rank = *name->ContainerPtrToValuePtr<int32>(data);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("SectionIndex")))
	{
		SectionIndex = *name->ContainerPtrToValuePtr<int32>(data);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("Laps")))
	{
		Laps = *name->ContainerPtrToValuePtr<int32>(data);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("bDisqualified")))
	{
		bDisqualified = *name->ContainerPtrToValuePtr<bool>(data);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("bFinished")))
	{
		bFinished = *name->ContainerPtrToValuePtr<bool>(data);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("bWrongVehicle")))
	{
		bWrongVehicle = *name->ContainerPtrToValuePtr<bool>(data);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("bWrongEngine")))
	{
		bWrongEngine = *name->ContainerPtrToValuePtr<bool>(data);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("LastSectionTotalTimeSeconds")))
	{
		LastSectionTotalTimeSeconds = *name->ContainerPtrToValuePtr<float>(data);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("LapTimes")))
	{
		LapTimes = *name->ContainerPtrToValuePtr<TArray<float>>(data);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("BestLapTime")))
	{
		BestLapTime = *name->ContainerPtrToValuePtr<float>(data);
	}
	if (FProperty* name = propertyStruct->GetPropertyByNameInChain(STR("Reward_RacingExp")))
	{
		Reward_RacingExp = *name->ContainerPtrToValuePtr<int32>(data);
	}
	if (FStructProperty* reward = StaticCast<FStructProperty*>(
		propertyStruct->GetPropertyByNameInChain(STR("Reward_Money"))))
	{
		void* rewardData = reward->ContainerPtrToValuePtr<void>(data);
		Reward_Money = FMTShadowedInt64(reward->GetStruct(), rewardData);
	}
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
