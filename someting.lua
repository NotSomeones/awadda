-- FINAL MINIMAP TEST SENDER FOR SYNAPSE / KRNL

local RunService  = game:GetService("RunService")
local Players     = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local httpRequest = http_request or request or (syn and syn.request)

if not httpRequest then
    warn("❌ Executor doesn't support HTTP")
    return
end

local SERVER_URL = "http://201.229.73.179:3000/update"
local SEND_INTERVAL = 0.5
local lastSend = 0

RunService.Heartbeat:Connect(function(dt)
    lastSend += dt
    if lastSend < SEND_INTERVAL then return end
    lastSend = 0

    local payload = {}

    for _, player in ipairs(Players:GetPlayers()) do
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            table.insert(payload, {
                username = player.Name,
                position = {
                    x = math.floor(root.Position.X),
                    z = math.floor(root.Position.Z)
                }
            })
        end
    end

    if #payload == 0 then return end

    local body = HttpService:JSONEncode(payload)

    local req = {
        Url     = SERVER_URL,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = body,

        url     = SERVER_URL,
        method  = "POST",
        headers = { ["Content-Type"] = "application/json" },
        body    = body
    }

    local success, res = pcall(function() return httpRequest(req) end)

    if success then
        print("✅ Sent", #payload, "players. Code:", res.StatusCode or res.status or "unknown")
    else
        warn("❌ Failed to send:", res)
    end
end)
