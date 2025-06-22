-- Services
local RunService   = game:GetService("RunService")
local Players      = game:GetService("Players")
local HttpService  = game:GetService("HttpService")

-- Executor HTTP function
local httpRequest = http_request or request or syn.request

-- Configuration
local SERVER_URL    = "http://201.229.73.179:3000/update"
local SEND_INTERVAL = 0.2  -- seconds between POSTS

-- State
local lastSend = 0

RunService.Heartbeat:Connect(function(deltaTime)
    lastSend = lastSend + deltaTime
    if lastSend < SEND_INTERVAL then
        return
    end
    lastSend = 0

    -- Gather positions for every player
    local payload = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            table.insert(payload, {
                username = player.Name,
                position = {
                    x = root.Position.X,
                    y = root.Position.Y,
                    z = root.Position.Z,
                }
            })
        end
    end

    -- Debug: what are we sending?
    print(("[Minimap] Sending payload for %d player(s) at time %.2f"):format(#payload, tick()))

    -- JSON-encode
    local body = HttpService:JSONEncode(payload)

    -- Send via executor http_request
    local success, response = pcall(function()
        return httpRequest({
            Url     = SERVER_URL,
            Method  = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body    = body
        })
    end)

    -- Debug: inspect result
    if success then
        if response and response.StatusCode then
            print(("[Minimap] POST returned status %d"):format(response.StatusCode))
            if response.Body then
                print("[Minimap] Response body:", response.Body)
            end
        else
            print("[Minimap] POST succeeded but no StatusCode in response")
        end
    else
        warn("[Minimap] HTTP request failed:", response)
    end
end)
