local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local httpRequest = http_request or request or syn.request

local endpoint = "http://201.229.73.179:8000/update"  -- Your FastAPI POST endpoint

local function getPlayerPositions()
    local players = game:GetService("Players"):GetPlayers()
    local data = {}

    for _, player in pairs(players) do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            table.insert(data, {
                name = player.Name,
                x = hrp.Position.X,
                z = hrp.Position.Z
            })
        end
    end

    return data
end

local function sendPositions()
    local data = getPlayerPositions()
    local jsonData = HttpService:JSONEncode(data)

    local success, response = pcall(function()
        return httpRequest({
            Url = endpoint,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonData
        })
    end)

    if success then
        print("Positions sent successfully")
    else
        warn("Failed to send positions: " .. tostring(response))
    end
end

-- Send on every heartbeat (use with caution, it sends ~60 requests per second)
RunService.Heartbeat:Connect(function()
    sendPositions()
end)
