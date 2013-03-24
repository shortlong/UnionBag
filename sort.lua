
local categoryOrder = {
    armor = 7,
    weapon = 6,
    planar = 5,
    consumable = 4,
    container = 3,
    crafting = 2,
    misc = 1,
}

local rarityOrder = {
	sellable = 1,
	common = 2,
	uncommon = 3,
	rare = 4,
	epic = 5,
	relic = 6,
	transcendant = 7,
	quest = 8,
}

local function GetCategoryOrder(category)
    return categoryOrder[split(category)[1]] or 0
end

local function GetRarityOrder(rarity)
    return rarityOrder[rarity or "common"]
end

local function Compare(params, index)
    if params[index] == nil then return false end
    if params[index][1] > params[index][2] then 
        return true
    elseif params[index][1] < params[index][2] then 
        return false
    else 
        return Compare(params, index + 1)
    end
end

local function sortByCategoryRarityName(a, b)
    local compareParams = {
        {GetCategoryOrder(a.value.category), GetCategoryOrder(b.value.category)},
        {GetRarityOrder(a.value.rarity), GetRarityOrder(b.value.rarity)},
        {a.value.name, b.value.name},
        {a.value.stack or 1, b.value.stack or 1},
    }
    return Compare(compareParams, 1)
end

function Sort(items)
    local sorted = {}
    table.sort(items, sortByCategoryRarityName)
    for i, v in ipairs(items) do
        table.insert(sorted, v.id)
    end
    return sorted
end