#pragma once

// Workaround against multiple check definitions
#pragma push_macro("check")
#undef check
#include <boost/beast.hpp>
#pragma pop_macro("check")
#include <boost/asio.hpp>
#include <boost/thread.hpp>
#include <boost/json.hpp>
#include <list>
#include <memory>
#include <vector>

namespace beast = boost::beast;         // from <boost/beast.hpp>
namespace http = beast::http;           // from <boost/beast/http.hpp>
namespace net = boost::asio;            // from <boost/asio.hpp>
namespace json = boost::json;
using tcp = boost::asio::ip::tcp;       // from <boost/asio/ip/tcp.hpp>

class Route;

// Handles websocket connections
class Websocket
{
	net::io_context ioc;
	tcp::acceptor acceptor;
	std::vector<boost::shared_ptr<boost::thread>> serverWorkers;
	std::list<std::shared_ptr<Route>> responses;

	// Static pointer to the helper instance
	static Websocket* instancePtr;

	// Mutex to ensure thread safety
	static std::mutex mtx;

public:
	static Websocket* Get();
	bool handle_response(const json::value& req, json::object& res) const;

private:
    Websocket();
	~Websocket();

	void do_accept();
};
