-- LocalScript (StarterPlayerScripts) — Exploit HTTP version

local RunService  = game:GetService("RunService")
local Players     = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Pick whichever executor function exists
local httpRequest = http_request or request or (syn and syn.request)

-- Configuration
local SERVER_URL    = "http://201.229.73.179:3000/update"
local SEND_INTERVAL = 0.2  -- seconds between POSTS

-- Make map‐center at (0,0) in 2D: ignore Y axis entirely.
local function to2D(pos3)
    -- pos3.X and pos3.Z are your game’s horizontal plane;
    -- we treat (0,0) = world origin as canvas center.
    return { x = pos3.X, z = pos3.Z }
end

local lastSend = 0
RunService.Heartbeat:Connect(function(dt)
    lastSend = lastSend + dt
    if lastSend < SEND_INTERVAL then return end
    lastSend = 0

    if not httpRequest then
        warn("[Minimap] no httpRequest available")
        return
    end

    -- Build payload array
    local payload = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            table.insert(payload, {
                username = plr.Name,
                position = to2D(hrp.Position)  -- only X,Z
            })
        end
    end

    -- Debug send
    print(("[Minimap] → Sending %d players"):format(#payload))

    -- Encode + build req
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

    -- Fire off
    local ok, res = pcall(function() return httpRequest(reqInfo) end)
    if not ok then
        warn("[Minimap] request error:", res)
        return
    end

    -- Dump response for debugging
    print("[Minimap] ← Raw response fields:")
    for k,v in pairs(res) do print(("  %s = %s"):format(tostring(k), tostring(v))) end

    local code = res.StatusCode or res.status or res.code
    local data = res.Body       or res.body or res.data
    print(("[Minimap] ← Status: %s  Body: %s"):format(tostring(code), tostring(data)))
end)
