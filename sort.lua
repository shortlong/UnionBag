
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
        {UB.getCategoryOrder(b.value.category), UB.getCategoryOrder(a.value.category)},
        {UB.getRarityOrder(b.value.rarity), UB.getRarityOrder(a.value.rarity)},
        {a.value.name, b.value.name},
        {a.value.stack or 1, b.value.stack or 1},
        {a.value.id, b.value.id},
    }
    return Compare(compareParams, 1)
end

local function SortItems(items)
    local sorted = {}
    table.sort(items.normal, sortByCategoryRarityName)
    table.sort(items.sellable, sortByCategoryRarityName)
    for i, v in ipairs(items.normal) do
        table.insert(sorted, v.id)
    end
    for i, v in ipairs(items.sellable) do
        table.insert(sorted, v.id)
    end
    return sorted
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

local function preSort(items)
    local result = {}
    result.sellable = {}
    result.normal = {}
    for i, v in ipairs(items) do
        if v.value.rarity == "sellable" then
            table.insert(result.sellable, {id = v.id, value = v.value})
        else
            table.insert(result.normal, {id = v.id, value = v.value})
        end
    end
    return result
end

function Sort(items, slots)
    return GetMoveList(SortItems(preSort(items)), slots)
end