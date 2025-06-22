local webhookUrl = "https://discord.com/api/webhooks/1386476429943767222/qm5OAtBczNaxk7TUSuGvmtLShd3l3Nj8mvEhKTltb3zNHXSk77Lmr8W91lpNewhBstXo"

local httpRequest = http_request or request or syn.request

local function isPlayerInGroup(player)
	local success, result = pcall(function()
		return player:IsInGroup(groupId)
	end)
	if not success then
		warn("Failed to check group membership for player: " .. player.Name)
		return false
	end
	return result
end

local function getAvatarUrl(userId)
	local apiUrl = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. userId .. "&size=420x420&format=Png"
	local success, response = pcall(function()
		return httpRequest({Url = apiUrl, Method = "GET", Headers = { ["Content-Type"] = "application/json" }})
	end)

	if success and response.Body then
		local json = game:GetService("HttpService"):JSONDecode(response.Body)
		if json and json.data and json.data[1] and json.data[1].imageUrl then
			return json.data[1].imageUrl
		end
	end

	return "https://tr.rbxcdn.com/default-avatar.png" 
end

local function sendToDiscord(player, action)
	local avatarUrl = getAvatarUrl(player.UserId)

	local embed = {
		["title"] = (action == "joined") and ":police_officer: Moderator Alert" or ":door: Moderator Left",
		["description"] = (action == "joined") and "**A moderator has joined the game!**" or "**A moderator has left the game!**",
		["color"] = (action == "joined") and 16711680 or 16776960, -- Red for join, Yellow for leave
		["fields"] = {
			{["name"] = ":bust_in_silhouette: Username", ["value"] = player.Name, ["inline"] = true},
			{["name"] = ":id: User ID", ["value"] = tostring(player.UserId), ["inline"] = true}
		},
		["thumbnail"] = { ["url"] = avatarUrl },
		["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
	}

	local data = { ["username"] = "Faggot Alert", ["embeds"] = { embed } }
	local jsonData = game:GetService("HttpService"):JSONEncode(data)

	local success, response = pcall(function()
		return httpRequest({
			Url = webhookUrl,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = jsonData
		})
	end)

	if success then
		print("Embed sent to Discord for player:", player.Name, "Action:", action)
	else
		warn("Failed to send embed to Discord: " .. tostring(response))
	end
end
