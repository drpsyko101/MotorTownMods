#include "modsmanager.h"

#include <UE4SSProgram.hpp>

static const char* modsReloadPath = "/mods/reload";

bool ModsManager::IsMatchingRequest(const http::request<http::string_body>& req) const
{
	if (req.target().starts_with(modsReloadPath) && req.method() == http::verb::post)
	{
		return true;
	}
	else if (req.target() == "/status")
	{
		return true;
	}
	return false;
}

bool ModsManager::IsMatchingRequest(const json::object& req) const
{
	if (req.contains("action") && req.at("action").as_string() == "getStatus") return true;

	return false;
}

json::object ModsManager::GetResponseJson(const http::request<http::string_body>& req, http::status& statusCode)
{
	json::object obj;
	if (req.target() == modsReloadPath)
	{
		if (req.method() == http::verb::post)
		{
			UE4SSProgram::get_program().reinstall_mods();
			statusCode = http::status::accepted;
			obj["status"] = "received mods reload signal";
			return obj;
		}
	}
	return obj;
}

json::object ModsManager::GetResponseJson(const json::object& req)
{
	json::object obj;
	if (req.contains("action") && req.at("action").as_string() == "getStatus")
	{
		obj["status"] = "ok";
	}
	return obj;
}
