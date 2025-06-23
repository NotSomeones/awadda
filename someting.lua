-- Low-latency Roblox sender with change-threshold and throttling

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Determine request function
local request = request or http_request or (syn and syn.request)
if not request then
    warn("No HTTP request function available; HTTP will not work.")
end

-- CONFIGURATION
local endpoint = "http://201.229.73.179:8000/update"
local minInterval = 0.5         -- seconds: send at least every 0.5s
local maxInterval = 2           -- seconds: force send if no significant movement but max time elapsed
local moveThreshold = 1         -- studs: send if moved >1 stud since last sent
-- You can lower minInterval (e.g. 0.2) but beware rate limits.

-- STATE
local lastSentTime = 0
-- lastPositions[name] = {x=..., z=...}
local lastPositions = {}

-- Build payload only for players with HumanoidRootPart
local function gatherPositions()
    local out = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                out[player.Name] = { x = hrp.Position.X, z = hrp.Position.Z }
            end
        end
    end
    return out
end

-- Compare current vs lastPositions: return true if any moved > threshold
local function hasSignificantChange(current)
    for name, pos in pairs(current) do
        local last = lastPositions[name]
        if not last then
            return true
        end
        local dx = pos.x - last.x
        local dz = pos.z - last.z
        if dx*dx + dz*dz > moveThreshold * moveThreshold then
            return true
        end
    end
    -- Also if a player left since lastPositions
    for name in pairs(lastPositions) do
        if not current[name] then
            return true
        end
    end
    return false
end

local function sendPositions(currentTbl)
    if not request then return end
    -- Build array payload with shorter keys if desired
    local arr = {}
    for name, pos in pairs(currentTbl) do
        table.insert(arr, { n = name, x = pos.x, z = pos.z })
    end

    local ok, jsonData = pcall(function()
        return HttpService:JSONEncode(arr)
    end)
    if not ok then
        warn("JSON encode failed:", jsonData)
        return false
    end

    local success, response = pcall(function()
        return request({
            Url = endpoint,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonData
        })
    end)
    if not success then
        warn("HTTP request error:", response)
        return false
    end
    if response and response.StatusCode == 200 then
        -- update lastPositions
        lastPositions = currentTbl
        return true
    else
        local code = response and response.StatusCode or "nil"
        local body = response and response.Body or ""
        warn(("Failed send: HTTP %s, body: %s"):format(tostring(code), tostring(body)))
        return false
    end
end

RunService.Heartbeat:Connect(function(dt)
    lastSentTime = lastSentTime + dt
    local current = gatherPositions()
    if hasSignificantChange(current) and lastSentTime >= minInterval then
        if sendPositions(current) then
            lastSentTime = 0
        end
    elseif lastSentTime >= maxInterval then
        -- force send even if no big movement, to keep alive
        if sendPositions(current) then
            lastSentTime = 0
        end
    end
end)

-- Immediate send on join/leave
Players.PlayerAdded:Connect(function()
    local current = gatherPositions()
    if sendPositions(current) then
        lastSentTime = 0
    end
end)
Players.PlayerRemoving:Connect(function()
    local current = gatherPositions()
    if sendPositions(current) then
        lastSentTime = 0
    end
end)
