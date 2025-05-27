local json = require("JsonParser")
local statics = require("Statics")

local function __createWebhookRequest(content)
    local dir = os.getenv("PWD") or io.popen("cd"):read()
    package.cpath = package.cpath .. ";" .. dir .. "/ue4ss/Mods/shared/?/core.dll"
    package.cpath = package.cpath .. ";" .. dir .. "/ue4ss/Mods/shared/?.dll"
    local http = require("socket.http")
    local https = require("ssl.https")
    local ltn12 = require("ltn12")
    local webhookUrl = os.getenv("MOD_WEBHOOK_URL")

    if not webhookUrl then return end

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

    LogMsg("Sending POST request to " .. webhookUrl .. " with payload size: " .. #content, "DEBUG")
    if string.match(webhookUrl, "^https:") then
        resState, resCode, resHeaders, resSecure = https.request {
            url = webhookUrl,
            method = "POST",
            headers = bheaders,
            source = ltn12.source.string(content),
            sink = ltn12.sink.table(res),
            protocol = "any",
            verify = "none",
        }
    else
        resState, resCode, resHeaders = http.request {
            url = webhookUrl,
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
---@param content string Request body in JSON string format
local function CreateWebhookRequest(content)
    local state, err = pcall(__createWebhookRequest, content)
    if not state then
        LogMsg("Failed to create webhook request: " .. err, "ERROR")
    end
    return state
end

return {
    CreateWebhookRequest = CreateWebhookRequest
}
