#include "serversettings.h"

ServerSettings::ServerSettings()
{
}

bool ServerSettings::IsMatchingRequest(http::request<http::string_body> req)
{
	return false;
}

json::object ServerSettings::GetResponseJson(http::request<http::string_body> req)
{
	return json::object();
}
