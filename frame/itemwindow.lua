local addon, shared = ...

Ux = Ux or {}
Ux.ItemWindow = Ux.ItemWindow or { }

Ux.slotTypeMap = {
    inventory = {
        maxBags = 5,
        getSlotid = Utility.Item.Slot.Inventory,
    },
}

local function CreateItemSlots(slotType, parent)
    local slots = {}
    for bagindex = 1, Ux.slotTypeMap[slotType].maxBags do
        local bag = GetItemDetail(Ux.slotTypeMap[slotType].getSlotid("bag", bagindex))
        if bag then
            for slotindex = 1, bag.slots do
                local slotid = Ux.slotTypeMap[slotType].getSlotid(bagindex, slotindex)
                slots[slotid] = Ux.ItemSlot.New(slotid, parent)
            end
        end
    end
    return slots
end

local function ArrangeSlots(self)
    local row = 1
    local firstSlotOfLastLine = nil
    local lastSlotInLine = nil

    for id, slot in pairsByKeys(self.slots) do
        if slot:GetVisible() then
            if row == 1 and firstSlotOfLastLine == nil then 
                slot:SetPoint("TOPLEFT", slot:GetParent(), "TOPLEFT", 0, 0)
                firstSlotOfLastLine = slot
                self.slotsRect.top = slot:GetTop()
                self.slotsRect.left = slot:GetLeft()
            elseif row == 1 and firstSlotOfLastLine ~= nil then
                slot.frame:SetPoint("TOPLEFT", firstSlotOfLastLine.frame, "BOTTOMLEFT", 0, -11)
                firstSlotOfLastLine = slot
            else
                slot.frame:SetPoint("TOPLEFT", lastSlotInLine.frame, "TOPRIGHT", -11, 0)
            end
            lastSlotInLine = slot

            row = row + 1
            if row > UB_Settings.slots_per_line then 
                row = 1
                self.slotsRect.right = slot:GetRight()
            end
        end
    end
    self.slotsRect.bottom = lastSlotInLine:GetBottom()
end

local function GetChangesInSize(newSize, frame)
    local dx, dy
    dx = newSize.right - frame:GetRight()
    dy = newSize.bottom - frame:GetBottom()
    return dx, dy
end

local function AdjustWindowSize(self)
    local dx, dy = GetChangesInSize(self.slotsRect, self.window:GetContent())
    local newWidth = self.window:GetWidth() + dx
    local newHeight = self.window:GetHeight() + dy
    if newHeight < 480 then newHeight = 480 end
    self:SetSize(newWidth, newHeight)
end

local function OnItemSlot(self, id, value)
    if self.slots[id] == nil then 
        self.slots[id] = Ux.ItemSlot.New(id, self.window:GetContent())
    end

    if type(value) == "boolean" and not value then 
        if self.slots[id]:GetVisible() then
            self.slots[id]:Empty()
            Ux.Tooltip.Hide(id)
        else
            self.slots[id]:SetVisible(true)
            self.needUpdate = true
        end
    elseif value == "nil" then
        self.slots[id]:SetVisible(false)
        self.needUpdate = true
    else
        self:OnItemUpdate(id)
    end
end

----------- Public ------------
function Ux.ItemWindow.New(slotType, parent, title)
    local itemwindow = {}
    itemwindow.slotType = slotType
    itemwindow.window = Ux.Window.New(parent, title)
    itemwindow.slots = CreateItemSlots(slotType, itemwindow.window:GetContent())
    itemwindow.slotsRect = {}
    itemwindow.needUpdate = true
    
    Ux.SortButton.New(slotType, itemwindow.window)
    
    function itemwindow:SetSize(width, height)
        self.window:SetSize(width, height)
    end
    function itemwindow:SetPoint(x, y)
        self.window:SetPoint("TOPLEFT", parent,"TOPLEFT", x, y)
    end
    function itemwindow:Toggle()
        self.window:Toggle()
    end
    function itemwindow:Update()
        if self.needUpdate then
            ArrangeSlots(self)
            AdjustWindowSize(self)
            self.needUpdate = false
        end
    end
    function itemwindow:OnItemUpdate(id)
        self.slots[id]:Update()
    end
    itemwindow.OnItemSlot = OnItemSlot
    
    return itemwindow
end