local addon, shared = ...

Ux = Ux or { }

function LoadUBData(a)
    if a == addon.identifier then
        UB_Settings = UB_Settings or {}
        if UB_Settings.inventory == nil then
            UB_Settings.inventory = { 
                x = UIParent:GetWidth() * 0.6, 
                y = UIParent:GetHeight() * 0.35,
            }
        end
        if UB_Settings.bank == nil then
            UB_Settings.bank = { 
                x = 10, 
                y = 10,
            }
        end
        for k,v in pairs(UB_Settings) do
            if type(v) == "table" then
                if v.x > UIParent:GetWidth() * 0.9 then
                    v.x = UIParent:GetWidth() * 0.6
                end
                if v.y > UIParent:GetHeight() * 0.65 then
                    v.y = UIParent:GetHeight() * 0.35
                end
            end
        end
    end
end

function SaveUBData(a)
    if a == addon.identifier then
        UB_Settings.inventory.x = Ux.inventory:GetLeft()
        UB_Settings.inventory.y = Ux.inventory:GetTop()
        UB_Settings.bank.x = Ux.bank:GetLeft()
        UB_Settings.bank.y = Ux.bank:GetTop()
    end
end

function RemoveEvent(event, handler)
    for i, value in ipairs(event) do
        if value == handler then
           table.remove(event, i)
        end
    end
end

local initialized = false
local initialization_enabled = false

function SystemUpdateBegin()
    if initialization_enabled then
        initialized = true
        initialization_enabled = false
        Ux.Init()
        RemoveEvent(Event.System.Update.Begin, SystemUpdateBeginHandler)
        print(addon.identifier .. " " .. addon.toc.Version .. " loaded")
    end
end

function UnitAvailabilityFull(t)
    if initialized then return end
    for k, v in pairs(t) do
        if v == "player" then
            Ux.playerInfo = Inspect.Unit.Detail("player")
            initialization_enabled = true
        end
    end
end

function Test(args)
    local args = split(args)
end

SystemUpdateBeginHandler = {SystemUpdateBegin, addon.identifier, "addon start"}
UnitAvailabilityFullHandler = {UnitAvailabilityFull, addon.identifier, "Availability Full" }

--table.insert(Command.Slash.Register("test"), {Test, addon.identifier, "test"})
table.insert(Event.Addon.SavedVariables.Load.End, {LoadUBData, addon.identifier, "load variables"})
table.insert(Event.Addon.SavedVariables.Save.Begin, {SaveUBData, addon.identifier, "save variable"})
table.insert(Event.Unit.Availability.Full, UnitAvailabilityFullHandler)
table.insert(Event.System.Update.Begin, SystemUpdateBeginHandler)