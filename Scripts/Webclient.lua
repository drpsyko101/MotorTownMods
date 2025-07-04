local json = require("JsonParser")
local statics = require("Statics")

local webhookFailure = false

---Send a request to the specified URL
---@param url string
---@param content string?
local function __createWebhookRequest(url, content)
    if webhookFailure then return end

    local dir = os.getenv("PWD") or io.popen("cd"):read()
    package.cpath = package.cpath .. ";" .. dir .. "/ue4ss/Mods/shared/?/core.dll"
    package.cpath = package.cpath .. ";" .. dir .. "/ue4ss/Mods/shared/?.dll"
    local http = require("socket.http")
    local ltn12 = require("ltn12")

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

    LogMsg("Sending POST request to " .. url .. " with payload size: " .. #content, "DEBUG")
    if string.match(url, "^https:") then
        error("HTTPS webhook endpoint is not currently supported.")
    else
        resState, resCode, resHeaders = http.request {
            url = url,
            method = "POST",
            headers = bheaders,
            source = ltn12.source.string(content),
            sink = ltn12.sink.table(res),
        }
    end
    if resCode == 200 then
        LogMsg("Res OK:\n" .. json.stringify(res), "DEBUG")
        return
    end
    error("Request failure: Exit code: " .. resCode)
end

---Send a request synchronously to the specified webhook URL
---@param content string? Request body in JSON string format
---@return boolean
local function CreateWebhookRequest(content)
    local url = os.getenv("MOD_WEBHOOK_URL")

    if not url then return false end

    local state, err = pcall(__createWebhookRequest, url, content)
    if not state then
        LogMsg("Failed to create webhook request: " .. err, "ERROR")
        webhookFailure = true
    end
    return state
end

---Send a request synchronously to the specified webhook URL
---@param path string
---@param content string? Request body in JSON string format
---@return boolean
local function CreateServerRequest(path, content)
    local url = os.getenv("MOD_SERVER_API_URL")

    if not url then return false end

    local state, err = pcall(__createWebhookRequest, url .. path, content)
    if not state then
        LogMsg("Failed to create server API request: " .. err, "ERROR")
    end
    return state
end

return {
    CreateWebhookRequest = CreateWebhookRequest,
    CreateServerRequest = CreateServerRequest
}
