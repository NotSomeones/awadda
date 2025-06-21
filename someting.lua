local farms = game.Workspace.Farm
local playername = game.Players.LocalPlayer.Name

local function findfarm()
    for _, v in pairs(farms:GetChildren()) do
        if v.Important.Data.Owner.Value == playername then
            print("found it")
            return v
        end
    end
end

local myfarm = findfarm()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local seedshop = game.Players.LocalPlayer.PlayerGui.Seed_Shop

local newlist = {}

local function buyallstock()
    for _, v in pairs(seedshop.Frame.ScrollingFrame:GetChildren()) do
        local mainframe = v:FindFirstChild("Main_Frame")
        if not mainframe then continue end

        local stockTextObj = mainframe:FindFirstChild("Stock_Text")
        if not stockTextObj then continue end

        local seedname = v.Name
        local stockCount = tonumber(stockTextObj.Text:match("%d+"))
        if not stockCount or stockCount <= 0 then continue end

        for _ = 1, stockCount do
            ReplicatedStorage.GameEvents.BuySeedStock:FireServer(seedname)
        end
    end
end

while true do
    wait(10)
    buyallstock()
end
