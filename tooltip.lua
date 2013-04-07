local addon, shared = ...

Ux = Ux or { }
Ux.Tooltip = { }

----------- Private -----------

local function getItemCount(items, type, name)
    local count = 0
    for _, item in pairs(items) do
        if (item.type == type) and (item.name == name) then 
            count = count + (item.stack or 1)
        end
    end
    return count
end

local function getItemCountText(item)
    local total, inventory, bank = 0, 0, 0
    inventory = getItemCount(GetItemDetail(Utility.Item.Slot.Inventory()), item.type, item.name)
    bank = getItemCount(GetItemDetail(Utility.Item.Slot.Bank()), item.type, item.name)
    total = inventory + bank
    return string.format("%d (背包 %d, 银行 %d)", total, inventory, bank)
end

local function addExtraItemInfo(item)
    ItemTooltip.AddDoubleText(Ux.playerInfo.name, getItemCountText(item),
        {r = 0.41, g = 0.35, b = 0.80}, {r = 0.41, g = 0.35, b = 0.80})
    if item.stackMax then 
        ItemTooltip.AddText(string.format(UB.translate("stackMax"), item.stackMax))
    end
end

----------- Pubic -------------
function Ux.Tooltip.Show(item, target)
    ItemTooltip.Hide()
    ItemTooltip.ClearLines()
    ItemTooltip.SetItem(item)
    addExtraItemInfo(item)
    ItemTooltip.Show(target)
end

function Ux.Tooltip.Hide()
    ItemTooltip.Hide()
end
