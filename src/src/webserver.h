// Workaround against multiple check definitions
#pragma push_macro("check")
#undef check
#include <boost/beast.hpp>
#pragma pop_macro("check")
#include <boost/asio.hpp>
#include <boost/thread.hpp>

namespace asio = boost::asio;
namespace beast = boost::beast;
namespace http = beast::http;

// Simple HTTP server with threading
class Webserver
{
	const char* ModName = nullptr;
	int Port = 5000;
	asio::io_context ioc;
	boost::thread serverThread;
	std::vector<class Route*> responses;

public:
	Webserver();
	~Webserver();

	// Get current instance of webserver
	static Webserver* Get();

	// Check if the server is still running
	bool isServerRunning();

private:
	// HTTP Server function
	void run_server(unsigned short port);

	// Function to handle incoming HTTP requests
	void handle_request(http::request<http::string_body> req, http::response<http::string_body>& res);

	void add_response(Route* response);
};
