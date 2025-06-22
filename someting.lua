-- Top10FruitsWithHighlights.lua
-- LocalScript in StarterPlayerScripts

-- 1) Base prices (min Sheckles) per fruit type
local basePricePerKg = {
    ["carrot"] = 18, ["strawberry"] = 14, ["blueberry"] = 18,
    ["orange tulip"] = 767, ["tomato"] = 27, ["corn"] = 36,
    ["daffodil"] = 903, ["watermelon"] = 2708, ["pumpkin"] = 3700,
    ["apple"] = 248, ["bamboo"] = 3610, ["coconut"] = 361,
    ["cactus"] = 3068, ["dragon fruit"] = 4287, ["mango"] = 5866,
    ["grape"] = 7085, ["mushroom"] = 136278, ["pepper"] = 7220,
    ["cacao"] = 10830, ["beanstalk"] = 25270, ["ember lily"] = 50138,
    ["sugar apple"] = 43320, ["pear"] = 500, ["raspberry"] = 90,
    ["pineapple"] = 1805, ["peach"] = 271, ["papaya"] = 1000,
    ["banana"] = 1579, ["passionfruit"] = 3204, ["soul fruit"] = 6994,
    ["cursed fruit"] = 23239, ["rose"] = 4513, ["foxglove"] = 18050,
    ["lilac"] = 31588, ["pink lily"] = 58663, ["purple dahlia"] = 67688,
    ["sunflower"] = 144400, ["crocus"] = 27075, ["succulent"] = 22563,
    ["violet corn"] = 45125, ["bendboo"] = 139888, ["cocovine"] = 60166,
    ["dragon pepper"] = 80221, ["chocolate carrot"] = 9928,
    ["red lollipop"] = 45125, ["candy sunflower"] = 72200,
    ["easter egg"] = 2256, ["candy blossom"] = 90250,
    ["cranberry"] = 1805, ["durian"] = 4513, ["eggplant"] = 6769,
    ["venus fly trap"] = 76713, ["lotus"] = 31588, ["nightshade"] = 3159,
    ["glowshroom"] = 271, ["mint"] = 5415, ["moonflower"] = 8574,
    ["starfruit"] = 13538, ["moonglow"] = 22563, ["moon blossom"] = 50138,
    ["blood banana"] = 5415, ["moon melon"] = 16245, ["celestiberry"] = 9025,
    ["moon mango"] = 45125, ["lavender"] = 22563, ["nectarshade"] = 45125,
    ["nectarine"] = 43320, ["hive fruit"] = 55955, ["manuka flower"] = 22563,
    ["bee balm"] = 16245, ["dandelion"] = 45125, ["nectar thorn"] = 40111,
    ["lumira"] = 76713, ["honeysuckle"] = 90250, ["suncoil"] = 72200,
    ["lemon"] = 316, ["cherry blossom"] = 451
}

-- 2) Modifier values
local modifierValues = {
    shocked=100,frozen=10,wet=2,chilled=2,choc=2,moonlit=2,bloodlit=4,
    celestial=120,disco=125,zomb=25,plasma=5,voidtouched=135,
    pollinated=3,honeyglazed=5,dawnbound=150,heavenly=5,
    cooked=10,burnt=4,molten=25,meteoric=125,windstruck=2,
    alienlike=100,sundried=85,verdant=4,paradisal=18,twisted=5,galactic=120
}

local function getVariantMul(variant)
    if variant == "Rainbow" then return 50
    elseif variant == "Gold"    then return 20
    else return 1 end
end

local function getModifiersMul(fruit)
    local sum, count = 0, 0
    for modName, modVal in pairs(modifierValues) do
        if fruit:GetAttribute(modName) then
            sum   = sum + modVal
            count = count + 1
        end
    end
    return 1 + sum - count
end

local function computeFruitValue(fruit)
    -- Base price
    local base = basePricePerKg[fruit.Name:lower()]
    if not base then return 0 end

    -- Weight
    local wVal = fruit:FindFirstChild("Weight")
    if not (wVal and wVal:IsA("NumberValue")) then return 0 end
    local w = wVal.Value
    if w <= 0 then return 0 end

    -- Variant
    local variant = "Normal"
    local varObj = fruit:FindFirstChild("variant")
    if varObj and varObj:IsA("StringValue") then
        variant = varObj.Value
    end

    -- Friend boost (optional)
    local friendPct = (fruit:GetAttribute("FriendBoost") or 0) / 100

    -- Multipliers
    local vMul = getVariantMul(variant)
    local mMul = getModifiersMul(fruit)
    local fMul = 1 + friendPct

    -- Final value
    return base * vMul * mMul * fMul * w
end

local function printTop10Fruits()
    local farmsFolder = workspace:WaitForChild("Farm")
    for _, farm in ipairs(farmsFolder:GetChildren()) do
        -- Get owner
        local ownerVal = farm:FindFirstChild("Important")
            and farm.Important:FindFirstChild("Data")
            and farm.Important.Data:FindFirstChild("Owner")
        local ownerName = ownerVal and ownerVal.Value or "Unknown"
        warn(("🏡 Farm: %s  |  Owner: %s"):format(farm.Name, ownerName))

        -- Collect values
        local scored = {}
        local phys = farm.Important and farm.Important:FindFirstChild("Plants_Physical")
        if phys then
            for _, plantType in ipairs(phys:GetChildren()) do
                local fruitsFolder = plantType:FindFirstChild("Fruits")
                if fruitsFolder then
                    for _, fruit in ipairs(fruitsFolder:GetChildren()) do
                        local val = computeFruitValue(fruit)
                        if val > 0 then
                            table.insert(scored, { fruit = fruit, value = val })
                        end
                    end
                end
            end
        end

        -- Sort descending
        table.sort(scored, function(a,b) return a.value > b.value end)

        -- Show and highlight top 10
        for rank = 1, math.min(10, #scored) do
            local e = scored[rank]
            local name = e.fruit.Name
            local val  = e.value
            warn(("%2d. %s → $%.2f"):format(rank, name, val))

            -- Highlight the model
            local hl = Instance.new("Highlight")
            hl.Adornee = e.fruit
            hl.Parent  = e.fruit
            -- Color gradient from green (rank 1) to red (rank 10)
            local hue = (10 - (rank - 1)) / 10 * 0.33  -- 0.33 ≈ green; 0 ≈ red
            hl.FillColor = Color3.fromHSV(hue, 1, 1)
            hl.OutlineTransparency = 1  -- hide outline
        end

        if #scored == 0 then
            warn("   (no fruits found or none had valid weight)")
        end
    end
end

-- Run on load
printTop10Fruits()
