local addon, shared = ...

Ux = Ux or {}
Ux.ItemWindow = Ux.ItemWindow or { }

Ux.bagTypeMap = {
    inventory = {
        maxBags = 5,
        getSlotid = Utility.Item.Slot.Inventory,
    },
    bank = {
        maxBags = 8,
        getSlotid = Utility.Item.Slot.Bank,
    },
}

local function getBagInfo(bagType)
    local result = {}
    if bagType == "bank" then 
        table.insert(result, {bagindex = "main", bagslots = 32})
    end
    for i = 1, Ux.bagTypeMap[bagType].maxBags do
        local bag = GetItemDetail(Ux.bagTypeMap[bagType].getSlotid("bag", i))
        if bag then table.insert(result, {bagindex = i, bagslots = bag.slots}) end
    end
    return result
end

local function createItemSlots(bagType, parent)
    local slotids = {}
    for _, v in ipairs(getBagInfo(bagType)) do
        for i = 1, v.bagslots do
            table.insert(slotids, Ux.bagTypeMap[bagType].getSlotid(v.bagindex, i))
        end
    end
    return Ux.ItemSlots.New(slotids, parent)
end

local function createBagSlots(bagType, parent)
    local bagids = {}
    for i = 1, Ux.bagTypeMap[bagType].maxBags do
        bagids[#bagids + 1] = Ux.bagTypeMap[bagType].getSlotid("bag", i)
    end
    return Ux.BagSlots.New(bagids, parent)
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

local function getItemAndSlotList(slots)
    local items = {}
    local slotids = {}
    for id, v in pairsByKeys(slots, compareSlotsId) do
        if v:GetVisible() then
            table.insert(slotids, id)
            if v.item then
                table.insert(items, {id = id, value = v.item})
            end
        end
    end
    return items, slotids
end

local function getChangesInSize(self, target)
    local right = self.itemslots:GetRight()
    if self.bagslots:GetVisible() then right = self.bagslots:GetRight() end
    local bottom = math.max(self.itemslots:GetBottom(), self.bagslots:GetBottom())
    dx = right - target:GetRight()
    dy = bottom - target:GetBottom()
    return dx, dy
end

local function adjustWindowSize(self)
    local dx, dy = getChangesInSize(self, self:GetContent())
    local newWidth = self:GetWidth() + dx
    local newHeight = self:GetHeight() + dy
    if newHeight < 480 then newHeight = 480 end
    self:SetSize(newWidth, newHeight)
end

local function OnItemSlot(self, id, value)
    local _, param = Utility.Item.Slot.Parse(id)
    if param == "bag" then
        self.bagslots:OnItemSlot(id, value)
    else
        self.itemslots:OnItemSlot(id, value)
    end
end

local function OnItemUpdate(self, id)
    local _, param = Utility.Item.Slot.Parse(id)
    if param == "bag" then
        self.bagslots:OnItemUpdate(id)
    else
        self.itemslots:OnItemUpdate(id)
    end
end

local function moveItems(movelist)
    for _, v in ipairs(movelist) do
        for i = #v, 2, -1 do
            Command.Item.Move(v[i - 1], v[i])
        end
    end
end

local function getSlotsOfBag(slots, bagid, num, bagType)
    local result = {}
    local _, _, bagindex = Utility.Item.Slot.Parse(bagid)
    for i = 1, num do
        table.insert(result, slots[Ux.bagTypeMap[bagType].getSlotid(bagindex, i)])
    end
    return result
end

local function highlight(slots, state)
    for _, v in pairs(slots) do
        v:Highlight(state)
    end
end

local function createItemWindow(bagType)
    local context = UI.CreateContext(addon.identifier)
    context:SetStrata("dialog")
    local this = Ux.Window.New(context)
    this.needUpdate = true
    this.bagType = bagType
    
    this.itemslots = createItemSlots(bagType, this:GetContent())
    this.itemslots:SetSlotSize(60, 60)
    this.bagslots = createBagSlots(bagType, this:GetContent())
    this.bagslots:SetVisible(false)
    this.bagslots:SetSlotSize(45, 45)
    this.bagslots:SetSlotEvent("MouseOut", function(self)
        self:Highlight(false)
        if self.item then
            highlight(getSlotsOfBag(this.itemslots.slots, self.slotid, self.item.slots, bagType), false)
        end
    end)
    this.bagslots:SetSlotEvent("MouseIn", function(self)
        local item = self.item
        if item then
            self:Highlight(true)
            highlight(getSlotsOfBag(this.itemslots.slots, self.slotid, self.item.slots, bagType), true)
        elseif Inspect.Cursor() == "item" then
            self:Highlight(true)
        end
    end)
    
    this.itemslots:SetPoint("TOPLEFT", this:GetContent(), "TOPLEFT", 0, 3)
    this.bagslots:SetPoint("TOPLEFT", this.itemslots, "TOPRIGHT", 3, 3)
    
    this.sortButton = Ux.SortButton.New(this)
    function this.sortButton.Event:LeftClick()
        moveItems(Sort(getItemAndSlotList(this.itemslots:GetSlots())))
    end
    function this.sortButton.Event:RightClick()
        this.bagslots:SetVisible(not this.bagslots:GetVisible())
        adjustWindowSize(this)
    end
    
    return this
end

----------- Public ------------
function Ux.ItemWindow.New(bagType)
    local this = createItemWindow(bagType)
    
    function this:Offline()
        self.sortButton:SetVisible(false)
        this.itemslots:Offline()
        this.bagslots:Offline()
    end
    
    function this:Online()
        self.sortButton:SetVisible(true)
        this.itemslots:Online()
        this.bagslots:Online()
    end
    
    function this:Update()
        self.itemslots:Update()
        self.bagslots:Update()
        adjustWindowSize(self)
    end
    
    this.OnItemUpdate = OnItemUpdate
    this.OnItemSlot = OnItemSlot
    
    return this
end