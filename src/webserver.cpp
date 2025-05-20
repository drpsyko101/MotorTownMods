#pragma once

#include "webserver.h"
#include <DynamicOutput/DynamicOutput.hpp>
#include <Unreal/UObjectGlobals.hpp>
#include "statics.h"
#include "playermanager.h"
#include "eventmanager.h"
#include "serversettings.h"

// Workaround against multiple check definitions
#pragma push_macro("check")
#undef check
#include <boost/beast.hpp>
#include <boost/json.hpp>
#pragma pop_macro("check")

using namespace RC;
namespace json = boost::json;
using tcp = asio::ip::tcp;

Webserver* _localServer = nullptr;

Webserver::Webserver() {
	ModName = ModStatics::GetModName();
	if (const char* val = getenv("MOD_PORT"))
	{
		Port = atoi(val);
	}

	responses.push_back(std::make_shared<PlayerManager>());
	responses.push_back(std::make_shared<EventManager>());
	responses.push_back(std::make_shared<ServerSettings>());

	serverThread = boost::thread(&Webserver::run_server, this, Port);
	serverThread.detach();

	Output::send<LogLevel::Verbose>(STR("[{}] API server listening at {}\n"), ModName, Port);
}

Webserver::~Webserver() {
	serverThread.interrupt();

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
	return serverThread.joinable();
}

// HTTP Server function
void Webserver::run_server(unsigned short port) {
	try
	{
		tcp::acceptor acceptor(ioc, tcp::endpoint(tcp::v4(), port));

		while (true) {
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
		Output::send<LogLevel::Error>(
			STR("[{}] Unexpected server failure: {}\n"),
			ModName,
			to_wstring(e.what()));
		return;
	}
}

// Function to handle incoming HTTP requests
std::string Webserver::handle_request(http::request<http::string_body> req, http::response<http::string_body>& res) {
	Output::send<LogLevel::Verbose>(
		STR("[{}] Processing {} request {}\n"),
		ModName,
		to_wstring(req.method_string()),
		to_wstring(req.target()));


	json::object response_json;

	for (auto response : responses)
	{
		if (response->IsMatchingRequest(req)) {
			response_json = response->GetResponseJson(req);
			res.result(http::status::ok);
			return json::serialize(response_json);
		}
	}

	if (req.target() == "/status") {
		response_json["message"] = "Server is running";
		res.result(http::status::ok);
		return json::serialize(response_json);
	}

	response_json["error"] = std::format("Unable to process {} request {}",
		std::string(req.method_string()),
		std::string(req.target()));
	res.result(http::status::bad_request);
	return json::serialize(response_json);
}

