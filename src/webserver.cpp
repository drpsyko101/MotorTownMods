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

// Workaround against multiple check definitions
#pragma push_macro("check")
#undef check
#include <boost/beast.hpp>
#include <boost/json.hpp>
#pragma pop_macro("check")

using namespace RC;
using namespace RC::Unreal;
namespace json = boost::json;
using tcp = asio::ip::tcp;

Webserver* _localServer = nullptr;

Webserver::Webserver() {
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
	for (int i = 0; i < numWorker; i++)
	{
		auto worker = boost::shared_ptr<boost::thread>(new boost::thread(&Webserver::run_server, this, Port));
		serverWorkers.push_back(worker);

		worker->detach();
	}

	ModStatics::LogOutput(L"API server listening at {}", Port);
}

Webserver::~Webserver() {
	for (auto& worker : serverWorkers)
	{
		worker->interrupt();
	}

	free(_localServer);
	_localServer = NULL;
}

Webserver* Webserver::Get() {
	if (_localServer == nullptr) {
		_localServer = new Webserver();
	}
	return _localServer;
}

bool Webserver::isServerRunning()
{
	if (serverWorkers.size() > 0)
	{
		return serverWorkers[0]->joinable();
	}
	return false;
}

// HTTP Server function
void Webserver::run_server(unsigned short port) {
	try
	{
		tcp::acceptor acceptor(ioc, tcp::endpoint(tcp::v4(), port));

		while (true)
		{

			tcp::socket socket(ioc);
			acceptor.accept(socket);

			beast::flat_buffer buffer;
			http::request<http::string_body> req;
			http::read(socket, buffer, req);

			http::response<http::string_body> res;
			res.body() = handle_request(req, res);

			res.set(http::field::content_type, "application/json");
			res.prepare_payload();

			http::write(socket, res);
		}
	}
	catch (const std::exception& e)
	{
		ModStatics::LogOutput<LogLevel::Error>(L"Unexpected server failure: {}", to_wstring(e.what()));
		return;
	}
}

// Function to handle incoming HTTP requests
std::string Webserver::handle_request(http::request<http::string_body> req, http::response<http::string_body>& res) {
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
