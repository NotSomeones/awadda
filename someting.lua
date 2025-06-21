local farms = game.workspace.Farm
local playername = game.Players.LocalPlayer.Name
local function findfarm()
    for i, v in pairs(farms:GetChildren()) do
        if v.Important.Data.Owner.Value == playername then
            print("found it")
        end
    end
end

findfarm()
