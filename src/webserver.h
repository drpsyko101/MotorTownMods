// Workaround against multiple check definitions
#pragma push_macro("check")
#undef check
#include <boost/beast.hpp>
#pragma pop_macro("check")
#include <boost/asio.hpp>
#include <boost/thread.hpp>
#include <list>
#include <memory>
#include <vector>

namespace asio = boost::asio;
namespace beast = boost::beast;
namespace http = beast::http;
using tcp = asio::ip::tcp;

class Route;

// Simple HTTP server with threading
class Webserver
{
	int Port = 5000;
	asio::io_context ioc;
	tcp::acceptor acceptor;
	std::vector<boost::shared_ptr<boost::thread>> serverWorkers;
	std::list<std::shared_ptr<Route>> responses;

	// Static pointer to the helper instance
	static Webserver* instancePtr;

	// Mutex to ensure thread safety
	static std::mutex mtx;

public:

	// Get current instance of webserver
	static Webserver* Get();

	// Check if the server is still running
	bool isServerRunning();

	// Function to handle incoming HTTP requests (made public to be accessible by session)
	std::string handle_request(http::request<http::string_body>& req, http::response<http::string_body>& res);

private:
	Webserver();
	~Webserver();

	// Function to asynchronously accept new connections
	void do_accept();
};
