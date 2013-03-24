local addon, shared = ...

Ux = Ux or {}
Ux.SortButton = Ux.SortButton or { }

‍require("socket")

function sleep(n)
   socket.select(nil, nil, n)
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

local function UpdateItemSlot(items, start, oldslot, newslot)
    for i = start, #items do
        if items[i] == oldslot then
            items[i] = newslot
            return
        end
    end
end

local function MoveItems(items, slots)
    for i = 1, #items do
        local updateNeeded = false
        if items[i] ~= slots[i] then
            print(items[i] .. " to " .. slots[i])
            if GetItemDetail(slots[i]) ~= nil then updateNeeded = true end
            Command.Item.Move(items[i], slots[i])
            if updateNeeded then UpdateItemSlot(items, i + 1, slots[i], items[i]) end
            sleep(500)
        end
    end
end

function Ux.SortButton.New(slotType, parent)
    local button = UI.CreateFrame("Texture", "sort button", parent)
    button:SetTexture(addon.identifier, "textures/icon_menu_sort.png")
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, 16)
    button:SetWidth(40)
    button:SetHeight(40)
    
    function button.Event:MouseIn()
        button:SetTexture(addon.identifier, "textures/icon_menu_sort_enable.png")
    end
    function button.Event:MouseOut()
        button:SetTexture(addon.identifier, "textures/icon_menu_sort.png")
    end
    function button.Event:LeftClick()
        local items, slots = GetItemAndSlotList(slotType)
        MoveItems(Sort(items), slots)
    end
end