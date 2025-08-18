#pragma once

#include "webroute.h"

class ModsManager : public Route
{
public:
	virtual bool IsMatchingRequest(const http::request<http::string_body>& req) const override;
	virtual bool IsMatchingRequest(const json::object& req) const override;
	virtual json::object GetResponseJson(const http::request<http::string_body>& req, http::status& statusCode) override;
	virtual json::object GetResponseJson(const json::object& req) override;
};
