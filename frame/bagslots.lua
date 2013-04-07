local addon = ...

Ux = Ux or {}
Ux.BagSlots = Ux.BagSlots or {}

local function updateSlot(self, item)
    self.icon:SetTexture("Rift", item.icon)
    self.icon:SetVisible(true)
    self.border:SetTexture("Rift", "icon_border_disabled.dds")
    self.border:SetVisible(true)
end

local function emptySlot(self)
    self.icon:SetVisible(false)
    self.highlight:SetVisible(false)
    self.border:SetTexture("Rift", "icon_border_disabled.dds")
end

local function onLeftDown(self)
    Command.Item.Standard.Drag(self.slotid)
end

local function onLeftUp(self)
    Command.Item.Standard.Drop(self.slotid)
end

function Ux.BagSlots.New(bagids, parent)
    local this = Ux.Slots.New(bagids, parent)
    this:SetRow(1)
    this:SetPadding(-11, -11, -3, 10)
    
    this:SetSlotMethod("UpdateSlot", updateSlot)
    this:SetSlotMethod("EmptySlot", emptySlot)
    this:SetSlotEvent("LeftUp", onLeftUp)
    this:SetSlotEvent("LeftDown", onLeftDown)
    
    this:UpdateSlots()
    return this
end
