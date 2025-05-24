--------  To Do:  --------------
-- Fix HTTP/0.9 issue
-- Look into respecting a "keep open" request
-- think about authentication
-- 405 response needs to add allowed methods header


-- Import Section
-- Declare everything that this module needs from outside
local dir = os.getenv("PWD") or io.popen("cd"):read()
package.cpath = package.cpath .. ";" .. dir .. "/ue4ss/Mods/shared/socket/core.dll"
local socket = require("socket")
local url = require("socket.url")

local string = string
local table = table

local pairs = pairs
local ipairs = ipairs
local tonumber = tonumber
local tostring = tostring
local date = os.date
local LogMsg = LogMsg

-- Cut off external access
_ENV = nil

---@enum (key) RequestMethod
local _method = {
    GET = "GET",
    POST = "POST",
    PUT = "PUT",
    DELETE = "DELETE"
}

---@enum (key) ConnectionState
local _state = {
    init = "init",
    header = "header",
    body = "body",
    close = "close"
}

---@enum MimeType
local _mimeType = {
    json = "application/json",
    plaintext = "text/plain"
}

---@alias ClientTable { id: integer, state: string, client: TCPSocketClient, rawHeaders: string[], headers: table<string,string>, method: RequestMethod, urlString: string, urlComponents?: table<string,string>, pathComponents: table<string,string>, queryComponents: table<string,string>, version: string, contentLength: number, content: string, state: ConnectionState }
---@alias RequestPathHandler fun(session: ClientTable)
---@alias RequestPathHandlerTable { path: string, method: RequestMethod, handler: RequestPathHandler }

local serverString = "MotorTownMods server 0.1.0"
local clients = {} ---@type TCPSocketClient[]
local sessions = {} ---@type table<TCPSocketClient, ClientTable>
local nextSessionID = 1
local g_server = nil ---@class TCPSocketServer
local handlers = {} ---@type RequestPathHandlerTable[]

---Find a handler index by path and method
---@param path string Request path
---@param method string One of GET, POST, PUT, DELETE
local function findHandlerIndex(path, method)
    for i, h in ipairs(handlers) do
        if path == h.path then
            if method == h.method then
                return i
            end
        end
    end

    return nil
end

---Find a handler by path and methods
---@param path string Request path
---@param method? RequestMethod
---@return table|nil
local function findHandler(path, method)
    for i, h in ipairs(handlers) do
        LogMsg("Checking " .. h.path .. "  " .. h.method, "DEBUG")

        local base = string.gsub(h.path, "%*", ".*") -- Turn asterisks into Lua wild patterns
        local pat = string.format("^%s$", base)      -- Add anchors to pattern
        if string.find(path, pat) == 1 then
            --if path == h.path then
            if method == nil or h.method == "*" or method == h.method then
                LogMsg("Match for" .. h.path, "DEBUG")
                return h
            end
        end
    end
    return nil
end

---Get a new connecting client
local function getNewClients()
    local client, err = g_server:accept()

    if client == nil then
        if err ~= "timeout" then
            LogMsg("Error from accept: " .. err, "ERROR")
        end
    else
        LogMsg("Accepted connection from client", "DEBUG")
        client:settimeout(1)
        table.insert(clients, client)

        local s = { id = nextSessionID, state = "init", client = client }
        nextSessionID = nextSessionID + 1
        sessions[client] = s

        -- socket.sleep(0.01)
    end
end

---Build the headers for a normal response
---Content is optional and may be nil. If not nil, content type must be provided (ex: "application/json")
---Assumes that the data is JSON
---@param content string? Content of the response
---@param contentType string? Content mime type
local function buildHeaders_OK(self, content, contentType)
    local h = {}

    local function add(name, value)
        table.insert(h, string.format("%s: %s", name, value))
    end

    table.insert(h, "HTTP/1.1 200 OK")

    add("Server", serverString)
    add("Date", date("!%a, %d %b %Y %H:%M:%S GMT"))
    add("Connection", "close")

    if content then
        add("Content-Length", #content)
        add("Content-type", contentType)
    end

    local header = table.concat(h, "\n") .. "\n\n"
    LogMsg("Adding header: " .. header, "DEBUG")
    return header
end

---Build the headers for an error response
---@param statusCode number HTTP status code
---@param statusText string HTTP status message
local function buildHeaders_Error(self, statusCode, statusText)
    local h = {}

    local function add(name, value)
        table.insert(h, string.format("%s: %s", name, value))
    end

    table.insert(h, string.format("HTTP/1.1 %d %s", statusCode, statusText))

    add("Server", serverString)
    add("Date", date("!%a, %d %b %Y %H:%M:%S GMT"))
    add("Connection", "close")

    return table.concat(h, "\n") .. "\n\n"
end

---Safely mark a session for removal
---@param s ClientTable
local function markSessionForRemoval(s)
    LogMsg("Marking client " .. s.id .. " for removal", "DEBUG")
    s.state = "close"
end

---Send a response to the clients
---@param s ClientTable Session client
---@param header string Response headers
---@param rcontent string? Response body
local function sendResponse(s, header, rcontent)
    LogMsg("Sending the response", "DEBUG")
    -- socket.sleep(0.1)

    local a, b, elast = s.client:send(header)
    if a == nil then
        LogMsg("Error: " .. b .. "  last byte sent: " .. elast, "ERROR")
    else
        LogMsg("Last byte sent: " .. a .. " header size: " .. #header, "DEBUG")
    end

    if rcontent then
        -- socket.sleep(0.1)
        local a, b, elast = s.client:send(rcontent)
        if a == nil then
            LogMsg("Error: " .. b .. "  last byte sent: " .. elast, "ERROR")
        else
            LogMsg("Last byte sent: " .. a .. " content size: " .. #rcontent, "DEBUG")
        end
    end
    -- socket.sleep(0.1)
    markSessionForRemoval(s)
end

---Send 200 OK responses
---@param s ClientTable
---@param content string
---@param contentType MimeType
local function sendOKResponse(s, content, contentType)
    local header = buildHeaders_OK(s, content, contentType)
    sendResponse(s, header, content)
end

local function sendErrorResponse(s, statusCode, statusText)
    local header = buildHeaders_Error(s, statusCode, statusText)
    sendResponse(s, header)
end

---Parse the raw headers into a nice name/value dictionary
---@param s ClientTable Session client
local function parseHeaders(s)
    --print( string.format( "(%d) Request is '%s'", s.id, s.method ) )

    s.headers = {}

    -- TODO: handle a continued header line!
    for _, line in ipairs(s.rawHeaders) do
        local name, value = string.match(line, "(%S+)%s*:%s*(.+)%s*")
        if name ~= nil then
            --print( string.format( "'%s' = '%s'", name, value ) )
            name = string.lower(name) -- convert to lowercase for simplified access
            s.headers[name] = value
        else
            LogMsg("Malformed header line:\n" .. line, "ERROR")
            return -1
        end
    end

    return 0 -- success
end

local function processHeaders(s)
    s.contentLength = 0

    local len = s.headers["content-length"]
    if len ~= nil then
        s.contentLength = tonumber(len)
    end
end

local function dumpSession(s)
    LogMsg("==============================", "DEBUG")
    LogMsg("URL string:" .. s.urlString, "DEBUG")
    LogMsg(string.format("Method: %s", s.method), "DEBUG")
    LogMsg(string.format("Version: %s", s.version), "DEBUG")

    LogMsg("Headers:", "DEBUG")
    for name, value in pairs(s.headers) do
        LogMsg(string.format("    '%s' = '%s'", name, value), "DEBUG")
    end

    LogMsg("URL components:", "DEBUG")
    for k, v in pairs(s.urlComponents) do
        LogMsg(string.format("     %s:  %s", k, tostring(v)), "DEBUG")
    end

    if s.queryComponents ~= nil then
        LogMsg("URL Query components", "DEBUG")
        for k, v in pairs(s.queryComponents) do
            LogMsg(string.format("     %s =  %s", k, tostring(v)), "DEBUG")
        end
    end

    LogMsg("URL Path: " .. s.urlComponents.path, "DEBUG")
    LogMsg("URL Params: " .. (s.urlComponents.params or ""), "DEBUG")
    LogMsg("URL url: " .. (s.urlComponents.url or ""), "DEBUG")

    LogMsg("URL path components:", "DEBUG")
    for k, v in pairs(s.pathComponents) do
        LogMsg(string.format("     %s:  %s", k, tostring(v)), "DEBUG")
    end

    LogMsg(string.format("Content Length: %d", s.contentLength), "DEBUG")
    LogMsg(string.format("Content: %s", s.content), "DEBUG")
    LogMsg("==============================", "DEBUG")
end


-- This is called when we have a complete request ready to be processed.
local function processSession(s)
    dumpSession(s)

    local h = findHandler(s.urlComponents.path, s.method)
    if h then
        --print( ">>>>>>>>>>  Handler is" .. h )
        h.handler(s)
    else
        -- No matching path and method. How about just the path?
        local h = findHandler(s.urlComponents.path, nil)
        if h then
            -- This is a valid path, but not for the method.
            sendErrorResponse(s, 405, "Method Not Allowed")
            -- TODO: need to build a header with the allowed methods!
        else
            sendErrorResponse(s, 404, "Not Found")
        end
    end

    -- socket.sleep(0.01)
    --sendErrorResponse( s, "404", "Not Found" )

    --local rcontent = "Howdy pardners"
end

---Turns a query string into a table of name/value pairs
local function decodeQuery(s)
    local cgi = {}
    for name, value in string.gmatch(s, "([^&=]+)=([^&=]+)") do
        name = url.unescape(name)
        value = url.unescape(value)
        cgi[name] = value
    end
    return cgi
end

---Handle client request data
---@param client TCPSocketClient
local function handleClient(client)
    local s = sessions[client]

    local data, err, partial

    if s.state == "init" or s.state == "header" then
        data, err, partial = client:receive("*l")
    elseif s.state == "body" then
        data, err, partial = client:receive(s.contentLength)
    end

    if data then
        if s.state == "init" then
            LogMsg(string.format("(%d) INIT: '%s'", s.id, data), "DEBUG")
            -- socket.sleep(0.01)
            s.rawHeaders = {}
            local method, urlString, ver = string.match(data, "(%S+)%s+(%S+)%s+(%S+)")
            if method ~= nil then
                s.method = method
                s.urlString = urlString

                -- Break down the url string
                s.urlComponents = url.parse(urlString)

                s.pathComponents = url.parse_path(s.urlComponents.path)

                LogMsg("Query Components " .. (s.urlComponents.query or ""), "DEBUG")
                if s.urlComponents.query ~= nil then
                    s.queryComponents = decodeQuery(s.urlComponents.query)
                end

                s.version = ver

                s.state = "header"
            else
                LogMsg("Malformed initial line", "ERROR")
                sendErrorResponse(s, 400, "Bad Request")
            end
        elseif s.state == "header" then
            LogMsg(string.format("(%d)  HDR: %s", s.id, data), "DEBUG")
            if data ~= "" then
                table.insert(s.rawHeaders, data)
            else
                LogMsg(string.format("(%d)  End Headers", s.id), "DEBUG")
                local rc = parseHeaders(s)
                if rc ~= 0 then
                    sendErrorResponse(s, 400, "Bad Request")
                    return
                end

                processHeaders(s)

                if s.contentLength == 0 then
                    LogMsg("Content length = 0, not waiting for content", "DEBUG")
                    -- Processing the session will result in it being closed
                    processSession(s)
                else
                    LogMsg("Waiting for content", "DEBUG")
                    s.state = "body"
                end
            end
        else
            --print( string.format( "(%d) BODY: %s", s.id, data ) )
            s.content = data
            processSession(s)
        end
    else
        if err == "closed" then
            LogMsg("Client closed the connection: ", "DEBUG")
            markSessionForRemoval(s)
            --print( "Size of client list is " .. #clients )
        elseif err == "timeout" then
            LogMsg("Receive timeout. Partial data: " .. partial, "ERROR")
            markSessionForRemoval(s)
        else
            LogMsg("Receive error: " .. err, "ERROR")
            markSessionForRemoval(s)
        end
    end
end

---Wait the given amount of time for some data to process. If data received, it will be processed and this
---method will return. If no data, it will timeout and return. The caller should not know or care which happened.
---
---Note that if there is data to process this method may return sooner or later than the timeout time.
---@param timeout number Timout in seconds
local function process(timeout)
    local rclients, _, err = socket.select(clients, nil, timeout) ---@cast rclients TCPSocketClient[]
    --print( #rclients, err )
    if err ~= nil then
        -- Either no data (timeout) or an error
        if err ~= "timeout" then
            LogMsg("Select error: " .. err, "ERROR")
        end
    else
        -- Some clients have data for us
        for _, client in ipairs(rclients) do
            if client == g_server then
                -- special case, accept new connection
                getNewClients()
            else
                handleClient(client)
            end
        end
    end

    -- Cleanup phase: remove closed sessions
    local i = #clients
    while i >= 1 do
        local client_to_check = clients[i]
        local s = sessions[client_to_check]
        if s and s.state == "close" then
            LogMsg("Cleaning up client " .. s.id, "DEBUG")
            client_to_check:close()
            table.remove(clients, i)
            sessions[client_to_check] = nil
        end
        i = i - 1
    end
end

---Register a new handler for the specified path and method
---@param path string pattern to match (no wildcards at the moment) Ex: "/api/status"
---@param method RequestMethod request type (e.g. GET, POST). If nil the handler will be called for all types.
---@param handler RequestPathHandler
local function registerHandler(path, method, handler)
    local h = { path = path, method = method, handler = handler }
    -- Already registered?
    local i = findHandlerIndex(path, method)
    if i == nil then
        -- add
        table.insert(handlers, h)
    else
        -- replace
        handlers[i] = h
    end
end

---Initialize the web server
---@param host string Host to bind to
---@param port number Port to bind to
local function init(host, port)
    LogMsg("Web Server binding to host '" .. host .. "' on port " .. port .. "...", "DEBUG")
    g_server = socket.bind(host, port)
    if g_server == nil then
        LogMsg("Unable to bind to port!", "ERROR");
        return
    end

    -- g_server:settimeout(0.05)

    -- Add the server socket to the client arrays so we will wait on it in select()
    table.insert(clients, g_server)
end

local function run(host, port)
    init(host, port)

    while 1 do
        process(5.0)
    end
end

return {
    run = run,
    registerHandler = registerHandler,
    init = init,
    process = process,
    dumpSession = dumpSession,

    decodeQuery = decodeQuery,

    sendOKResponse = sendOKResponse,
    sendErrorResponse = sendErrorResponse
}
