local addon, shared = ...

Ux.ItemSlot = Ux.ItemSlot or { }

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

local function UpdateSlot(self)
    local item = GetItemDetail(self.id)
    if not item then return end
    
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

local function EmptySlot(self)
    self.icon:SetVisible(false)
    self.border:SetVisible(false)
    self.text:SetVisible(false)
    self.highlight:SetVisible(false)
end

local function CreateSlot(id, parent)
    local slot = {}
    slot.id = id
    
    slot.frame = UI.CreateFrame("Texture", "slot_frame", parent)
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
        local item = GetItemDetail(id)
        if item then
            slot.highlight:SetVisible(true)
            Dump(item)
            Command.Tooltip(item.id)
            Ux.Tooltip.Show(id, self)
        elseif Inspect.Cursor() == "item" then
            slot.highlight:SetVisible(true)
        end
    end
    function slot.frame.Event:MouseOut()
        slot.highlight:SetVisible(false)
        if GetItemDetail(id) then
            Command.Tooltip(nil)
            Ux.Tooltip.Hide(id)
        end
    end
    function slot.frame.Event:RightClick()
        Command.Item.Standard.Right(id)
    end
    function slot.frame.Event:LeftDown()
        Command.Item.Standard.Drag(id)
    end
    function slot.frame.Event:LeftUp()
        Command.Item.Standard.Drop(id)
    end
    return slot
end

----------- Public ------------
function Ux.ItemSlot.New(id, parent)
    local slot = CreateSlot(id, parent)
    
    function slot:SetVisible(visible)
        self.frame:SetVisible(visible)
    end
    function slot:GetVisible()
        return self.frame:GetVisible()
    end
    function slot:GetTop()
        return self.frame:GetTop()
    end
    function slot:GetBottom()
        return self.frame:GetBottom()
    end
    function slot:GetLeft()
        return self.frame:GetLeft()
    end
    function slot:GetRight()
        return self.frame:GetRight()
    end
    function slot:GetParent()
        return self.frame:GetParent()
    end
    function slot:SetPoint(...)
        self.frame:SetPoint(...)
    end
    slot.Update = UpdateSlot
    slot.Empty = EmptySlot
    
    slot:Update()
    return slot
end
