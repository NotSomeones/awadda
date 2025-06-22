-- Services
local RunService  = game:GetService("RunService")
local Players     = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Executor HTTP function
local httpRequest = http_request or request or syn.request

-- Configuration
local SERVER_URL    = "http://201.229.73.179:3000/update"
local SEND_INTERVAL = 0.2  -- seconds between POSTS

-- State
local lastSend = 0

RunService.Heartbeat:Connect(function(dt)
    lastSend = lastSend + dt
    if lastSend < SEND_INTERVAL then return end
    lastSend = 0

    -- 1) Gather positions
    local payload = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            payload[#payload+1] = {
                username = plr.Name,
                position = { x = hrp.Position.X, y = hrp.Position.Y, z = hrp.Position.Z }
            }
        end
    end

    -- 2) Debug print
    print(("[Minimap] → Sending %d entries"):format(#payload))

    -- 3) Build the request table (all common key variants)
    local body    = HttpService:JSONEncode(payload)
    local reqInfo = {
        Url     = SERVER_URL,
        url     = SERVER_URL,
        Method  = "POST",
        method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        headers = { ["Content-Type"] = "application/json" },
        Body    = body,
        body    = body,
    }

    -- 4) Fire the request inside a function for pcall
    local ok, res = pcall(function() return httpRequest(reqInfo) end)

    -- 5) Check for pcall error
    if not ok then
        warn("[Minimap] httpRequest error:", res)
        return
    end

    -- 6) Dump all response fields
    print("[Minimap] ← Raw response fields:")
    for k,v in pairs(res) do
        print(("   %s = %s"):format(tostring(k), tostring(v)))
    end

    -- 7) Interpret status & body
    local code = res.StatusCode or res.status or res.code
    local data = res.Body       or res.body or res.data
    print(("[Minimap] ← Status code: %s"):format(tostring(code)))
    print(("[Minimap] ← Body: %s"):format(tostring(data)))
end)
