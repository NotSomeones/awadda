-- Top10FruitsLocal.lua
-- Put this in StarterPlayerScripts as a LocalScript

-- 1) Base price per kg, per fruit type
local basePricePerKg = {
    carrot     = 10,
    strawberry = 25,
    blueberry  = 12,
    tomato     = 15,
    cauliflower= 20,
    watermelon = 30,
    greenapple = 8,
    avocado    = 18,
    banana     = 22,
    pumpkin    = 40,
    -- … fill in all your fruits …
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
