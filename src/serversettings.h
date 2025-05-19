#include "webroute.h"

#include <Unreal/FString.hpp>

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

class ServerSettings : public Route
{
public:
	ServerSettings();
	virtual bool IsMatchingRequest(http::request<http::string_body> req) override;
	virtual json::object GetResponseJson(http::request<http::string_body> req) override;
};
