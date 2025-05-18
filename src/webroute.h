#pragma once

// Workaround against multiple check definitions
#pragma push_macro("check")
#undef check
#include <boost/beast.hpp>
#include <boost/json.hpp>
#pragma pop_macro("check")
#include <boost/asio.hpp>
#include <boost/thread.hpp>

namespace asio = boost::asio;
namespace beast = boost::beast;
namespace http = beast::http;
namespace json = boost::json;

// Generic response object
class Route
{
public:
	Route();
	virtual ~Route() {};

	virtual bool is_request_match(http::request<http::string_body> req);
	virtual json::object get_response(http::request<http::string_body> req);
};
