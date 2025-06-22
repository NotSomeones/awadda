-- Services
local HttpService   = game:GetService("HttpService")
local RunService    = game:GetService("RunService")
local Players       = game:GetService("Players")

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
    for _, player in pairs(Players:GetPlayers()) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            table.insert(payload, {
                username = player.Name,
                position = {
                    x = root.Position.X,
                    y = root.Position.Y,
                    z = root.Position.Z
                }
            })
        end
    end

    -- Send in one go
    local ok, err = pcall(function()
        HttpService:PostAsync(
            SERVER_URL,
            HttpService:JSONEncode(payload),
            Enum.HttpContentType.ApplicationJson
        )
    end)
    if not ok then
        warn("Minimap POST failed:", err)
    end
end)
