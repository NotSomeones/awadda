-- Simplified KRNL Lua script: write player data to "playerdata.json" via writefile,
-- but ensure that "PlanetZ_DK" (if in the game) is first in the JSON array.

local HttpService = game:GetService("HttpService")
local localPlayerName = "jmasters360"      -- your local player
local priorityName = "PlanetZ_DK"         -- the player you want first in the output

-- Wait until local player exists
local function getLocalPlayer()
    local plr = game.Players:FindFirstChild(localPlayerName)
    if plr then return plr end
    for i = 1, 50 do
        task.wait(0.1)
        plr = game.Players:FindFirstChild(localPlayerName)
        if plr then return plr end
    end
    error("Local player not found: " .. localPlayerName)
end

local localPlayer = getLocalPlayer()

-- Sort players so that priorityName comes first (if present), then the rest
local function sortPlayers(players)
    local sorted = {}
    -- First: priorityName if present
    for _, v in ipairs(players) do
        if v.Name == priorityName then
            table.insert(sorted, v)
            break
        end
    end
    -- Then: everyone else (excluding priorityName)
    for _, v in ipairs(players) do
        if v.Name ~= priorityName then
            table.insert(sorted, v)
        end
    end
    return sorted
end

while task.wait(0.01) do
    local ok, tbl = pcall(function()
        local char = localPlayer.Character
        if not char then return {} end
        local head = char:FindFirstChild("Head")
        local root = char.PrimaryPart
        if not head or not root then return {} end

        local lpPos = head.Position
        local lpCF = root.CFrame
        local offsetCF = lpCF * CFrame.Angles(0, math.rad(-90), 0)
        local lookVec = offsetCF.LookVector

        local out = {}
        -- Get all players and sort them
        local allPlayers = sortPlayers(game.Players:GetPlayers())
        for _, v in ipairs(allPlayers) do
            if v.Name ~= localPlayerName then
                local c = v.Character
                if c then
                    local h = c:FindFirstChild("Head")
                    local rp = c.PrimaryPart
                    if h and rp then
                        local pos = h.Position
                        local rel = pos - lpPos
                        local adjX = rel:Dot(Vector3.new(lookVec.X, 0, lookVec.Z))
                        local adjZ = rel:Dot(Vector3.new(-lookVec.Z, 0, lookVec.X))
                        table.insert(out, {
                            name = v.Name,
                            pos = { x = adjX, y = rel.Y, z = adjZ },
                            lookY = h.Rotation.Y
                        })
                    end
                end
            end
        end
        return out
    end)

    if ok then
        local success, jsonText = pcall(function()
            return HttpService:JSONEncode(tbl)
        end)
        if success then
            pcall(function()
                writefile("playerdata.json", jsonText)
            end)
        end
    end
end
