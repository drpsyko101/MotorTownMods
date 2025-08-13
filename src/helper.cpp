#include "helper.h"

GameHelper* GameHelper::instancePtr = nullptr;
std::mutex GameHelper::mtx;

GameHelper* GameHelper::get()
{
	if (instancePtr == nullptr)
	{
		std::lock_guard<std::mutex> lock(mtx);
		if (instancePtr == nullptr)
		{
			instancePtr = new GameHelper();
		}
	}
	return instancePtr;
}

UObject* GameHelper::GetGameState()
{
	if (GameState) return GameState;

	GameState = UObjectGlobals::FindFirstOf(STR("MotorTownGameState"));
	return GameState;
}
