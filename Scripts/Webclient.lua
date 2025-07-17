local dir = os.getenv("PWD") or io.popen("cd"):read()
package.cpath = package.cpath .. ";" .. dir .. "/ue4ss/Mods/shared/?/core.dll"
package.cpath = package.cpath .. ";" .. dir .. "/ue4ss/Mods/shared/?.dll"

local json = require("JsonParser")
local statics = require("Statics")
local server = RequireSafe("Webserver")
local socket = RequireSafe("socket")
local http = RequireSafe("socket.http")
local https = RequireSafe("ssl.https")
local ltn12 = RequireSafe("ltn12")
local webhookUrl = os.getenv("MOD_WEBHOOK_URL")
local method = os.getenv("MOD_WEBHOOK_METHOD") or "POST"
local extraHeaders = json.parse(os.getenv("MOD_WEBHOOK_EXTRA_HEADERS") or "{}") or {}

---Send a request to the specified URL
---@param url string
---@param content string?
local function __createWebhookRequest(url, content)
    if url then
        if socket and http and ltn12 then
            ---Function start time
            local time = socket.gettime() * 1000
            local bheaders = {
                ["content-type"] = "application/json",
                ["content-length"] = #content,
                ["user-agent"] = statics.ModName .. " client " .. statics.ModVersion
            }
            local res = {}
            local resState = nil ---@type string|number|nil
            local resCode = 0 ---@type string|number
            local resHeaders = {}
            local resSecure = {}

            -- Merge additional headers i.e. basic/bearer authentication
            if type(extraHeaders) == "table" then
                MergeTable(bheaders, extraHeaders)
            end

            LogOutput("DEBUG", "Sending POST request to %s with payload size: %i", url, #content)
            if string.match(url, "^https:") then
                if https == nil then
                    error("Unable to send HTTPS request: Failed to load luasec module")
                end

                resState, resCode, resHeaders, resSecure = https.request {
                    url = url,
                    method = method,
                    headers = bheaders,
                    source = ltn12.source.string(content),
                    sink = ltn12.sink.table(res),
                    protocol = "any",
                    verify = "none",
                }
            else
                resState, resCode, resHeaders = http.request {
                    url = url,
                    method = method,
                    headers = bheaders,
                    source = ltn12.source.string(content),
                    sink = ltn12.sink.table(res),
                }
            end
            local execTime = socket.gettime() * 1000 - time
            LogOutput("INFO", "Webhook: %i %s \"%s\" %.1fms", resCode, method, url, execTime)
            if resCode == 200 then
                LogOutput("DEBUG", "Res OK:\n%s", json.stringify(res))
            else
                error(string.format("Wehbhook request failure: Exit code: %i", resCode))
            end
        else
            error(
                string.format(
                    "Failed to send webhook: Required module(s) not loaded: %s %s %s",
                    socket and "socket" or nil,
                    http and "http" or nil,
                    ltn12 and "ltn12" or nil
                )
            )
        end
    end
end

---Send a request synchronously to the specified webhook URL
---@param content string? Request body in JSON string format
local function CreateWebhookRequest(content)
    ExecuteAsync(function()
        LogOutput("DEBUG", "Sending webhook content:\n%s", content)
        pcall(__createWebhookRequest, webhookUrl, content)
    end)
end

---Create a webhook request from and event and its data.
---The request will be made asynchronously
---@param event string Event name. Usually the full path to the function hook.
---@param data table Payload to send to the webhook endpoint
---@param callback fun(status: boolean)? Optional callback after handling the request
local function CreateEventWebhook(event, data, callback)
    LogOutput("DEBUG", "Received hook event %s", event)
    if socket and webhookUrl and server then
        local payload = json.stringify {
            hook = event,
            timestamp = math.floor(socket.gettime() * 1000),
            data = data
        }
        LogOutput("DEBUG", "Collecting payload:\n%s", payload)
        ExecuteAsync(function()
            LogOutput("DEBUG", "Sending webhook content:\n%s", payload)
            local status = pcall(__createWebhookRequest, webhookUrl, payload)
            if callback then
                callback(status)
            end
        end)
    end
end

---Send a request synchronously to the specified webhook URL
---@param path string
---@param content string? Request body in JSON string format
---@return boolean
local function CreateServerRequest(path, content)
    local serverUrl = os.getenv("MOD_SERVER_API_URL")

    if not serverUrl then return false end

    local state, err = pcall(__createWebhookRequest, serverUrl .. path, content)
    if not state then
        LogOutput("ERROR", "Failed to create server API request: %s", err)
    end
    return state
end

return {
    ---@deprecated Use `CreateEventWebhook` instead for additional functionality
    CreateWebhookRequest = CreateWebhookRequest,
    CreateServerRequest = CreateServerRequest,
    CreateEventWebhook = CreateEventWebhook
}
