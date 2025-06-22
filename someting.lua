-- LocalScript (for executor only)

local RunService  = game:GetService("RunService")
local Players     = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Executor HTTP function
local httpRequest = http_request or request or (syn and syn.request)

if not httpRequest then
    warn("[Minimap] ❌ No executor HTTP function found")
    return
end

local SERVER_URL    = "http://201.229.73.179:3000/update"
local SEND_INTERVAL = 0.2
local lastSend      = 0

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
                    x = root.Position.X,
                    z = root.Position.Z, -- ignore Y for 2D map
                }
            })
        end
    end

    -- Debug
    print(("[Minimap] Sending %d player(s)"):format(#payload))

    local body = HttpService:JSONEncode(payload)

    local requestData = {
        Url     = SERVER_URL,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = body,
    }

    -- Add lowercase keys for KRNL/some executors
    requestData.url     = requestData.Url
    requestData.method  = requestData.Method
    requestData.headers = requestData.Headers
    requestData.body    = requestData.Body

    local success, response = pcall(function()
        return httpRequest(requestData)
    end)

    if not success then
        warn("[Minimap] ❌ HTTP request failed:", response)
        return
    end

    -- Response dump
    print("[Minimap] ✅ HTTP request sent. Response:")
    for k, v in pairs(response) do
        print(" ", k, "=", v)
    end
end)
