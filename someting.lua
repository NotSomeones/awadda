-- Minimap Sender: Synapse / KRNL
-- Sends all player positions (x, z only) to your server every 0.2s

local RunService  = game:GetService("RunService")
local Players     = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local httpRequest = http_request or request or (syn and syn.request)

-- Ensure HTTP function is available
if not httpRequest then
    warn("[Minimap] ❌ No supported HTTP function in executor.")
    return
end

-- Config
local SERVER_URL    = "http://201.229.73.179:3000/update"
local SEND_INTERVAL = 0.2
local lastSend      = 0

RunService.Heartbeat:Connect(function(dt)
    lastSend += dt
    if lastSend < SEND_INTERVAL then return end
    lastSend = 0

    local payload = {}

    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            table.insert(payload, {
                username = player.Name,
                position = {
                    x = root.Position.X,
                    z = root.Position.Z  -- 2D only
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

        -- Lowercase compatibility for KRNL/etc
        url     = SERVER_URL,
        method  = "POST",
        headers = { ["Content-Type"] = "application/json" },
        body    = body
    }

    local success, response = pcall(function()
        return httpRequest(req)
    end)

    if success then
        print(("[Minimap] ✅ Sent %d players | Code: %s"):format(#payload, response.StatusCode or response.status or "???"))
    else
        warn("[Minimap] ❌ Failed to send:", response)
    end
end)
