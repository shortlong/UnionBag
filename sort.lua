
Ux = Ux or {}

local categoryOrder = {
    ["misc fishing misc"] = 91,
    ["armor plate chest"] = 90,
    ["armor plate legs"] = 89,
    ["armor plate feet"] = 88,
    ["armor plate hands"] = 87,
    ["armor plate head"] = 86,
    ["armor plate shoulders"] = 85,
    ["armor plate waist"] = 84,
    ["armor chain chest"] = 83,
    ["armor chain legs"] = 82,
    ["armor chain feet"] = 81,
    ["armor chain hands"] = 80,
    ["armor chain head"] = 79,
    ["armor chain shoulders"] = 78,
    ["armor chain waist"] = 77,
    ["armor leather chest"] = 76,
    ["armor leather legs"] = 75,
    ["armor leather feet"] = 74,
    ["armor leather hands"] = 73,
    ["armor leather head"] = 72,
    ["armor leather shoulders"] = 71,
    ["armor leather waist"] = 70,
    ["armor cloth chest"] = 69,
    ["armor cloth legs"] = 68,
    ["armor cloth feet"] = 67,
    ["armor cloth hands"] = 66,
    ["armor cloth head"] = 65,
    ["armor cloth shoulders"] = 64,
    ["armor cloth waist"] = 63,
    ["armor accessory neck"] = 62,
    ["armor accessory ring"] = 61,
    ["armor accessory trinket"] = 60,
    ["weapon onehand sword"] = 59,
    ["weapon onehand axe"] = 58,
    ["weapon onehand mace"] = 57,
    ["weapon onehand dagger"] = 56,
    ["weapon twohand sword"] = 55,
    ["weapon twohand axe"] = 54,
    ["weapon twohand mace"] = 53,
    ["weapon twohand polearm"] = 52,
    ["weapon twohand staff"] = 51,
    ["weapon ranged bow"] = 50,
    ["weapon ranged gun"] = 49,
    ["weapon ranged wand"] = 48,
    ["weapon totem"] = 47,
    ["weapon shield"] = 46,
    ["planar lesser"] = 45,
    ["planar greater"] = 44,
    ["consumable food"] = 43,
    ["consumable drink"] = 42,
    ["consumable potion"] = 41,
    ["consumable scroll"] = 40,
    ["consumable enchantment"] = 39,
    ["consumable"] = 38,
    ["container"] = 37,
    ["crafting recipe apothecary"] = 36,
    ["crafting recipe armorsmith"] = 35,
    ["crafting recipe artificer"] = 34,
    ["crafting recipe butchering"] = 33,
    ["crafting recipe foraging"] = 32,
    ["crafting recipe weaponsmith"] = 31,
    ["crafting recipe outfitter"] = 30,
    ["crafting recipe mining"] = 29,
    ["crafting recipe runecrafting"] = 28,
    ["crafting material metal"] = 27,
    ["crafting material gem"] = 26,
    ["crafting material wood"] = 25,
    ["crafting material plant"] = 24,
    ["crafting material hide"] = 23,
    ["crafting material meat"] = 22,
    ["crafting material cloth"] = 21,
    ["crafting material rune"] = 20,
    ["crafting ingredient reagent"] = 19,
    ["crafting ingredient drop"] = 18,
    ["crafting ingredient rift"] = 17,
    ["crafting augment"] = 16,
    ["misc quest"] = 15,
    ["misc mount"] = 14,
    ["misc pet"] = 13,
    ["misc collectable"] = 12,
    ["misc other"] = 11,
    ["misc"] = 10,
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
    return categoryOrder[category] or 0
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
        {a.value.id, b.value.id},
    }
    return Compare(compareParams, 1)
end

local function SortItems(items)
    local sorted = {}
    table.sort(items, sortByCategoryRarityName)
    for i, v in ipairs(items) do
        table.insert(sorted, v.id)
    end
    return sorted
end

local function GetItemAndSlotList(slotType)
    local items = {}
    local slots = {}
    for bagindex = 1, Ux.slotTypeMap[slotType].maxBags do
        local bag = GetItemDetail(Ux.slotTypeMap[slotType].getSlotid("bag", bagindex))
        if bag then
            for slotindex = 1, bag.slots do
                local slotid = Ux.slotTypeMap[slotType].getSlotid(bagindex, slotindex)
                table.insert(slots, slotid)
                item = GetItemDetail(slotid)
                if item then table.insert(items, {id = slotid, value = item}) end
            end
        end
    end
    return items, slots
end

local function CreateFlags(num)
	local flags = {}
	for i = 1, num do
		flags[i] = false
	end
	return flags
end

local function GetItemSlotMap(items, slots)
	local map = {}
	for i, v in ipairs(items) do
		table.insert(map, {src = v, dest = slots[i]})
	end
	return map
end

local function SearchInMap(map, flags, src, result)
	for i, v in ipairs(map) do
		if not flags[i] and v.src == src then
			table.insert(result, v.dest)
			flags[i] = true
			return SearchInMap(map, flags, v.dest, result)
		end
	end
end

local function TravelMap(map)
	local list = {}
	local flags = CreateFlags(#map)
	for i, v in ipairs(map) do
		if not flags[i] then
			flags[i] = true
			local temp = {v.src, v.dest,}
			SearchInMap(map, flags, v.dest, temp)
			if temp[1] == temp[#temp] then temp[#temp] = nil end
			table.insert(list, temp)
		end
	end
	return list
end

local function GetMoveList(items, slots)
    return TravelMap(GetItemSlotMap(items, slots))
end

local function MoveItems(movelist)
    for _, v in ipairs(movelist) do
        --Dump(v)
        for i = #v, 2, -1 do
            Command.Item.Move(v[i - 1], v[i])
        end
    end
end

function Sort(slotType)
    local items, slots = GetItemAndSlotList(slotType)
    MoveItems(GetMoveList(SortItems(items), slots))
end