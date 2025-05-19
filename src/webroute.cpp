#include "webroute.h"

Route::Route()
{
}

bool Route::IsMatchingRequest(http::request<http::string_body> req)
{
	return false;
}

json::object Route::GetResponseJson(http::request<http::string_body> req)
{
	return json::object();
}
