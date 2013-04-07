local addon, shared = ...

Ux = Ux or { }

local nativeBank = {
    UI.Native.Bank,
    UI.Native.BagBank1,
    UI.Native.BagBank2,
    UI.Native.BagBank3,
    UI.Native.BagBank4,
    UI.Native.BagBank5,
    UI.Native.BagBank6,
    UI.Native.BagBank7,
    UI.Native.BagBank8,
}

local nativeInventory = {
    UI.Native.BagInventory1,
    UI.Native.BagInventory2,
    UI.Native.BagInventory3,
    UI.Native.BagInventory4,
    UI.Native.BagInventory5,
}

for i = 1, #nativeBank do
    nativeBank[i]:SetStrata("notify")
end

for i = 1, #nativeInventory do
    nativeInventory[i]:SetStrata("notify")
    nativeInventory[i].Event.Loaded = function(self)
        Ux.OnInventoryLoaded(i, nativeInventory[i]:GetLoaded())
    end
end

local function getBagCount()
    local count = 0
    for i = 1, 5 do
        local bag = GetItemDetail(Utility.Item.Slot.Inventory("bag", i))
        if bag then count = count + 1 end
    end
    return count
end

local invShowCount = 0

function Ux.OnInventoryLoaded(index, state)
    if state then 
        invShowCount = invShowCount + 1
    else
        invShowCount = invShowCount - 1
    end
    if invShowCount == getBagCount() then
        Ux.inventory:Show()
    elseif invShowCount == 0 then
        Ux.inventory:Hide()
    end
end

function Ux.OnInteraction(interaction, state)
    if interaction == "bank" then
        if state then
            Ux.bank:Show()
            Ux.bank:Online()
            Ux.bank:SetTitle("银行")
        else
            Ux.bank:Hide()
            Ux.bank:Offline()
            Ux.bank:SetTitle("银行(离线)")
        end
    end
end

function Ux.OnItemUpdate(updates)
    for k in pairs(updates) do
        local bagtype = Utility.Item.Slot.Parse(k)
        if Ux[bagtype] then
            Ux[bagtype]:OnItemUpdate(k)
        end
    end
end

function Ux.OnItemSlot(updates)
    for id, v in pairs(updates) do
        local bagtype, param = Utility.Item.Slot.Parse(id)
        if Ux[bagtype] then
            Ux[bagtype]:OnItemSlot(id, v)
        end
    end
    Ux.inventory:Update()
    Ux.bank:Update()
end

local function addEvent()
    table.insert(Event.Item.Update, {Ux.OnItemUpdate, addon.identifier, "OnItemUpdate"})
    table.insert(Event.Item.Slot, {Ux.OnItemSlot, addon.identifier, "OnItemSlot"})
    table.insert(Event.Interaction, {Ux.OnInteraction, addon.identifier, "OnInteraction"})
end

function Ux.Init()
    Ux.inventory = Ux.ItemWindow.New("inventory")
    Ux.inventory:SetTitle(GetPlayerName() .. "的背包")
    Ux.inventory:SetPoint(UB_Settings.inventory.x, UB_Settings.inventory.y)
    Ux.inventory:Update()
    
    Ux.bank = Ux.ItemWindow.New("bank")
    Ux.bank:SetTitle("银行(离线)")
    Ux.bank:SetPoint(UB_Settings.bank.x, UB_Settings.bank.y)
    Ux.bank:Update()
    Ux.bank:Offline()
    
    function Ux.inventory.title.Event:RightClick()
        Ux.bank:Show()
    end
    function Ux.inventory.title.Event:MouseIn()
        self:SetText("右击显示离线银行")
    end
    function Ux.inventory.title.Event:MouseOut()
        self:SetText(GetPlayerName() .. "的背包")
    end
    
    addEvent()
end
