local addon, shared = ...

Ux.Slots = Ux.Slots or { }

local function createItemSlot(slotid, parent)
    local slot = UI.CreateFrame("Texture", "slot_frame", parent)
    slot:SetTexture("Rift", "icon_empty.png.dds")
    slot.slotid = slotid

    slot.icon = UI.CreateFrame("Texture", "slot_icon", slot)
    slot.icon:SetPoint("CENTER", slot, "CENTER", 0, 0)
    slot.icon:SetLayer(1)

    slot.highlight = UI.CreateFrame("Texture", "slot_highlight", slot)
    slot.highlight:SetVisible(false)
    slot.highlight:SetLayer(2)
    slot.highlight:SetPoint("CENTER", slot, "CENTER", 0, 0)
    slot.highlight:SetTexture(addon.identifier, "textures/highlight.png")

    slot.border = UI.CreateFrame("Texture", "slot_border", slot)
    slot.border:SetPoint("CENTER", slot, "CENTER", 0, 0)
    slot.border:SetLayer(3)

    slot.text = UI.CreateFrame("Text", "slot_text", slot)
    slot.text:SetVisible(false)
    slot.text:SetLayer(4)
    slot.text:SetFontSize(16)
    slot.text:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", -8, -2)
    
    function slot:SetSize(width, height)
        self:SetWidth(width)
        self:SetHeight(height)
        self.icon:SetHeight(height - 11)
        self.icon:SetWidth(width - 11)
        self.highlight:SetHeight(height - 15)
        self.highlight:SetWidth(width - 15)
        self.border:SetHeight(height)
        self.border:SetWidth(width)
    end
    
    function slot:Update()
        self.item = GetItemDetail(self.slotid)
        if self.item and self.UpdateSlot then self:UpdateSlot(self.item)
        elseif self.item == nil and self.EmptySlot then self:EmptySlot() end
    end
    
    function slot:Highlight(state)
        self.highlight:SetVisible(state)
    end
    
    return slot
end

local function compareSlotsId(a, b)
    local _, a_param = Utility.Item.Slot.Parse(a)
    local _, b_param = Utility.Item.Slot.Parse(b)
    if a_param == "main" and b_param ~= "main" then
        return true
    elseif b_param == "main" and a_param ~= "main" then
        return false
    else
        return a < b
    end
end

local function arrangeSlots(self)
    local row = 1
    local firstSlotOfLastLine = nil
    local lastSlotInLine = nil
    local right = 0

    for id, slot in pairsByKeys(self.slots, compareSlotsId) do
        if slot:GetVisible() then
            slot:SetSize(self.slotsize.width, self.slotsize.height)
            if row == 1 and firstSlotOfLastLine == nil then 
                slot:SetPoint("TOPLEFT", slot:GetParent(), "TOPLEFT", 0, 0)
                firstSlotOfLastLine = slot
            elseif row == 1 and firstSlotOfLastLine ~= nil then
                slot:SetPoint("TOPLEFT", firstSlotOfLastLine, "BOTTOMLEFT", 0, self.padding.top)
                firstSlotOfLastLine = slot
            else
                slot:SetPoint("TOPLEFT", lastSlotInLine, "TOPRIGHT", self.padding.left, 0)
            end
            lastSlotInLine = slot

            row = row + 1
            if row > self.row then 
                row = 1
                right = slot:GetRight()
            end
        end
    end
    self:SetWidth(right - self:GetLeft())
    self:SetHeight(lastSlotInLine:GetBottom() - self:GetTop())
end

local function createSlots(slotids, parent)
    local this = UI.CreateFrame("Frame", "slotsframe", parent)
    this.slots = {}
    for i, slotid in pairs(slotids) do
        this.slots[slotid] = createItemSlot(slotid, this)
    end
    return this
end

local function onItemSlot(self, id, value)
    if self.slots[id] == nil then 
        self.slots[id] = createItemSlot(id, self)
        self.needUpdate = true
    end
    
    if type(value) == "boolean" and not value then 
        if self.slots[id]:GetVisible() then
            self:OnItemUpdate(id)
            Ux.Tooltip.Hide()
        else
            self.slots[id]:SetVisible(true)
            self.needUpdate = true
        end
    elseif value == "nil" then
        self.slots[id]:SetVisible(false)
        self.needUpdate = true
    else
        self.slots[id]:SetVisible(true)
        self:OnItemUpdate(id)
    end
end

----------- Public ------------
function Ux.Slots.New(slotids, parent)
    local this = createSlots(slotids, parent)
    this.row = 10
    this.needUpdate = true
    this.slotsize = {width = 64, height = 64}
    this.padding = {left = 10, top = 10, right = 10, bottom = 10}
    
    function this:Offline()
        for k, v in pairs(self.slots) do
            v.oldRightClick = v.Event.RightClick
            v.oldLeftDown = v.Event.LeftDown
            v.oldLeftUp = v.Event.LeftUp
            v.oldMiddleClick = v.Event.MiddleClick 
            
            v.Event.RightClick = nil
            v.Event.LeftDown = nil
            v.Event.LeftUp = nil
            v.Event.MiddleClick = nil
        end
    end
    
    function this:Online()
        for k, v in pairs(self.slots) do
            v.Event.RightClick = v.oldRightClick
            v.Event.LeftDown = v.oldLeftDown
            v.Event.LeftUp = v.oldLeftUp
            v.Event.MiddleClick = v.oldMiddleClick
        end
    end
    
    function this:SetSlotEvent(event, handler)
        for k, v in pairs(self.slots) do
            v.Event[event] = handler
        end
    end
    
    function this:SetSlotMethod(method, handler)
        for k, v in pairs(self.slots) do
            v[method] = handler
        end
    end
    
    function this:SetSlotSize(width, height)
        self.slotsize.width = width
        self.slotsize.height = height
        arrangeSlots(self)
    end
    
    function this:SetRow(row)
        self.row = row
    end
    
    function this:SetPadding(left, right, top, bottom)
        self.padding.left = left or -10
        self.padding.right = right or 10
        self.padding.top = top or -10
        self.padding.bottom = bottom or 10
    end
    
    function this:GetSlots()
        return self.slots
    end
    
    function this:AddSlot(slotid)
        
    end
    
    function this:UpdateSlots()
        for k, v in pairs(self.slots) do
            v:Update()
        end
    end
    
    function this:OnItemUpdate(id)
        self.slots[id]:Update()
    end
    this.OnItemSlot = onItemSlot
    
    function this:Update()
        if self.needUpdate then
            arrangeSlots(self)
            self.needUpdate = false
        end
    end
    
    return this
end
