-- FASTAPI ENDPOINT
local ENDPOINT = "http://201.229.73.179:8000/update"  -- change to your public IP if needed

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- CONFIG
local UPDATE_INTERVAL = 1 -- seconds
local SendLoopEnabled = true

-- Helper to get all visible player data (name, x, z)
local function getPlayerData()
    local data = {}

    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            table.insert(data, {
                name = player.Name,
                x = math.floor(hrp.Position.X),
                z = math.floor(hrp.Position.Z)
            })
        end
    end

    return data
end

-- Send loop
task.spawn(function()
    while SendLoopEnabled do
        local ok, err = pcall(function()
            local payload = HttpService:JSONEncode(getPlayerData())
            HttpService:PostAsync(ENDPOINT, payload, Enum.HttpContentType.ApplicationJson)
        end)

        if not ok then
            warn("[MinimapSender] Failed to send data:", err)
        end

        task.wait(UPDATE_INTERVAL)
    end
end)
