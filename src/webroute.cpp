#include "webroute.h"

#include <boost/asio.hpp>
#include <boost/beast.hpp>
#include <boost/url.hpp>
#include <DynamicOutput/DynamicOutput.hpp>
#include <Helpers/String.hpp>

#include "statics.h"

namespace asio = boost::asio;
namespace beast = boost::beast;
namespace http = beast::http;
namespace urls = boost::urls;
using namespace RC;
using tcp = asio::ip::tcp;

Route::Route()
{
}

bool Route::IsMatchingRequest(const http::request<http::string_body>& req) const
{
	return false;
}

bool Route::IsMatchingRequest(const json::object& req) const
{
	return false;
}

json::object Route::GetResponseJson(const json::object& req)
{
	return json::object();
}

static void OnReqFail(const std::string message)
{
	ModStatics::LogOutput<LogLevel::Error>(L"Failed to send webhook request: {}", to_wstring(message));
}

void Route::SendWebhookEvent(const json::object payload)
{
	const std::string url = ModStatics::GetWebhookUrl();

	if (url.empty()) return;

	try {
		auto uriRaw = boost::urls::parse_uri(url);
		const urls::url_view uri = uriRaw.value();
		asio::io_context ioc;
		tcp::resolver resolver(ioc);
		beast::tcp_stream stream(ioc);

		const std::string host = uri.host();
		const std::string port = uri.port().empty() ? "80" : uri.port();
		const std::string target = uri.path();
		const std::string schema = uri.scheme().empty() ? "http" : uri.scheme();
		ModStatics::LogOutput(L"Sending payload to {}:{} {}",
			to_wstring(host),
			to_wstring(port),
			to_wstring(target));

		const auto result = resolver.resolve(host, port);
		stream.connect(result);

		http::request<http::string_body> req{ http::verb::post, uri.path(), 11 };
		req.set(http::field::host, uri.host());
		req.set(http::field::content_type, "application/json");
		req.prepare_payload();

		const std::string body = json::serialize(payload);
		ModStatics::LogOutput(L"Sending payload {}", to_wstring(body));

		req.body() = body;

		http::async_write(
			stream,
			req,
			[uri](boost::beast::error_code e, std::size_t bytesWritten) {
				if (e) return OnReqFail(e.what());

				ModStatics::LogOutput(L"Successfully sent webhook {}", to_wstring(uri.path()));
			}
		);
	}
	catch (std::exception& e) {
		OnReqFail(e.what());
	}
}
