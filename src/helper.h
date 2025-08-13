#pragma once

#include <iostream>
#include <mutex>
#include <Unreal/UObjectGlobals.hpp>

using namespace RC;
using namespace RC::Unreal;

class GameHelper
{
private:
	// GameState
	UObject* GameState = nullptr;

	// Static pointer to the helper instance
	static GameHelper* instancePtr;

	// Mutex to ensure thread safety
	static std::mutex mtx;

	// Private constructor
	GameHelper() {}

public:
	GameHelper(const GameHelper& obj) = delete; // Prevent copy operator
	GameHelper& operator=(const GameHelper&) = delete; // Also delete assignment operator

	// Get the helper instance
	static GameHelper* get();

	// Get game state
	UObject* GetGameState();
};
