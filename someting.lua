-- Optimized KRNL Lua writer for near-instant radar
local HttpService      = game:GetService("HttpService")
local RunService       = game:GetService("RunService")
local writefile_safe   = writefile
local getPlayers       = game.Players.GetPlayers
local findChild        = game.Players.FindFirstChild
local abs, floor       = math.abs, math.floor
local rad, dot         = math.rad, Vector3.new().Dot

-- User settings:
local localName    = "jmasters360"
local priorityName = "PlanetZ_DK"
local outPath      = "playerdata.json"

-- Wait for local player instance
local function waitForPlayer(name)
    local p = findChild(game.Players, name)
    if p then return p end
    repeat RunService.Heartbeat:Wait() until findChild(game.Players, name)
    return findChild(game.Players, name)
end

local localPlayer = waitForPlayer(localName)

-- Build output table each heartbeat
local lastJson, lastHash = "", nil
RunService.Heartbeat:Connect(function()
    -- Character check
    local char = localPlayer.Character
    if not char or not char.PrimaryPart then return end

    local head = char:FindFirstChild("Head")
    if not head then return end

    local basePos   = head.Position
    local lookCF    = char.PrimaryPart.CFrame * CFrame.Angles(0, rad(-90), 0)
    local lookVec   = lookCF.LookVector

    -- One-pass build: priorityName first, then others
    local out       = {}
    local players   = getPlayers(game.Players)
    for i = 1, #players do
        local p = players[i]
        if p.Name ~= localName then
            local c = p.Character
            if c and c.PrimaryPart then
                local hPos = c.Head.Position
                local rel  = hPos - basePos
                local x    = dot(Vector3.new(lookVec.X,0,lookVec.Z), rel)
                local z    = dot(Vector3.new(-lookVec.Z,0,lookVec.X), rel)
                local entry = {
                    name  = p.Name,
                    pos   = { x = x, y = rel.Y, z = z },
                    lookY = c.Head.Rotation.Y
                }
                if p.Name == priorityName then
                    table.insert(out, 1, entry)
                else
                    out[#out+1] = entry
                end
            end
        end
    end

    -- JSON-encode and hash
    local jsonText = HttpService:JSONEncode(out)
    local hash     = #jsonText + (jsonText:byte(1) or 0)
    if hash ~= lastHash then
        lastHash, lastJson = hash, jsonText
        pcall(writefile_safe, outPath, jsonText)
    end
end)
