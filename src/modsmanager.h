#pragma once

#include "webroute.h"

class ModsManager : public Route
{
public:
	virtual bool IsMatchingRequest(http::request<http::string_body> req) override;
	virtual json::object GetResponseJson(http::request<http::string_body> req, http::status& statusCode) override;
};
