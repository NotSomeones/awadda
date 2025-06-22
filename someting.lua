local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local webhookUrl = "https://discord.com/api/webhooks/1352187286648786944/3wwWAquZ_EjA4hgjDMVjwEfZKKBN3nXfehfxB7wpverPVm0yY9kWd-X0PBmgtfoxDEiD"
local httpRequest = http_request or request or syn.request

local function sendPlayerLocations()
	local playerData = {}

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local pos = character.HumanoidRootPart.Position
			table.insert(playerData, {
				name = player.Name,
				userId = player.UserId,
				x = math.floor(pos.X),
				y = math.floor(pos.Y),
				z = math.floor(pos.Z)
			})
		end
	end

	local jsonContent = HttpService:JSONEncode({
		username = "Minimap Scanner",
		content = "```json\n" .. HttpService:JSONEncode(playerData) .. "\n```"
	})

	local success, response = pcall(function()
		return httpRequest({
			Url = webhookUrl,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = jsonContent
		})
	end)

	if success then
		print("Player locations sent.")
	else
		warn("Failed to send player locations:", response)
	end
end

-- Run every 5 seconds
while true do
	pcall(sendPlayerLocations)
	wait(5)
end
