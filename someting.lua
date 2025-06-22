-- Top10FruitsWithFormattedValues.lua
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
    shocked=100, frozen=10, wet=2, chilled=2, choc=2, moonlit=2, bloodlit=4,
    celestial=120, disco=125, zomb=25, plasma=5, voidtouched=135,
    pollinated=3, honeyglazed=5, dawnbound=150, heavenly=5,
    cooked=10, burnt=4, molten=25, meteoric=125, windstruck=2,
    alienlike=100, sundried=85, verdant=4, paradisal=18, twisted=5, galactic=120
}

-- Helper: color gradient for ranks
local function getColorForRank(rank)
    local hue = (1 - (rank - 1) / 9) * 0.33 -- from green (0.33) down to red (0)
    return Color3.fromHSV(hue, 1, 1)
end

-- Formats numbers into "thousand", "million", etc.
local function formatValue(n)
    local absn = math.abs(n)
    if absn >= 1e12 then return string.format("%.2f trillion", n/1e12)
    elseif absn >= 1e9 then return string.format("%.2f billion", n/1e9)
    elseif absn >= 1e6 then return string.format("%.2f million", n/1e6)
    elseif absn >= 1e3 then return string.format("%.2f thousand", n/1e3)
    else return string.format("%.0f", n)
    end
end

-- Returns fruit-type multiplier
local function getVariantMul(variant)
    if variant == "Rainbow" then return 50 elseif variant == "Gold" then return 20 else return 1 end
end

-- Returns combined modifiers multiplier
local function getModifiersMul(fruit)
    local sum, count = 0, 0
    for modName, modVal in pairs(modifierValues) do
        if fruit:GetAttribute(modName) then sum += modVal; count += 1 end
    end
    return 1 + sum - count
end

-- Computes value and breakdown
local function computeFruitValue(fruit)
    local base = basePricePerKg[fruit.Name:lower()] or 0
    -- weight
    local wObj = fruit:FindFirstChild("Weight")
    local weight = (wObj and wObj:IsA("NumberValue") and wObj.Value) or 0
    if weight <= 0 then return 0, base, 1, 1, weight end
    -- variant
    local variant = fruit:FindFirstChild("variant")
    variant = (variant and variant:IsA("StringValue") and variant.Value) or "Normal"
    local variantMul = getVariantMul(variant)
    -- modifiers
    local modMul = getModifiersMul(fruit)
    -- friend boost
    local friendMul = 1 + ((fruit:GetAttribute("FriendBoost") or 0) / 100)
    -- total multiplier
    local totalMul = variantMul * modMul * friendMul
    local total = base * totalMul * weight
    return total, base, variantMul, modMul, friendMul, weight
end

-- Prints and highlights top 10 with full breakdown
local function printTop10Fruits()
    for _, farm in pairs(workspace.Farm:GetChildren()) do
        local owner = farm.Important.Data.Owner.Value
        warn("🏡 Farm: "..farm.Name.." | Owner: "..owner)
        local list = {}
        if farm.Important and farm.Important.Plants_Physical then
            for _, pt in pairs(farm.Important.Plants_Physical:GetChildren()) do
                local fruits = pt:FindFirstChild("Fruits")
                if fruits then
                    for _, fruit in pairs(fruits:GetChildren()) do
                        local total, base, vM, mM, fM, w = computeFruitValue(fruit)
                        if total > 0 then list[#list+1] = {f=fruit,t=total,b=base,v=vM,m=mM,fm=fM,w=w} end
                    end
                end
            end
        end
        table.sort(list, function(a,b) return a.t>b.t end)
        for i=1,math.min(10,#list) do
            local e=list[i]
            warn(string.format("%2d. %s → %s Sheckles", i, e.f.Name, formatValue(e.t)))
            warn(string.format("  Formula: %d × %d × %d × %.2f × %d = %s", e.b, e.v, e.m, e.fm, e.w, formatValue(e.t)))
            local hl=Instance.new("Highlight") hl.Adornee=e.f hl.Parent=e.f hl.FillColor=getColorForRank(i) hl.OutlineTransparency=1
        end
    end
end

printTop10Fruits()
