--------  To Do:  --------------
-- Look into respecting a "keep open" request
-- 405 response needs to add allowed methods header
-- Cover more cases that may results in timeout


-- Import Section
-- Declare everything that this module needs from outside
local dir = os.getenv("PWD") or io.popen("cd"):read()
package.cpath = package.cpath .. ";" .. dir .. "/ue4ss/Mods/shared/?/core.dll"
package.cpath = package.cpath .. ";" .. dir .. "/ue4ss/Mods/shared/?.dll"
local socket = require("socket")
local mime = require("mime")
local url = require("socket.url")
local statics = require("Statics")
local json = require("JsonParser")
local auth = os.getenv("MOD_SERVER_PASSWORD")
local bcrypt = nil
if auth then
    local status, err = pcall(function()
        LogMsg("Attempting to load bcrypt...", "DEBUG")
        bcrypt = require("bcrypt")
        LogMsg("Successfully loaded bcrypt", "DEBUG")
    end)
    if not status then
        LogMsg("Failed to load bcrypt, will use base64 as fallback: " .. err, "ERROR")
    end
end

local string = string
local table = table

local pairs = pairs
local ipairs = ipairs
local tonumber = tonumber
local tostring = tostring
local date = os.date
local LogMsg = LogMsg
local setmetatable = setmetatable
local pcall = pcall
local min = math.min
local time = function ()
    return socket.gettime() * 1000
end

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

---@class ClientTable
---@field id integer Client connection ID. No two clients should have the same ID unless connections are kept open
---@field client TCPSocketClient
---@field rawHeaders string[] Raw request header pairs in a case-sensitive table
---@field headers table<string,string> Request headers in lowercase keys
---@field method RequestMethod
---@field urlString string Full URL request path
---@field urlComponents table<string,string>?
---@field pathComponents string[] URL request paths separated by `/`
---@field queryComponents table<string,string>
---@field version string HTTP version used in the request
---@field contentLength number? Returns a valid number if content is not empty
---@field content string? Request body
---@field state ConnectionState
---@field connTime number
local ClientTable = {}
ClientTable.__index = ClientTable

---Create a new client
---@param newId number
---@param client TCPSocketClient
---@return ClientTable
function ClientTable.new(newId, client)
    local obj = setmetatable({}, ClientTable)
    obj.id = newId
    obj.client = client
    obj.state = "init"
    obj.connTime = time()
    return obj
end

---@enum (key) ResponseStatus
local _resCode = {
    [200] = "200 OK",
    [201] = "201 Created",
    [204] = "204 No Content",
    [400] = "400 Bad Request",
    [401] = "401 Unauthorized",
    [403] = "403 Forbidden",
    [404] = "404 Not Found",
    [405] = "405 Method Not Allowed",
    [500] = "500 Internal Server Error",
    [503] = "503 Service Unavailable"
}

---Request handler for the specified path
---@alias RequestPathHandler fun(session: ClientTable): resContent: string?, resType: MimeType?, resCode: ResponseStatus?

---@class RequestPathHandlerTable
---@field path string
---@field method RequestMethod
---@field handler RequestPathHandler
---@field authenticate boolean
local RequestPathHandlerTable = {}
RequestPathHandlerTable.__index = RequestPathHandlerTable

---Create a new request handler
---@param path string
---@param method RequestMethod
---@param handler RequestPathHandler
---@param authenticate boolean?
---@return RequestPathHandlerTable
function RequestPathHandlerTable.new(path, method, handler, authenticate)
    local obj = setmetatable({}, RequestPathHandlerTable)
    obj.path = path
    obj.method = method
    obj.handler = handler
    if authenticate == nil then
        obj.authenticate = true
    else
        obj.authenticate = authenticate
    end
    return obj
end

local serverString = statics.ModName .. " server " .. statics.ModVersion
local clients = {} ---@type TCPSocketClient[]
local sessions = {} ---@type table<TCPSocketClient, ClientTable>
local nextSessionID = 1
local g_server = nil ---@class TCPSocketServer
local handlers = {} ---@type RequestPathHandlerTable[]

---Find a handler index by path and method
---@param path string Request path
---@param method RequestMethod Request method i.e. GET, POST, etc.
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
---@return RequestPathHandlerTable|nil
local function findHandler(path, method)
    for i, h in ipairs(handlers) do
        LogMsg("Checking " .. h.path .. "  " .. h.method, "DEBUG")

        local base = string.gsub(h.path, "%*", ".*") -- Turn asterisks into Lua wild patterns
        local pat = string.format("^%s$", base)      -- Add anchors to pattern
        if string.find(path, pat) == 1 then
            --if path == h.path then
            if method == nil or h.method == "*" or method == h.method then
                LogMsg("Match for " .. h.path, "DEBUG")
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

        local s = ClientTable.new(nextSessionID, client)
        nextSessionID = nextSessionID + 1
        sessions[client] = s
    end
end

---Build the headers for a normal response
---Content is optional and may be `nil`. If not `nil`, content type must be provided (ex: `application/json`)
---Assumes that the supplied data is JSON format by default
---@param content string? Content of the response
---@param contentType MimeType? Content mime type
---@param resCode ResponseStatus? Response code, defaults to `200 OK`
local function buildHeaders(content, contentType, resCode)
    contentType = contentType or _mimeType.json
    local code = _resCode[resCode or 200]
    local h = {}

    local function add(name, value)
        table.insert(h, string.format("%s: %s", name, value))
    end

    table.insert(h, "HTTP/1.1 " .. code)

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

---Safely mark a session for removal
---@param client ClientTable
local function markSessionForRemoval(client)
    LogMsg("Marking client " .. client.id .. " for removal", "DEBUG")
    client.state = "close"
end

---Helper function to ensure all data is sent
---@param client TCPSocketClient
---@param data string
local function send_all(client, data)
    local total_sent = 0

    local len = #data
    while total_sent < len do
        -- 'send' partial send method doesn't work, so we do our own string sub
        -- 'send' method will send malformed data if exceeds 40 bytes
        local endByte = min(total_sent + 40, len)
        local partial = string.sub(data, total_sent + 1, endByte)
        local sent, err, partial_sent_index = client:send(partial)
        if sent == nil then
            -- Handle error (e.g., connection closed, timeout)
            LogMsg("ERROR: Failed to send data: " .. (err or "unknown error"), "ERROR")
            return nil, err -- Return nil and error message
        end
        total_sent = total_sent + sent
        -- If 'sent' is less than the remaining 'data', client:send might have returned only part
        -- In LuaSocket, if 'send' succeeds but sends less than requested, 'sent' will be the actual amount.
        -- The loop naturally handles this by advancing total_sent.
    end
    return total_sent -- Return the total bytes sent on success
end

---Send a response to the clients
---@param client ClientTable
---@param content? string Response body
---@param contentType MimeType? Content mime type. defaults to `application/json`
---@param resCode ResponseStatus? Response code. Defaults to `200 OK`
local function sendResponse(client, content, contentType, resCode)
    LogMsg("Sending the response", "DEBUG")
    local header = buildHeaders(content, contentType, resCode)

    local sent = send_all(client.client, header)
    LogMsg("Last byte sent: " .. sent .. " header size: " .. #header, "DEBUG")

    if content then
        local contentSent = send_all(client.client, content)
        LogMsg("Last byte sent: " .. contentSent .. " content size: " .. #content, "DEBUG")
    end
    LogMsg(string.format("%d %s \"%s\" %.1fms", resCode or 200, client.method, client.urlString, time() - client.connTime))
    markSessionForRemoval(client)
end

---Parse the raw headers into a nice name/value dictionary
---@param client ClientTable
local function parseHeaders(client)
    client.headers = {}

    -- TODO: handle a continued header line!
    for _, line in ipairs(client.rawHeaders) do
        local name, value = string.match(line, "(%S+)%s*:%s*(.+)%s*")
        if name ~= nil then
            name = string.lower(name) -- convert to lowercase for simplified access
            client.headers[name] = value
        else
            LogMsg("Malformed header line:\n" .. line, "ERROR")
            return -1
        end
    end

    return 0 -- success
end

---Process request header content
---@param client ClientTable
local function processHeaders(client)
    client.contentLength = 0

    local len = client.headers["content-length"]
    if len ~= nil then
        client.contentLength = tonumber(len)
    end
end

---Authenticate header if applicable
---@param client ClientTable
local function authenticateSession(client)
    -- If no password is set, don't authenticate
    if not auth then
        return true
    end

    local headerAuth = client.headers["authorization"] or nil
    if headerAuth then
        local basicAuth = string.match(headerAuth, "Basic (.+)")
        if bcrypt then
            if bcrypt.verify(auth, basicAuth) then
                return true
            end
        else
            -- Fallback to base64 encoding
            return basicAuth == mime.b64(auth)
        end
    end

    LogMsg("Unauthenticated session " .. client.id, "DEBUG")
    return false
end

---Dump headers for debugging
---@param client ClientTable
local function dumpSession(client)
    LogMsg("==============================", "DEBUG")
    LogMsg("URL string:" .. client.urlString, "DEBUG")
    LogMsg(string.format("Method: %s", client.method), "DEBUG")
    LogMsg(string.format("Version: %s", client.version), "DEBUG")

    LogMsg("Headers:", "DEBUG")
    for name, value in pairs(client.headers) do
        LogMsg(string.format("    '%s' = '%s'", name, value), "DEBUG")
    end

    LogMsg("URL components:", "DEBUG")
    for k, v in pairs(client.urlComponents) do
        LogMsg(string.format("     %s:  %s", k, tostring(v)), "DEBUG")
    end

    if client.queryComponents ~= nil then
        LogMsg("URL Query components", "DEBUG")
        for k, v in pairs(client.queryComponents) do
            LogMsg(string.format("     %s =  %s", k, tostring(v)), "DEBUG")
        end
    end

    LogMsg("URL Path: " .. client.urlComponents.path, "DEBUG")
    LogMsg("URL Params: " .. (client.urlComponents.params or ""), "DEBUG")
    LogMsg("URL url: " .. (client.urlComponents.url or ""), "DEBUG")

    LogMsg("URL path components:", "DEBUG")
    for k, v in pairs(client.pathComponents) do
        LogMsg(string.format("     %s:  %s", k, tostring(v)), "DEBUG")
    end

    LogMsg(string.format("Content Length: %d", client.contentLength), "DEBUG")
    LogMsg(string.format("Content: %s", client.content), "DEBUG")
    LogMsg("==============================", "DEBUG")
end

---This is called when we have a complete request ready to be processed.
---@param client ClientTable
local function processSession(client)
    dumpSession(client)

    local h = findHandler(client.urlComponents.path, client.method)
    if h then
        if h.authenticate and not authenticateSession(client) then
            sendResponse(client, nil, nil, 401)
            return
        end

        local status, content, mime, code = pcall(h.handler, client)
        -- Check if the handler returned any valid response
        if status then
            sendResponse(client, content, mime, code)
        else
            if not pcall(function()
                    local errMsg = content or "Unknown error"
                    LogMsg("Handler error: " .. content, "ERROR")
                    -- TODO: Fix perser failed to escape certain characters
                    local err = json.stringify {
                        error = errMsg
                    }
                    sendResponse(client, err, nil, 500)
                end) then
                sendResponse(client, '{"error":"Internal server error"}', nil, 500)
            end
        end
    else
        -- No matching path and method. How about just the path?
        local h = findHandler(client.urlComponents.path, nil)
        if h then
            -- This is a valid path, but not for the method.
            sendResponse(client, nil, nil, 405)
            -- TODO: need to build a header with the allowed methods!
        else
            sendResponse(client, nil, nil, 404)
        end
    end
end

---Turns a query string into a table of name/value pairs
---@param path string
local function decodeQuery(path)
    local cgi = {}
    for name, value in string.gmatch(path, "([^&=]+)=([^&=]+)") do
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
                sendResponse(s, nil, nil, 400)
            end
        elseif s.state == "header" then
            LogMsg(string.format("(%d)  HDR: %s", s.id, data), "DEBUG")
            if data ~= "" then
                table.insert(s.rawHeaders, data)
            else
                LogMsg(string.format("(%d)  End Headers", s.id), "DEBUG")
                local rc = parseHeaders(s)
                if rc ~= 0 then
                    sendResponse(s, nil, nil, 400)
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
            s.content = data
            processSession(s)
        end
    else
        if err == "closed" then
            LogMsg("Client closed the connection: ", "DEBUG")
            markSessionForRemoval(s)
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
    local rclients, _, err = socket.select(clients, nil, timeout)
    ---@cast rclients TCPSocketClient[]
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
---@param path string pattern to match (e.g. `/api/status`)
---@param method RequestMethod request type (e.g. `GET`, `POST`)
---@param handler RequestPathHandler request handler function
---@param authenticate boolean? Should the handler be authenticated. Defaults to true
local function registerHandler(path, method, handler, authenticate)
    local h = RequestPathHandlerTable.new(path, method, handler, authenticate)
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
    g_server = socket.bind(host, port)
    if g_server == nil then
        LogMsg("Unable to bind to port " .. port, "ERROR");
        return
    end

    local bindAddr, bindPort = g_server:getsockname()
    LogMsg("Webserver listening to host " .. (bindAddr or host) .. " on port " .. (bindPort or port) .. "...")

    g_server:settimeout(0.05)

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
}
