local addon, shared = ...

local INV_MAX_SLOTS_PER_LINE = 15
local INV_MIN_SLOTS_PER_LINE = 8
local INV_MAX_BAGS = 5

local ub_ui = { 
    context = UI.CreateContext(addon.identifier),
    tooltipCount = 0,
}

Ux = Ux or { }

local rarityTexture = {
    common =		"icon_border.dds",
	epic =			"icon_border_epic.dds",
	quest =			"icon_border_quest.dds",
	rare =			"icon_border_rare.dds",
	relic =			"icon_border_relic.dds",
	sellable =		"icon_border_disabled.dds",
	transcendant =	"icon_border_relic.dds",
	uncommon =		"icon_border_uncommon.dds",
}

function GetPlayerName()
    return Inspect.Unit.Detail("player").name
end

function GetItemDetail(var)
    return Inspect.Item.Detail(var)
end

function ScaleInventory(scale)
    local width = ub_ui.inventory:GetWidth() * scale
    local height = ub_ui.inventory:GetHeight() * scale
    ub_ui.inventory:SetWidth(width)
    ub_ui.inventory:SetHeight(height)
    UB_Settings.width = width
    UB_Settings.heigth = heigth
end

function CreateInventory()
    ub_ui.inventory = UI.CreateFrame("RiftWindow", "ub_ui.inventory", ub_ui.context)
    ub_ui.inventory:SetVisible(false)
    ub_ui.inventory:SetTitle(GetPlayerName() .. "的背包")
    ub_ui.inventory:SetWidth(UB_Settings.width)
    ub_ui.inventory:SetHeight(UB_Settings.height)
    ub_ui.inventory:SetPoint("TOPLEFT", UIParent, "TOPLEFT", UB_Settings.x, UB_Settings.y)
    ub_ui.visible = false
end

function AddInventoryEvent()
    function ub_ui.inventory.Event:KeyDown(button)
        print(button .. " down")
    end
    function ub_ui.inventory.Event:KeyUp(button)
        print(button .. " up")
    end
    --function ub_ui.inventory.Event:WheelForward()
    --    ScaleInventory(0.97)
    --end
    --function ub_ui.inventory.Event:WheelBack()
    --    ScaleInventory(1.03)
    --end
    local windowborder = ub_ui.inventory:GetBorder()
    function windowborder.Event:LeftDown()
        self.MouseDown = true
        local mousepoint = Inspect.Mouse()
        self.xInWindow = mousepoint.x - ub_ui.inventory:GetLeft()
        self.yInWindow = mousepoint.y - ub_ui.inventory:GetTop()
    end
    function windowborder.Event:LeftUp()
        self.MouseDown = false
        UB_Settings.x = ub_ui.inventory:GetLeft()
        UB_Settings.y = ub_ui.inventory:GetTop()
    end
    function windowborder.Event:MouseMove()
        if self.MouseDown then
            local dx, dy
            local mousepoint = Inspect.Mouse()
            dx = mousepoint.x - self.xInWindow
            dy = mousepoint.y - self.yInWindow
            ub_ui.inventory:SetPoint("TOPLEFT", UIParent, "TOPLEFT", dx, dy)
        end
    end
end

function AddCloseButtonForInventory()
    ub_ui.closebutton = UI.CreateFrame("RiftButton", "ub_ui.closebutton", ub_ui.inventory)
    ub_ui.closebutton:SetSkin("close")
    ub_ui.closebutton:SetPoint("TOPRIGHT", ub_ui.inventory, "TOPRIGHT", -8, 16)
    function ub_ui.closebutton.Event:LeftClick()
        ub_ui.visible = not ub_ui.visible
        ub_ui.inventory:SetVisible(ub_ui.visible)
    end
end

function AddSearchboxForInventory()
    local windowcontent = ub_ui.inventory:GetContent()
    ub_ui.searchbox = UI.CreateFrame("RiftTextfield", "ub_ui.searchbox", windowcontent)
    ub_ui.searchbox:SetPoint("TOPLEFT", windowcontent, "TOPLEFT", 10, 10)
    ub_ui.searchbox:SetText("搜索")
    ub_ui.searchbox:SetBackgroundColor(0.5, 0.5, 0.5)
end

function AddSortButtonForInventory()
    local windowcontent = ub_ui.inventory:GetContent()
    ub_ui.sortbutton = UI.CreateFrame("RiftButton", "ub_ui.sortbutton", windowcontent)
    ub_ui.sortbutton:SetSkin("default")
    ub_ui.sortbutton:SetPoint("BOTTOMRIGHT", windowcontent, "BOTTOMRIGHT", -10, -10)
    ub_ui.sortbutton:SetText("整理")
end

function CreateSlot(slotid, pframe)
    local slot = { visible = true, }
    slot.frame = UI.CreateFrame("Texture", "slot_frame", pframe)
    slot.frame:SetTexture("Rift", "icon_empty.png.dds")

    slot.icon = UI.CreateFrame("Texture", "slot_icon", slot.frame)
    slot.icon:SetPoint("CENTER", slot.frame, "CENTER", 0, 0)
    slot.icon:SetLayer(1)

    slot.highlight = UI.CreateFrame("Texture", "slot_highlight", slot.frame)
    slot.highlight:SetVisible(false)
    slot.highlight:SetLayer(2)
    slot.highlight:SetPoint("CENTER", slot.frame, "CENTER", 0, 0)
    slot.highlight:SetTexture(addon.identifier, "textures/highlight.png")

    slot.border = UI.CreateFrame("Texture", "slot_border", slot.frame)
    slot.border:SetPoint("CENTER", slot.frame, "CENTER", 0, 0)
    slot.border:SetLayer(3)

    slot.text = UI.CreateFrame("Text", "slot_text", slot.frame)
    slot.text:SetLayer(4)
    slot.text:SetFontSize(16)
    slot.text:SetPoint("BOTTOMRIGHT", slot.frame, "BOTTOMRIGHT", -8, -2)

    function slot.frame.Event:MouseIn()
        local item = GetItemDetail(slotid)
        if item then
            slot.highlight:SetVisible(true)
            Dump(item)
            Command.Tooltip(item.id)
            Ux.Tooltip.Show(slotid, self)
        elseif Inspect.Cursor() == "item" then
            slot.highlight:SetVisible(true)
        end
    end
    function slot.frame.Event:MouseOut()
        slot.highlight:SetVisible(false)
        if GetItemDetail(slotid) then
            Command.Tooltip(nil)
            Ux.Tooltip.Hide(slotid)
        end
    end
    function slot.frame.Event:RightClick()
        Command.Item.Standard.Right(slotid)
    end
    function slot.frame.Event:LeftDown()
        Command.Item.Standard.Drag(slotid)
    end
    function slot.frame.Event:LeftUp()
        Command.Item.Standard.Drop(slotid)
    end
    return slot
end

function CreateInventorySlots()
    local windowcontent = ub_ui.inventory:GetContent()
    ub_ui.inventoryslots = {}
    for bagindex = 1, INV_MAX_BAGS do
        local bag = GetItemDetail(Utility.Item.Slot.Inventory("bag", bagindex))
        if bag ~= nil then
            for slotindex = 1, bag.slots do
                local slotid = Utility.Item.Slot.Inventory(bagindex, slotindex)
                ub_ui.inventoryslots[slotid] = CreateSlot(slotid, windowcontent)
            end
        end
    end
end

function ArrangeInventorySlots()
    local row = 1
    local firstSlotOfLastLine = nil
    local lastSlotInLine = nil

    for id, slot in pairsByKeys(ub_ui.inventoryslots) do
        slot.frame:SetVisible(slot.visible)
        if slot.visible then
            if row == 1 and firstSlotOfLastLine == nil then 
                slot.frame:SetPoint("TOPLEFT", ub_ui.inventory:GetContent(), "TOPLEFT", 0, 0)
                firstSlotOfLastLine = slot
            elseif row == 1 and firstSlotOfLastLine ~= nil then
                slot.frame:SetPoint("TOPLEFT", firstSlotOfLastLine.frame, "BOTTOMLEFT", 0, -11)
                firstSlotOfLastLine = slot
            else
                slot.frame:SetPoint("TOPLEFT", lastSlotInLine.frame, "TOPRIGHT", -11, 0)
            end
            lastSlotInLine = slot

            row = row + 1
            if row > UB_Settings.inv_slots_per_line then 
                row = 1
            end
        end
    end
end

function UpdateSlotItem(slot, item)
    slot.icon:SetTexture("Rift", item.icon)
    slot.icon:SetVisible(true)

    slot.border:SetTexture("Rift", rarityTexture[item.rarity or "common"])
    slot.border:SetVisible(true)

    if item.stack and item.stack ~= 1 then
        slot.text:SetText("" .. item.stack)
        slot.text:SetVisible(true)
    else
        slot.text:SetVisible(false)
    end
end

function EmptySlotItem(slot)
    slot.icon:SetVisible(false)
    slot.border:SetVisible(false)
    slot.text:SetVisible(false)
    slot.highlight:SetVisible(false)
end

function ScanInventory()
    for i = 1, INV_MAX_BAGS do
        items = GetItemDetail(Utility.Item.Slot.Inventory(i))
        for slot, item in pairs(items) do
            UpdateSlotItem(ub_ui.inventoryslots[slot], item)
        end
    end
end

function GetSlotsRectRightAndBottom(slots)
    local right, bottom
    local count = 1

    for id, slot in pairsByKeys(slots) do
        if slot.visible then
            if count == UB_Settings.inv_slots_per_line then
                right = slot.frame:GetRight()
            else
                bottom = slot.frame:GetBottom()
            end
            count = count + 1
        end
    end
    return right, bottom
end

function GetFrameRightAndBottom(frame)
    local right, bottom
    right = frame:GetRight()
    bottom = frame:GetBottom()
    return right, bottom
end

function AdjustInventorySize()
    local slotsRight, slotsBottom
    local contentRight, contentBottom
    slotsRight, slotsBottom = GetSlotsRectRightAndBottom(ub_ui.inventoryslots)
    contentRight, contentBottom = GetFrameRightAndBottom(ub_ui.inventory:GetContent())

    local invWidth = ub_ui.inventory:GetWidth()
    local invHeight = ub_ui.inventory:GetHeight()
    invWidth = invWidth + slotsRight - contentRight
    invHeight = invHeight + slotsBottom - contentBottom
    if invHeight < 480 then invHeight = 480 end
    ub_ui.inventory:SetWidth(invWidth)
    ub_ui.inventory:SetHeight(invHeight)
end

function BuildInventoryElements()
    CreateInventorySlots()
    ArrangeInventorySlots()
    ScanInventory()
    AdjustInventorySize()
end

function BuildUI()
    CreateInventory()
    AddInventoryEvent()
    AddCloseButtonForInventory()
end

function ToggleWindow()
    ub_ui.visible = not ub_ui.visible
    ub_ui.inventory:SetVisible(ub_ui.visible)
    Ux.Tooltip.Hide()
end

function LoadUBData(a)
    if a == addon.identifier then
        if UB_Settings == nil then
            UB_Settings = {}
            UB_Settings.x = 400
            UB_Settings.y = 300
            UB_Settings.width = 500
            UB_Settings.height = 500
            UB_Settings.inv_slots_per_line = 10
        end
        if UB_Settings.x > UIParent:GetWidth() * 0.9 then 
            UB_Settings.x = UIParent:GetWidth() * 0.55
        end
        if UB_Settings.y > UIParent:GetHeight() * 0.9 then 
            UB_Settings.y = UIParent:GetHeight() * 0.35
        end
    end
end

function OnItemUpdate(updates)
    for k in pairs(updates) do
        local slottype = Utility.Item.Slot.Parse(k)
        if slottype == "inventory" then
            UpdateSlotItem(ub_ui.inventoryslots[k], GetItemDetail(k))
        end
    end
end

function CreateSlotIfNotExists(slotid, pframe)
    if ub_ui.inventoryslots[slotid] == nil then 
        print("create slot " .. slotid)
        ub_ui.inventoryslots[slotid] = CreateSlot(id, pframe)
    end
end

function UpdateUI()
    ArrangeInventorySlots()
    AdjustInventorySize()
end

function OnItemSlot(updates)
    local need_to_update_ui = false
    for id, v in pairs(updates) do
        local slottype, param = Utility.Item.Slot.Parse(id)
        if slottype == "inventory" and tostring(param) ~= "bag" then
            if ub_ui.inventoryslots[id] == nil then 
                ub_ui.inventoryslots[id] = CreateSlot(id, ub_ui.inventory:GetContent())
                need_to_update_ui = true
            end

            if type(v) == "boolean" and not v then 
                EmptySlotItem(ub_ui.inventoryslots[id])
            elseif v == "nil" then
                ub_ui.inventoryslots[id].visible = false
                need_to_update_ui = true
            else
                UpdateSlotItem(ub_ui.inventoryslots[id], GetItemDetail(id))
            end
        end
    end
    if need_to_update_ui then UpdateUI() end
end

local NEED_TO_BUILD_UI = true
local NEED_TO_SCAN_INV = true
local INV_SCANED = false

function AddItemEvent()
    table.insert(Event.Item.Update, {OnItemUpdate, addon.identifier, "item update"})
    table.insert(Event.Item.Slot, {OnItemSlot, addon.identifier, "item slot change"})
end

function SystemUpdateBegin()
    if NEED_TO_BUILD_UI then
        NEED_TO_BUILD_UI = false
        BuildUI()
        Ux.Tooltip.Init()
    elseif NEED_TO_SCAN_INV then
        NEED_TO_SCAN_INV = false
        INV_SCANED = true
        BuildInventoryElements()
        AddItemEvent()
    end
end

function UnitAvailabilityFull(t)
    if INV_SCANED then return end
    for k, v in pairs(t) do
        if v == "player" then 
            NEED_TO_SCAN_INV = true
        end
    end
end

function Test()
    --Dump(GetItemDetail(GetItemDetail("si01.001").id))
    --Ux.Tooltip.Init()
end

print(addon.identifier .. " loaded")

table.insert(Command.Slash.Register("unionbag"), {ToggleWindow, addon.identifier, "Toggle Main Window"})
table.insert(Command.Slash.Register("test"), {Test, addon.identifier, "test"})
table.insert(Event.System.Update.Begin, {SystemUpdateBegin, addon.identifier, "addon start"})
table.insert(Event.Addon.SavedVariables.Load.End, {LoadUBData, addon.identifier, "load variables"})
table.insert(Event.Unit.Availability.Full, {UnitAvailabilityFull, addon.identifier, "Availability Full" })
