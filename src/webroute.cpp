#include "webroute.h"

Route::Route()
{
}

bool Route::is_request_match(http::request<http::string_body> req)
{
	return false;
}

json::object Route::get_response(http::request<http::string_body> req)
{
	return json::object();
}
