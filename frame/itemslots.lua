local addon, shared = ...

Ux.ItemSlots = Ux.ItemSlots or { }

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

local function updateSlot(self, item)
    self.icon:SetTexture("Rift", item.icon)
    self.icon:SetVisible(true)

    self.border:SetTexture("Rift", rarityTexture[item.rarity or "common"])
    self.border:SetVisible(true)

    if item.stack and item.stack ~= 1 then
        self.text:SetText("" .. item.stack)
        self.text:SetVisible(true)
    else
        self.text:SetVisible(false)
    end
end

local function emptySlot(self)
    self.icon:SetVisible(false)
    self.border:SetVisible(false)
    self.text:SetVisible(false)
    self.highlight:SetVisible(false)
end

local function onMouseIn(self)
    local item = self.item
    if item then
        Ux.ItemSlots.currentSlot = self.slotid
        self:Highlight(true)
        Command.Tooltip(item.id)
        Ux.Tooltip.Show(item, self)
    elseif Inspect.Cursor() == "item" then
        self:Highlight(true)
    end
end

local function onMouseOut(self)
    self:Highlight(false)
    if Ux.ItemSlots.currentSlot and Ux.ItemSlots.currentSlot == self.slotid then
        Ux.ItemSlots.currentSlot = ""
        Command.Tooltip(nil)
        Ux.Tooltip.Hide()
    end
end

local function onRightClick(self)
    Command.Item.Standard.Right(self.slotid)
end

local function onLeftDown(self)
    Command.Item.Standard.Left(self.slotid)
end

local function onLeftUp(self)
    Command.Item.Standard.Drop(self.slotid)
end

local function onMiddleClick(self)
    Command.Item.Split(self.slotid, 1)
end

----------- Public ------------
function Ux.ItemSlots.New(slotids, parent)
    local this = Ux.Slots.New(slotids, parent)
    this:SetPadding(-11, -11, -11, 10)
    
    this:SetSlotMethod("UpdateSlot", updateSlot)
    this:SetSlotMethod("EmptySlot", emptySlot)
    --this:SetSlotEvent("MiddleClick", onMiddleClick)
    this:SetSlotEvent("LeftUp", onLeftUp)
    this:SetSlotEvent("LeftDown", onLeftDown)
    this:SetSlotEvent("RightClick", onRightClick)
    this:SetSlotEvent("MouseOut", onMouseOut)
    this:SetSlotEvent("MouseIn", onMouseIn)
    
    this:UpdateSlots()
    return this
end
