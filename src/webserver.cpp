#include "webserver.h"
#include "statics.h"
#include "modsmanager.h"
#include "playermanager.h"
#include "eventmanager.h"
#include "serversettings.h"
#include "vehiclemanager.h"

#include <DynamicOutput/DynamicOutput.hpp>
#include <Helpers/String.hpp>
#include <Unreal/UObjectGlobals.hpp>
#include <chrono>
#include <memory>
#include <string>
#include <utility>

// Workaround against multiple check definitions
#pragma push_macro("check")
#undef check
#include <boost/beast.hpp>
#include <boost/json.hpp>
#pragma pop_macro("check")

using namespace RC;
using namespace RC::Unreal;
namespace json = boost::json;

Webserver* Webserver::instancePtr = nullptr;
std::mutex Webserver::mtx;

// Handles an HTTP server connection
class HttpSession : public std::enable_shared_from_this<HttpSession>
{
	tcp::socket socket_;
	beast::flat_buffer buffer_;
	http::request<http::string_body> req_;
	Webserver* webserver_;

public:
	HttpSession(tcp::socket socket, Webserver* server)
		: socket_(std::move(socket)), webserver_(server)
	{
	}

	// Start the session
	void run()
	{
		do_read();
	}

private:
	void do_read()
	{
		// Make the request empty before reading,
		// otherwise the operation behavior is undefined.
		req_ = {};

		http::async_read(socket_, buffer_, req_,
			beast::bind_front_handler(
				&HttpSession::on_read,
				shared_from_this()));
	}

	void on_read(beast::error_code ec, std::size_t bytes_transferred)
	{
		boost::ignore_unused(bytes_transferred);

		// This means they closed the connection
		if (ec == http::error::end_of_stream)
			return do_close();

		if (ec) {
			ModStatics::LogOutput<LogLevel::Error>(L"Server read error: {}", to_wstring(ec.message()));
			return;
		}

		// Create the response and send it
		http::response<http::string_body> res;
		res.body() = webserver_->handle_request(req_, res);
		res.set(http::field::content_type, "application/json");
		res.prepare_payload();

		do_write(std::move(res));
	}

	void do_write(http::response<http::string_body>&& res)
	{
		auto sp = std::make_shared<http::response<http::string_body>>(std::move(res));

		http::async_write(socket_, *sp,
			[self = shared_from_this(), sp](beast::error_code ec, std::size_t bytes)
			{
				self->on_write(ec, bytes);
			});
	}

	void on_write(beast::error_code ec, std::size_t bytes_transferred)
	{
		boost::ignore_unused(bytes_transferred);

		if (ec) {
			ModStatics::LogOutput<LogLevel::Error>(L"Server write error: {}", to_wstring(ec.message()));
		}

		do_close();
	}

	void do_close()
	{
		beast::error_code ec;
		socket_.shutdown(tcp::socket::shutdown_send, ec);
	}
};


Webserver::Webserver() : ioc(), acceptor(ioc) 
{
	if (const char* val = getenv("MOD_MANAGEMENT_PORT"))
	{
		Port = atoi(val);
	}

	responses.push_back(std::make_shared<ModsManager>());
	responses.push_back(std::make_shared<PlayerManager>());
	responses.push_back(std::make_shared<EventManager>());
	responses.push_back(std::make_shared<ServerSettings>());
	responses.push_back(std::make_shared<VehicleManager>());

	int numWorker = 1;
	if (const char* val = getenv("MOD_MANAGEMENT_WORKER"))
	{
		numWorker = atoi(val);
	}

	try {
		tcp::endpoint endpoint(tcp::v4(), Port);
		acceptor.open(endpoint.protocol());
		acceptor.set_option(asio::socket_base::reuse_address(true));
		acceptor.bind(endpoint);
		acceptor.listen(asio::socket_base::max_listen_connections);
	}
	catch (const std::exception& e) {
		ModStatics::LogOutput<LogLevel::Error>(L"Failed to setup acceptor: {}", to_wstring(e.what()));
		return;
	}

	do_accept();

	ModStatics::LogOutput(L"API server listening at {}", Port);

	serverWorkers.reserve(numWorker);
	for (int i = 0; i < numWorker; i++)
	{
		auto worker = boost::make_shared<boost::thread>([this]() { ioc.run(); });
		serverWorkers.push_back(worker);
	}
}

Webserver::~Webserver()
{
	ioc.stop();
	for (auto& worker : serverWorkers)
	{
		if (worker->joinable()) {
			worker->join();
		}
	}
}

Webserver* Webserver::Get() 
{
	if (instancePtr == nullptr)
	{
		std::lock_guard<std::mutex> lock(mtx);
		if (instancePtr == nullptr)
		{
			instancePtr = new Webserver();
		}
	}
	return instancePtr;
}

bool Webserver::isServerRunning()
{
	return !ioc.stopped();
}

void Webserver::do_accept()
{
	acceptor.async_accept(
		asio::make_strand(ioc),
		[this](beast::error_code ec, tcp::socket socket)
		{
			if (!ec)
			{
				std::make_shared<HttpSession>(std::move(socket), this)->run();
			}
			do_accept();
		});
}

// Function to handle incoming HTTP requests
std::string Webserver::handle_request(http::request<http::string_body>& req, http::response<http::string_body>& res) {
	using namespace std::chrono;

	auto start = system_clock::now();
	auto reqMethod = to_wstring(static_cast<std::string>(req.method_string()));
	auto reqPath = to_wstring(static_cast<std::string>(req.target()));

	ModStatics::LogOutput<LogLevel::Verbose>(
		L"Processing {} request {}",
		reqMethod,
		reqPath);

	json::object response_json;
	http::status statusCode = http::status::ok;

	try
	{
		for (auto& response : responses)
		{
			if (response->IsMatchingRequest(req)) {
				response_json = response->GetResponseJson(req, statusCode);
				break;
			}
		}
	}
	catch (std::exception& e)
	{
		response_json["error"] = std::format("Internal server error: {}", e.what());
		statusCode = http::status::internal_server_error;
	}

	if (req.target() == "/status") {
		response_json["message"] = "mods management server is running";
	}

	if (response_json.empty())
	{
		response_json["error"] = std::format("Unable to process {} request {}",
			std::string(req.method_string()),
			std::string(req.target()));
		statusCode = http::status::bad_request;
	}

	auto el = duration_cast<milliseconds>(system_clock::now() - start).count();
	ModStatics::LogOutput(L"{} {} \"{}\" {}ms", static_cast<int>(statusCode), reqMethod, reqPath, el);

	res.result(statusCode);
	return json::serialize(response_json);
}
