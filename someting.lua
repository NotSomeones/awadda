local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local endpoint = "http://201.229.73.179:8000/update"

local function getPlayerData()
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

local function sendPlayerData()
    local data = getPlayerData()
    local jsonData = HttpService:JSONEncode(data)
    local headers = {
        ["Content-Type"] = "application/json"
    }

    local success, response = pcall(function()
        return HttpService:PostAsync(endpoint, jsonData, Enum.HttpContentType.ApplicationJson, false, headers)
    end)

    if success then
        print("Data sent successfully")
    else
        warn("Failed to send data: " .. tostring(response))
    end
end

RunService.Heartbeat:Connect(function()
    -- send data every frame (no delay)
    sendPlayerData()
end)
