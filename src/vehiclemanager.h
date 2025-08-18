#pragma once

#include <Unreal/UnrealCoreStructs.hpp>
#include "webroute.h"
#include "statics.h"
#include <memory>

using namespace RC;
using namespace RC::Unreal;
using namespace std;

class VehicleManager : public Route
{
public:
	VehicleManager();
	virtual bool IsMatchingRequest(const http::request<http::string_body>& req) const override;
	virtual json::object GetResponseJson(const http::request<http::string_body>& req, http::status& statusCode) override;
};
