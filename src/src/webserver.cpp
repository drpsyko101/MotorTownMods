#include "webserver.h"
#include <DynamicOutput/DynamicOutput.hpp>
#include <Unreal/UObjectGlobals.hpp>
#include "statics.h"
#include "playermanager.h"

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
	if (const char* val = getenv("MOD_PORT")) {
		Port = static_cast<int>(*val);
	}

	responses.push_back(new PlayerManager());

	serverThread = boost::thread(&Webserver::run_server, this, Port);
	serverThread.detach();

	Output::send<LogLevel::Verbose>(STR("{} API server listening at {}\n"), *ModName, Port);
}

Webserver::~Webserver() {
	serverThread.interrupt();

	free(_localServer);
	_localServer = NULL;

	for (int i = 0; i < responses.size(); i++)
	{
		free(responses[i]);
	}
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
	tcp::acceptor acceptor(ioc, tcp::endpoint(tcp::v4(), port));

	while (true) {
		tcp::socket socket(ioc);
		acceptor.accept(socket);

		beast::flat_buffer buffer;
		http::request<http::string_body> req;
		http::read(socket, buffer, req);

		http::response<http::string_body> res;
		handle_request(req, res);

		http::write(socket, res);
	}
}

// Function to handle incoming HTTP requests
void Webserver::handle_request(http::request<http::string_body> req, http::response<http::string_body>& res) {
	std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
	Output::send<LogLevel::Verbose>(
		STR("Processing {} request {}\n"), 
		converter.from_bytes(req.method_string().data()),
		converter.from_bytes(req.target().data()));

	json::object response_json;

	for (int i = 0; i < responses.size(); i++)
	{
		if (responses[i]->is_request_match(req)) {
			response_json = responses[i]->get_response(req);
		}
	}

	if (response_json.empty()) {
		response_json["error"] = std::format("Unknown endpoint {}", std::string(req.target()));
	}

	res.result(http::status::ok);
	res.set(http::field::content_type, "application/json");
	res.body() = json::serialize(response_json);
	res.prepare_payload();
}

void Webserver::add_response(Route* response)
{
	responses.push_back(response);
}
