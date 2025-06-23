-- Low-latency Roblox sender with change-threshold, throttling, and debug prints

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

-- STATE
local lastSentTime = 0
-- lastPositions[name] = {x=..., z=...}
local lastPositions = {}

-- Build payload: returns table mapping name -> {x, z}
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
    print("[gatherPositions] Found " .. tostring(#Players:GetPlayers()) .. " players, payload entries: " .. tostring(#(function(t) local c=0; for _ in pairs(t) do c=c+1 end; return {c} end)(out))) 
    return out
end

-- Compare current vs lastPositions: return true if any moved > threshold or join/leave
local function hasSignificantChange(current)
    -- Check new or moved players
    for name, pos in pairs(current) do
        local last = lastPositions[name]
        if not last then
            print(("[hasChange] New player or first read: %s"):format(name))
            return true
        end
        local dx = pos.x - last.x
        local dz = pos.z - last.z
        if dx*dx + dz*dz > moveThreshold * moveThreshold then
            print(("[hasChange] Player %s moved significantly: Δx=%.2f, Δz=%.2f"):format(name, dx, dz))
            return true
        end
    end
    -- Check removed players
    for name in pairs(lastPositions) do
        if not current[name] then
            print(("[hasChange] Player left or no longer has HRP: %s"):format(name))
            return true
        end
    end
    return false
end

local function sendPositions(currentTbl)
    if not request then
        warn("Skipping sendPositions: no request function")
        return false
    end

    -- Build array payload with shorter keys
    local arr = {}
    for name, pos in pairs(currentTbl) do
        table.insert(arr, { n = name, x = pos.x, z = pos.z })
    end

    local ok, jsonData = pcall(function()
        return HttpService:JSONEncode(arr)
    end)
    if not ok then
        warn("[sendPositions] JSON encode failed:", jsonData)
        return false
    end

    print(("[sendPositions] Sending payload with %d entries"):format(#arr))
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
        warn("[sendPositions] HTTP request error:", response)
        return false
    end
    if response and response.StatusCode == 200 then
        print("[sendPositions] Success (HTTP 200)")
        -- update lastPositions on success
        lastPositions = currentTbl
        return true
    else
        local code = response and response.StatusCode or "nil"
        local body = response and response.Body or ""
        warn(("[sendPositions] Failed send: HTTP %s, body: %s"):format(tostring(code), tostring(body)))
        return false
    end
end

RunService.Heartbeat:Connect(function(dt)
    lastSentTime = lastSentTime + dt
    local current = gatherPositions()
    if hasSignificantChange(current) and lastSentTime >= minInterval then
        print("[Heartbeat] Significant change and >= minInterval, attempting send")
        if sendPositions(current) then
            lastSentTime = 0
        end
    elseif lastSentTime >= maxInterval then
        print("[Heartbeat] maxInterval reached, forcing send")
        if sendPositions(current) then
            lastSentTime = 0
        end
    else
        -- Debug: not sending this tick
        -- print(("[Heartbeat] No send: lastSentTime=%.2f"):format(lastSentTime))
    end
end)

-- Immediate send on join/leave
Players.PlayerAdded:Connect(function(player)
    print("[PlayerAdded] " .. player.Name)
    local current = gatherPositions()
    if sendPositions(current) then
        lastSentTime = 0
    end
end)
Players.PlayerRemoving:Connect(function(player)
    print("[PlayerRemoving] " .. player.Name)
    local current = gatherPositions()
    if sendPositions(current) then
        lastSentTime = 0
    end
end)
