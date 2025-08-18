#pragma once

#include "webroute.h"

#include <Unreal/FString.hpp>
#include <Unreal/NameTypes.hpp>
#include "statics.h"

using namespace RC;
using namespace RC::Unreal;

struct FMTDediConfigAdmin
{
	FString UniqueNetId;
	FString Nickname;
};

struct FMTDediConfig
{
	FString ServerName;
	FString Password;
	FString ServerMessage;
	int32 MaxPlayers;
	int32 MaxVehiclePerPlayer;
	bool bAllowPlayerToJoinWithCompanyVehicles;
	bool bAllowCompanyAIDriver;
	TArray<FMTDediConfigAdmin> Admins;
	int32 MaxHousingPlotRentalDays;
	float HousingPlotRentalPriceRatio;
	int32 MaxHousingPlotRentalPerPlayer;
	bool bAllowModdedVehicle;
	bool bEnableHostWebAPIServer;
	FString HostWebAPIServerPassword;
	int32 HostWebAPIServerPort;
	float NPCVehicleDensity;
	float NPCPoliceDensity;
};

enum class EMTAIVehicleSpawnType : uint8
{
    None = 0,
    TowRequest = 1,
    TowRequest_Rescue = 2,
    TowRequest_Delivery = 3,
    Getaway = 4,
};

enum class EMTVehicleType : uint8
{
    None = 0,
    Kart = 1,
    Small = 2,
    Pickup = 3,
    Bus = 4,
    Truck = 5,
    SemiTractor = 6,
    SemiTrailer = 7,
    SmallTrailer = 8,
    Motorhome = 9,
    Caravan = 10,
    HeavyMachinery = 11,
    Bike = 12,
    Racecar = 13,
};

enum class EMTTimeOfDayScheduleType : uint8
{
    None = 0,
    BusPassengerSpawnMultiplayer = 1,
    SchoolBusPassengerSpawnMultiplayer = 2,
    Count = 3,
};

struct FMTAIVehicleSpawnSetting
{
    FName SettingKey;                                       // 0x0000 (size: 0x8)
    EMTAIVehicleSpawnType SpawnType;                        // 0x0008 (size: 0x4)
    uint8_t VehicleClass[8] = {};                           // 0x0010 (size: 0x8)
    FName VehicleKey;                                       // 0x0018 (size: 0x8)
    TArray<EMTVehicleType> VehicleTypes;                    // 0x0020 (size: 0x10)
    uint8_t GameplayTagQuery[48] = {};                      // 0x0030 (size: 0x48)
    uint8_t GameplayTagQuery2[48] = {};                     // 0x0078 (size: 0x48)
    bool bSpawnAIController = false;                        // 0x00C0 (size: 0x1)
    bool bIsTrafficVehicle = false;                         // 0x00C1 (size: 0x1)
    bool bSpawnRoadSide = false;                            // 0x00C2 (size: 0x1)
    bool bDespawnIfPlayersAreFar = false;                   // 0x00C3 (size: 0x1)
    bool bAllowCloseToPlayer = false;                       // 0x00C4 (size: 0x1)
    bool bAllowCloseToOtherVehicle = false;                 // 0x00C5 (size: 0x1)
    bool bDespawnIfNotMoveForLong = false;                  // 0x00C6 (size: 0x1)
    float MaxLifetimeSeconds = 0.f;                         // 0x00C8 (size: 0x4)
    int32 MaxCount = 1;                                     // 0x00CC (size: 0x4)
    int32 MinCount = -1;                                    // 0x00D0 (size: 0x4)
    bool bUseNPCVehicleDensity = false;                     // 0x00D4 (size: 0x1)
    bool bUseNPCPoliceDensity = false;                      // 0x00D5 (size: 0x1)
    float SpawnOverMinCountCoolDownTimeSeconds = 0.f;       // 0x00D8 (size: 0x4)
    EMTTimeOfDayScheduleType CountMultiplierScheduleType;   // 0x00DC (size: 0x1)
    float MinDistanceFromRoad = 0.f;                        // 0x00E0 (size: 0x4)
    float MaxDistanceFromRoad = 0.f;                        // 0x00E4 (size: 0x4)
    bool bIncludeTrailer = false;                           // 0x00E8 (size: 0x1)
}; // Size: 0xF8

class ServerSettings : public Route
{
public:
	ServerSettings();
	virtual bool IsMatchingRequest(const http::request<http::string_body>& req) const override;
	virtual json::object GetResponseJson(const http::request<http::string_body>& req, http::status& statusCode) override;

private:
    boost::json::value GetVehicleSpawnSettings() const;
};
