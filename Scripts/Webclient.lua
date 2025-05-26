local dir = os.getenv("PWD") or io.popen("cd"):read()
package.cpath = package.cpath .. ";" .. dir .. "/ue4ss/Mods/shared/?/core.dll"
local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("JsonParser")

---Send a request synchronously to the specified webhook URL
---@param content string Request body
---@return boolean
local function CreateWebhookRequest(content)
    local webhookUrl = os.getenv("MOD_WEBHOOK_URL")
    if not webhookUrl then return false end

    local bheaders = {}
    bheaders["accept"] = "*/*"
    bheaders["accept-encoding"] = "gzip,deflate,br"
    bheaders["content-type"] = "application/json"
    bheaders["content-length"] = tostring(content:len())
    bheaders["connection"] = "keep-alive"
    bheaders["user-agent"] = "MotorTown server 0.1.1"

    local res = {}
    LogMsg("Sending POST request to " .. webhookUrl)
    local r, c, h = http.request {
        url = webhookUrl,
        method = "POST",
        headers = bheaders,
        sink = ltn12.sink.table(res),
        source = ltn12.source.string(content)
    }
    if c == 200 then
        LogMsg("Res OK:\n" .. json.stringify(res))
        return true
    end
    LogMsg("Failed to send request with exit code: " .. c, "ERROR")
    LogMsg("Failed to send request with headers: " .. json.stringify(h), "ERROR")
    return false
end

return {
    CreateWebhookRequest = CreateWebhookRequest
}
