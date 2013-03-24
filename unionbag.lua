local addon, shared = ...

Ux = Ux or { }

function ToggleWindow()
    Ux.Toggle()
end

function LoadUBData(a)
    if a == addon.identifier then
        if UB_Settings == nil then
            UB_Settings = {}
            UB_Settings.x = 400
            UB_Settings.y = 300
            UB_Settings.width = 500
            UB_Settings.height = 500
            UB_Settings.slots_per_line = 10
        end
        if UB_Settings.x > UIParent:GetWidth() * 0.9 then 
            UB_Settings.x = UIParent:GetWidth() * 0.55
        end
        if UB_Settings.y > UIParent:GetHeight() * 0.9 then 
            UB_Settings.y = UIParent:GetHeight() * 0.35
        end
    end
end

function AddItemEvent()
    table.insert(Event.Item.Update, {Ux.OnItemUpdate, addon.identifier, "item update"})
    table.insert(Event.Item.Slot, {Ux.OnItemSlot, addon.identifier, "item slot change"})
end

local initialized = false
local initialization_enabled = false

function SystemUpdateBegin()
    if initialization_enabled then
        initialized = true
        initialization_enabled = false
        Ux.Init()
        AddItemEvent()
        print(addon.identifier .. " loaded")
    end
end

function UnitAvailabilityFull(t)
    if initialized then return end
    for k, v in pairs(t) do
        if v == "player" then
            initialization_enabled = true
        end
    end
end

function Test()
    print(Utility.Item.Slot.Inventory())
    for k, v in pairs(GetItemDetail(GetItemDetail("si"))) do
        print(k .. " " .. v.name)
    end
end

table.insert(Command.Slash.Register("unionbag"), {ToggleWindow, addon.identifier, "Toggle Main Window"})
table.insert(Command.Slash.Register("test"), {Test, addon.identifier, "test"})
table.insert(Event.System.Update.Begin, {SystemUpdateBegin, addon.identifier, "addon start"})
table.insert(Event.Addon.SavedVariables.Load.End, {LoadUBData, addon.identifier, "load variables"})
table.insert(Event.Unit.Availability.Full, {UnitAvailabilityFull, addon.identifier, "Availability Full" })
