local json = require("JsonParser")
local statics = require("Statics")
local socket = RequireSafe("socket") ---@type Socket?
local http = RequireSafe("socket.http")
local https = RequireSafe("ssl.https")
local ltn12 = RequireSafe("ltn12")
local webhookUrl = os.getenv("MOD_WEBHOOK_URL")
local method = os.getenv("MOD_WEBHOOK_METHOD") or "POST"
local extraHeaders = json.parse(os.getenv("MOD_WEBHOOK_EXTRA_HEADERS") or "{}") or {}
local webhookEvents = SplitString(os.getenv("MOD_WEBHOOK_ENABLE_EVENTS") or "all", ",") or {}

---@enum (key) EventHook
local events = {
    ServerSendChat = "/Script/MotorTown.MotorTownPlayerController:ServerSendChat",
    ServerAcceptDelivery = "/Script/MotorTown.MotorTownPlayerController:ServerAcceptDelivery",
    ServerAddEvent = "/Script/MotorTown.MotorTownPlayerController:ServerAddEvent",
    ServerChangeEventState = "/Script/MotorTown.MotorTownPlayerController:ServerChangeEventState",
    ServerRemoveEvent = "/Script/MotorTown.MotorTownPlayerController:ServerRemoveEvent",
    ServerPassedRaceSection = "/Script/MotorTown.MotorTownPlayerController:ServerPassedRaceSection",
    ServerJoinEvent = "/Script/MotorTown.MotorTownPlayerController:ServerJoinEvent",
    ServerLeaveEvent = "/Script/MotorTown.MotorTownPlayerController:ServerLeaveEvent",
    ServerCargoArrived = "/Script/MotorTown.MotorTownPlayerController:ServerCargoArrived",
    ServerCreateCompany = "/Script/MotorTown.MotorTownPlayerController:ServerCreateCompany",
    ServerCloseDownCompany = "/Script/MotorTown.MotorTownPlayerController:ServerCloseDownCompany",
    ServerRequestJoinCompany = "/Script/MotorTown.MotorTownPlayerController:ServerRequestJoinCompany",
    ServerDenyCompanyJoinRequest = "/Script/MotorTown.MotorTownPlayerController:ServerDenyCompanyJoinRequest",
}

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
                MergeTables(bheaders, extraHeaders)
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

            if type(resCode) == "string" then
                error(string.format("Failed to send webhook request: %s", resCode))
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

---Request pool
---@type [table, fun(status: boolean)?][]
local requests = {}

---Create a webhook request from and event and its data.
---The request will be made asynchronously
---@param event string Event name. Usually the full path to the function hook.
---@param data table|table[] Payload to send to the webhook endpoint
---@param callback fun(status: boolean)? Optional callback after handling the request
local function CreateEventWebhook(event, data, callback)
    LogOutput("DEBUG", "Received hook event %s", event)
    if socket and webhookUrl then
        local payload = {
            hook = event,
            timestamp = math.floor(socket.gettime() * 1000),
            data = data
        }
        LogOutput("DEBUG", "Collecting payload:\n%s", payload)
        table.insert(requests, { payload, callback })
    end
end

-- Get the amount of delay in between async loop (ms).
-- This will slot in between webserver loops.
local delay = (tonumber(os.getenv("MOD_SERVER_PROCESS_AMOUNT")) or 5) * 100
LoopAsync(delay, function()
    if #requests > 0 then
        local payloads = {} ---@type table[]
        local callbacks = {} ---@type fun(status: boolean)[]

        -- Return the payload in order
        -- This also takes into account possible table insertion while processing data
        while #requests ~= 0 do
            local payload, callback = table.unpack(table.remove(requests, 1))
            table.insert(payloads, payload)
            table.insert(callbacks, callback)
        end

        local payload = json.stringify(payloads)
        LogOutput("DEBUG", "Sending webhook content:\n%s", payload)
        -- Silently send the webhook request without raising any error
        local status = pcall(__createWebhookRequest, webhookUrl, payload)

        for _, value in ipairs(callbacks) do
            value(status)
        end
    end
    return webhookEvents[1] == "none"
end)

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

---Check if event hook enabled
---@param event EventHook
---@return boolean enabled
---@return string? eventName
local function isEventEnabled(event)
    if webhookEvents[1] == "none" then return false end

    for index, value in ipairs(webhookEvents) do
        if events[event] and (value == "all" or event == value) then
            return true, events[event]
        end
    end
    return false
end

---Register event hook wrapper
---@param event EventHook
---@param hookFunction fun(self: UObject, ...): table|table[]
---@param callback fun(status: boolean)?
---@return integer? preId
---@return integer? postId
local function RegisterEventHook(event, hookFunction, callback)
    local isEnabled, eventName = isEventEnabled(event)
    if isEnabled and eventName then
        local status, out1, out2 = pcall(function()
            local preId, postId = RegisterHook(eventName, function(self, ...)
                local status, result = pcall(hookFunction, self, ...)
                if status then
                    if result and type(result) == "table" then
                        CreateEventWebhook(eventName, result, callback)
                    else
                        error("Invalid return value specified")
                    end
                else
                    LogOutput("ERROR", "Failed to execute event hook: %s", result)
                end
            end)
            return preId, postId
        end)
        if status then
            return out1, out2
        else
            LogOutput("ERROR", "Failed to register event hook: %s", out1)
        end
    end
end

return {
    ---@deprecated Use `CreateEventWebhook` instead for additional functionality
    CreateWebhookRequest = CreateWebhookRequest,
    CreateServerRequest = CreateServerRequest,
    ---@deprecated Use `RegisterEventHook` wrapper function for cleaner code
    CreateEventWebhook = CreateEventWebhook,
    RegisterEventHook = RegisterEventHook,
}
