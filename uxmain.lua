local addon, shared = ...

Ux = Ux or { }

Ux.Context = UI.CreateContext(addon.identifier)

function Ux.OnItemUpdate(updates)
    for k in pairs(updates) do
        local slottype = Utility.Item.Slot.Parse(k)
        if slottype == "inventory" then
            Ux.Inventory:OnItemUpdate(k)
        end
    end
end

function Ux.OnItemSlot(updates)
    for id, v in pairs(updates) do
        local slottype, param = Utility.Item.Slot.Parse(id)
        if slottype == "inventory" and tostring(param) ~= "bag" then
            Ux.Inventory:OnItemSlot(id, v)
        end
    end
    Ux.Inventory:Update()
end

----------- Public ------------
function Ux.Init()
    Ux.Inventory = Ux.ItemWindow.New("inventory", Ux.Context, GetPlayerName() .. "的背包")
    Ux.Inventory:SetSize(UB_Settings.width, UB_Settings.height)
    Ux.Inventory:SetPoint(UB_Settings.x, UB_Settings.y)
    Ux.Inventory:Update()
    
    Ux.Tooltip.Init()
end

function Ux.Toggle()
    Ux.Inventory:Toggle()
    Ux.Tooltip.Hide()
end