local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- CONFIG
local localPlayerName = "jmasters360"      -- Your Roblox player name
local priorityName    = "PlanetZ_DK"       -- The player to be placed first
local outputFile      = "playerdata.json"

-- Wait for local player
local function waitForPlayer(name)
    local player
    repeat
        player = game.Players:FindFirstChild(name)
        task.wait()
    until player
    return player
end

local localPlayer = waitForPlayer(localPlayerName)
local lastHash = nil

-- Hash utility
local function simpleHash(text)
    local hash = 0
    for i = 1, #text do
        hash = hash + string.byte(text, i)
    end
    return hash
end

RunService.Heartbeat:Connect(function()
    local char = localPlayer.Character
    if not char or not char.PrimaryPart then return end

    local head = char:FindFirstChild("Head")
    if not head then return end

    local rootCF = char.PrimaryPart.CFrame
    local offsetCF = rootCF * CFrame.Angles(0, math.rad(-90), 0)
    local lookVec = offsetCF.LookVector
    local origin = head.Position

    local out = {}

    for _, player in ipairs(game.Players:GetPlayers()) do
        if player == localPlayer then continue end
        local c = player.Character
        if c and c.PrimaryPart and c:FindFirstChild("Head") then
            local pos = c.Head.Position
            local rel = pos - origin

            local adjX = rel:Dot(Vector3.new(lookVec.X, 0, lookVec.Z))
            local adjZ = rel:Dot(Vector3.new(-lookVec.Z, 0, lookVec.X))

            table.insert(out, {
                name = player.Name,
                pos = {
                    x = adjX,
                    y = rel.Y,
                    z = adjZ,
                }
            })
        end
    end

    -- Insert local player with facing direction at the start
    table.insert(out, 1, {
        name = priorityName,
        pos = { x = 0, y = 0, z = 0 },
        dir = { x = lookVec.X, z = lookVec.Z }
    })

    local encoded = HttpService:JSONEncode(out)
    local hash = simpleHash(encoded)

    if hash ~= lastHash then
        lastHash = hash
        pcall(function()
            writefile(outputFile, encoded)
        end)
    end
end)
