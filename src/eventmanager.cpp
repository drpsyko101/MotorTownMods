#include "eventManager.h"
#include "helper.h"

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
#include <Helpers/String.hpp>
#include <Unreal/Core/Containers/ScriptArray.hpp>
#include <DynamicOutput/DynamicOutput.hpp>
#include <regex>
#include <boost/url.hpp>

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
	// Handle new event creation
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
				if (ModStatics::IsRunningOnWine()) return;

				if (FStructProperty* event = static_cast<FStructProperty*>(
					context.TheStack.Node()->GetPropertyByNameInChain(STR("Event"))))
				{
					if (UStruct* eventStruct = event->GetStruct())
					{
						if (void* data = event->ContainerPtrToValuePtr<void>(context.TheStack.Locals()))
						{
							boost::json::object obj = ModStatics::StructToJson(eventStruct, data);

							// TODO: Fix broadcast webhook struct failure
							//SendWebhookEvent(newEvent.ToJson());
						}
					}
				}
			},
			nullptr);
	}

	// Handle event state change
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
				if (ModStatics::IsRunningOnWine()) return;

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

					// TODO: Broadcast webhook
				}
			},
			nullptr);
	}

	// Handle event deletion
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
				if (ModStatics::IsRunningOnWine()) return;

				if (FGuid* eventGuid = context.TheStack.Node()->GetValuePtrByPropertyNameInChain<FGuid>(
					STR("EventGuid")))
				{
					Output::send<LogLevel::Verbose>(STR("[{}] Event {} removed\n"),
						ModStatics::GetModName(),
						to_wstring(ModStatics::GuidToString(*eventGuid)));

					// TODO: Broadcast to webhook
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

json::object EventManager::GetResponseJson(http::request<http::string_body> req, http::status& statusCode)
{
	json::object res;
	std::regex reg("^/events/");
	if (req.target() == "/events" && req.method() == http::verb::get)
	{
		res["data"] = GetEvents();
		statusCode = http::status::ok;
		return res;
	}
	else if (req.target() == "/events" && req.method() == http::verb::post)
	{
		return res;
		// TODO: Fix create event
		try
		{
			json::value val = json::parse(req.body());
			if (!val.is_object())
			{
				throw std::invalid_argument("parse: invalid object type received");
			}
			FMTEvent event(val.as_object());
			if (CreateNewEvent(event))
			{
				//res["data"] = event.ToJson();
			}
		}
		catch (const std::exception& e)
		{
			Output::send<LogLevel::Error>(STR("[{}] Failed to create a new event: {}"),
				ModStatics::GetModName(),
				to_wstring(e.what()));
		}
		return res;
	}
	else if (std::regex_match(std::string(req.target()), reg) && req.method() == http::verb::get)
	{
		std::vector<std::string> pathSegments;
		try
		{
			boost::url_view url(req.target());
			auto segments = url.segments();
			for (auto segment : segments)
			{
				pathSegments.push_back(std::string(segment));
			}
		}
		catch (std::exception&) {}

		auto guid = ModStatics::StringToGuid(pathSegments[1]);
		res["data"] = GetEvents(guid);
		statusCode = http::status::ok;
		return res;
	}
	else if (std::regex_match(std::string(req.target()), reg) && req.method() == http::verb::patch)
	{
		json::value val = json::parse(req.body());

		if (!val.is_object())
		{
			Output::send<LogLevel::Error>(STR("[{}] Invalid payload for {}\n"),
				ModStatics::GetModName(),
				to_wstring(req.target().data()));
			return res;
		}

		json::object obj = val.as_object();
		// TODO: make modification

		return res;
	}
	return res;
}

static uint8* GetData(FScriptArray* ScriptArray, int32 ElementSize, int32 Index)
{
	return static_cast<uint8*>(ScriptArray->GetData()) + Index * ElementSize;
}

boost::json::value EventManager::GetEvents(FGuid eventGuid, const int depth) const
{
	UObject* gameState = GameHelper::get()->GetGameState();
	if (gameState)
	{
		UObject* eventManager = *gameState->GetValuePtrByPropertyNameInChain<UObject*>(STR("Net_EventSystem"));
		if (eventManager)
		{
			ModStatics::LogOutput(L"eventManger isValid");
			auto event = ModStatics::ObjectToJson(eventManager, L"", L"MTEventSystem", depth);
			return event["Net_Events"];
		}
	}

	return boost::json::array();
}

bool EventManager::CreateNewEvent(FMTEvent& Event)
{
	if (auto func = UObjectGlobals::StaticFindObject<UFunction*>(
		nullptr,
		nullptr,
		STR("/Script/MotorTown.MotorTownPlayerController:ServerAddEvent")))
	{
		if (auto PC = static_cast<AActor*>(
			UObjectGlobals::FindFirstOf(STR("MotorTownPlayerController"))))
		{
			PC->ProcessEvent(func, &Event);
			return true;
		}
	}
	return false;
}

FMTEvent::FMTEvent()
	: EventType(EMTEventType::None)
	, State(EMTEventState::None)
{
}

FMTEvent::FMTEvent(std::string eventName)
	: FMTEvent()
{
	EventName = FString(TEXT("TestName"));
}

FMTEvent::FMTEvent(const json::object object)
	: FMTEvent()
{
}
