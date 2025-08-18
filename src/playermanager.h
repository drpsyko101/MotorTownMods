#pragma once

#include <Unreal/UnrealCoreStructs.hpp>
#include "webroute.h"
#include "statics.h"
#include <memory>

using namespace RC;
using namespace RC::Unreal;
using namespace std;

class PlayerManager : public Route
{
public:
	PlayerManager();
	virtual bool IsMatchingRequest(const http::request<http::string_body>& req) const override;
	virtual bool IsMatchingRequest(const json::object& req) const override;
	virtual json::object GetResponseJson(const http::request<http::string_body>& req, http::status& statusCode) override;
	virtual json::object GetResponseJson(const json::object& req) override;

private:
	boost::json::value GetPlayerStates() const;
};
