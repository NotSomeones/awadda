-- Top10FruitsLocal.lua
-- Put this in StarterPlayerScripts as a LocalScript

-- 1) Base price per kg, per fruit type
local basePricePerKg = {
    ["carrot"] = 18,
    ["strawberry"] = 14,
    ["blueberry"] = 18,
    ["orange tulip"] = 767,
    ["tomato"] = 27,
    ["corn"] = 36,
    ["daffodil"] = 903,
    ["watermelon"] = 2708,
    ["pumpkin"] = 3700,
    ["apple"] = 248,
    ["bamboo"] = 3610,
    ["coconut"] = 361,
    ["cactus"] = 3068,
    ["dragon fruit"] = 4287,
    ["mango"] = 5866,
    ["grape"] = 7085,
    ["mushroom"] = 136278,
    ["pepper"] = 7220,
    ["cacao"] = 10830,
    ["beanstalk"] = 25270,
    ["ember lily"] = 50138,
    ["sugar apple"] = 43320,
    ["pear"] = 500,
    ["raspberry"] = 90,
    ["pineapple"] = 1805,
    ["peach"] = 271,
    ["papaya"] = 1000,
    ["banana"] = 1579,
    ["passionfruit"] = 3204,
    ["soul fruit"] = 6994,
    ["cursed fruit"] = 23239,
    ["rose"] = 4513,
    ["foxglove"] = 18050,
    ["lilac"] = 31588,
    ["pink lily"] = 58663,
    ["purple dahlia"] = 67688,
    ["sunflower"] = 144400,
    ["crocus"] = 27075,
    ["succulent"] = 22563,
    ["violet corn"] = 45125,
    ["bendboo"] = 139888,
    ["cocovine"] = 60166,
    ["dragon pepper"] = 80221,
    ["chocolate carrot"] = 9928,
    ["red lollipop"] = 45125,
    ["candy sunflower"] = 72200,
    ["easter egg"] = 2256,
    ["candy blossom"] = 90250,
    ["cranberry"] = 1805,
    ["durian"] = 4513,
    ["eggplant"] = 6769,
    ["venus fly trap"] = 76713,
    ["lotus"] = 31588,
    ["nightshade"] = 3159,
    ["glowshroom"] = 271,
    ["mint"] = 5415,
    ["moonflower"] = 8574,
    ["starfruit"] = 13538,
    ["moonglow"] = 22563,
    ["moon blossom"] = 50138,
    ["blood banana"] = 5415,
    ["moon melon"] = 16245,
    ["celestiberry"] = 9025,
    ["moon mango"] = 45125,
    ["lavender"] = 22563,
    ["nectarshade"] = 45125,
    ["nectarine"] = 43320,
    ["hive fruit"] = 55955,
    ["manuka flower"] = 22563,
    ["bee balm"] = 16245,
    ["dandelion"] = 45125,
    ["nectar thorn"] = 40111,
    ["lumira"] = 76713,
    ["honeysuckle"] = 90250,
    ["suncoil"] = 72200,
    ["lemon"] = 316,
    ["cherry blossom"] = 451
}


-- 2) Modifier values
local modifierValues = {
    shocked      = 100,  frozen     = 10,    wet        = 2,    chilled   = 2,
    choc         = 2,    moonlit    = 2,    bloodlit   = 4,    celestial = 120,
    disco        = 125,  zomb       = 25,   plasma     = 5,    voidtouched = 135,
    pollinated   = 3,    honeyglazed= 5,    dawnbound  = 150,  heavenly  = 5,
    cooked       = 10,   burnt      = 4,    molten     = 25,   meteoric  = 125,
    windstruck   = 2,    alienlike  = 100,  sundried   = 85,   verdant   = 4,
    paradisal    = 18,   twisted    = 5,    galactic   = 120,
}

-- Helper: fruit‐type multiplier from variant
local function getVariantMul(variant)
    if variant == "Rainbow" then
        return 50
    elseif variant == "Gold" then
        return 20
    else
        return 1
    end
end

-- Helper: combined modifier multiplier
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

-- Compute one fruit’s value
local function computeFruitValue(fruit)
    -- 1) Base
    local base = basePricePerKg[fruit.Name:lower()]
    if not base then return 0 end

    -- 2) Weight (NumberValue or Attribute)
    local w = fruit:GetAttribute("weight")
    if typeof(w) ~= "number" then
        local val = fruit:FindFirstChild("weight")
        if val and val:IsA("NumberValue") then
            w = val.Value
        end
    end
    if type(w) ~= "number" or w <= 0 then
        return 0
    end

    -- 3) Variant (StringValue)
    local variant = "Normal"
    local varObj = fruit:FindFirstChild("variant")
    if varObj and varObj:IsA("StringValue") then
        variant = varObj.Value
    end

    -- 4) Friend boost (if you use one—remove or adapt if not)
    local friendPct = fruit:GetAttribute("FriendBoost") or 0
    friendPct = friendPct / 100  -- slider was 0–5 for 0–500%

    -- 5) Multipliers
    local vMul    = getVariantMul(variant)
    local mMul    = getModifiersMul(fruit)
    local fMul    = 1 + friendPct

    -- 6) Final
    local perKg = base * vMul * mMul * fMul
    return perKg * w
end

-- Scan each farm and print top 10
local function printTop10Fruits()
    local farmsFolder = workspace:WaitForChild("Farm")
    for _, farm in ipairs(farmsFolder:GetChildren()) do
        local phys = farm:FindFirstChild("Important")
            and farm.Important:FindFirstChild("Plants_Physical")
        if not phys then continue end

        local scored = {}
        for _, plantType in ipairs(phys:GetChildren()) do
            local fruitsFolder = plantType:FindFirstChild("Fruits")
            if not fruitsFolder then continue end

            for _, fruit in ipairs(fruitsFolder:GetChildren()) do
                local value = computeFruitValue(fruit)
                if value > 0 then
                    table.insert(scored, { fruit = fruit, value = value })
                end
            end
        end

        table.sort(scored, function(a, b) return a.value > b.value end)

        warn(("── Top 10 fruits in farm %s ──"):format(farm.Name))
        for i = 1, math.min(10, #scored) do
            local e = scored[i]
            warn(("%2d. %s  ($%.2f)"):format(i, e.fruit:GetFullName(), e.value))
        end
        if #scored == 0 then
            warn("   (no fruits found or none had valid weight)")
        end
    end
end

-- Run on load
printTop10Fruits()
