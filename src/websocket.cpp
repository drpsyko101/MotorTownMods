#include "websocket.h"
#include "statics.h"
#include "webroute.h"
#include "statics.h"
#include "modsmanager.h"
#include "playermanager.h"
#include "eventmanager.h"
#include "serversettings.h"
#include "vehiclemanager.h"

#include <boost/beast/core.hpp>
#include <boost/beast/websocket.hpp>
#include <boost/asio/strand.hpp>
#include <algorithm>
#include <cstdlib>
#include <functional>
#include <iostream>
#include <memory>
#include <string>
#include <thread>
#include <vector>

namespace websocket = beast::websocket; // from <boost/beast/websocket.hpp>

Websocket* Websocket::instancePtr = nullptr;
std::mutex Websocket::mtx;

// Echoes back all received WebSocket messages
class session : public std::enable_shared_from_this<session>
{
	websocket::stream<beast::tcp_stream> ws_;
	beast::flat_buffer buffer_;
	std::string response_buffer_; // Buffer for outgoing messages
	std::string remote_address_; // To store client's IP and port
	Websocket* websocket_;

public:
	// Take ownership of the socket
	explicit
		session(tcp::socket&& socket, Websocket* websocket)
		: ws_(std::move(socket))
		, websocket_(websocket)
	{
		try
		{
			// Store the client's endpoint for logging
			remote_address_ = ws_.next_layer().socket().remote_endpoint().address().to_string() + ":"
				+ std::to_string(ws_.next_layer().socket().remote_endpoint().port());
		}
		catch (const std::exception&)
		{
			// This can happen if the connection is dropped immediately
			remote_address_ = "unknown";
		}
	}

	// Start the asynchronous operation
	void
		run()
	{
		// Set suggested timeout settings for the websocket
		ws_.set_option(
			websocket::stream_base::timeout::suggested(
				beast::role_type::server));

		// Set a decorator to change the Server of the handshake
		ws_.set_option(websocket::stream_base::decorator(
			[](websocket::response_type& res)
			{
				res.set(http::field::server,
					to_string(ModStatics::GetModName()) +
					" websocket");
			}));

		// Accept the websocket handshake
		ws_.async_accept(
			beast::bind_front_handler(
				&session::on_accept,
				shared_from_this()));
	}

	void
		on_accept(beast::error_code ec)
	{
		if (ec)
		{
			ModStatics::LogOutput<LogLevel::Error>(L"Failed to accept new websocket connection");
			return;
		}

		ModStatics::LogOutput(L"Accepted new websocket connection from {}", to_wstring(remote_address_));

		// Read a message
		do_read();
	}

	void
		do_read()
	{
		// Read a message into our buffer
		ws_.async_read(
			buffer_,
			beast::bind_front_handler(
				&session::on_read,
				shared_from_this()));
	}

	void
		on_read(
			beast::error_code ec,
			std::size_t bytes_transferred)
	{
		boost::ignore_unused(bytes_transferred);

		// This indicates that the session was closed
		if (ec == websocket::error::closed) 
		{
			ModStatics::LogOutput(L"Websocket connection closed by {}", to_wstring(remote_address_));
			return;
		}

		if (ec)
		{
			ModStatics::LogOutput<LogLevel::Error>(L"Failed to accept read websocket content");
			return;
		}

		const auto text = beast::buffers_to_string(buffer_.data());
		json::object res;
		
		try
		{
			const auto req = json::parse(text);
			if (!websocket_->handle_response(req, res))
			{
				res["status"] = "error";
				res["error"] = {
					{"code", 404},
					{"message", "Request not found"}
				};
			}
		}
		catch (const std::exception& e)
		{
			const auto errMsg = to_wstring(e.what());
			ModStatics::LogOutput<LogLevel::Error>(L"Failed to process request: {}", errMsg);
			res["status"] = "error";
			res["error"] = {
				{"code", 400},
				{"message", "Invalid JSON format"}
			};
		}

		// Echo the message
		ws_.text(ws_.got_text());
		ws_.async_write(
			net::buffer(json::serialize(res)),
			beast::bind_front_handler(
				&session::on_write,
				shared_from_this()));
	}

	void
		on_write(
			beast::error_code ec,
			std::size_t bytes_transferred)
	{
		boost::ignore_unused(bytes_transferred);

		if (ec)
		{
			ModStatics::LogOutput<LogLevel::Error>(L"Failed to accept read websocket content");
			return;
		}

		// Clear the buffer
		buffer_.consume(buffer_.size());

		// Do another read
		do_read();
	}
};

Websocket* Websocket::Get()
{
	if (instancePtr == nullptr)
	{
		std::lock_guard<std::mutex> lock(mtx);
		if (instancePtr == nullptr)
		{
			instancePtr = new Websocket();
		}
	}
	return instancePtr;
}

bool Websocket::handle_response(const json::value& req, json::object& res) const
{
	// Check for object type and action
	if (!req.is_object() || !req.as_object().contains("action")) return false;

	for (auto& response : responses)
	{
		if (response->IsMatchingRequest(req.as_object()))
		{
			res = response->GetResponseJson(req.as_object());
			return true;
		}
	}
	return false;
}

Websocket::Websocket()
	: ioc()
	, acceptor(ioc)
{
	unsigned short port = 5002;
	int threads = 1;

	if (const auto portEnv = getenv("MOD_WEBSOCKET_PORT"))
	{
		port = atoi(portEnv);
	}

	if (const auto threadsEnv = getenv("MOD_MANAGEMENT_WORKER"))
	{
		threads = atoi(threadsEnv);
	}

	responses.push_back(std::make_shared<ModsManager>());
	responses.push_back(std::make_shared<PlayerManager>());
	responses.push_back(std::make_shared<EventManager>());
	responses.push_back(std::make_shared<ServerSettings>());
	responses.push_back(std::make_shared<VehicleManager>());

	try {
		tcp::endpoint endpoint(tcp::v4(), port);
		acceptor.open(endpoint.protocol());
		acceptor.set_option(net::socket_base::reuse_address(true));
		acceptor.bind(endpoint);
		acceptor.listen(net::socket_base::max_listen_connections);
	}
	catch (const std::exception& e) {
		ModStatics::LogOutput<LogLevel::Error>(L"Failed to setup acceptor: {}", to_wstring(e.what()));
		return;
	}

	do_accept();

	ModStatics::LogOutput(L"Webhook server listening at {}", port);

	serverWorkers.reserve(threads);
	for (int i = 0; i < threads; i++)
	{
		auto worker = boost::make_shared<boost::thread>([this]() { ioc.run(); });
		serverWorkers.push_back(worker);
	}
}

Websocket::~Websocket()
{
}

void Websocket::do_accept()
{
	acceptor.async_accept(
		net::make_strand(ioc),
		[this](beast::error_code ec, tcp::socket socket)
		{
			if (!ec)
			{
				std::make_shared<session>(std::move(socket), this)->run();
			}
			do_accept();
		});
}
