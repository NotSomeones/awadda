-- Simplified KRNL Lua script: write player data to "playerdata.json" via writefile
local HttpService = game:GetService("HttpService")
local localPlayerName = "PlanetZ_DK"

-- Wait until player exists
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
        for _, v in ipairs(game.Players:GetPlayers()) do
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
