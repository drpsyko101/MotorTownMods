#include <Unreal/UnrealCoreStructs.hpp>
#include "webroute.h"

using namespace RC;
using namespace RC::Unreal;
using namespace std;

class PlayerManager : public Route
{
	map<string, FVector> player_locations;
public:
	PlayerManager();
	virtual bool is_request_match(http::request<http::string_body> req) override;
	virtual json::object get_response(http::request<http::string_body> req) override;

private:
	map<string, FVector> get_player_locations();
};
