
Ux = Ux or { }

local addon = ...

local function setCategoryText(self, item)
    local ct = split(item.category)
    local leftText, rightText
    if ct[1] == "weapon" then
        leftText = UB.translate(ct[2])
        rightText = UB.translate(ct[3])
    elseif ct[1] == "armor" then
        leftText = UB.translate(ct[3])
        rightText = UB.translate(ct[2])
    elseif ct[1] == "planar" or ct[1] == "consumable" then
        leftText = UB.translate(ct[1])
        rightText = UB.translate(ct[2])
    elseif ct[1] == "crafting" then
        if ct[2] == "ingredient" then 
            leftText = UB.translate("crafting")
        else
            leftText = UB.translate(ct[2])
            rightText = UB.translate(ct[3])
        end
    else
        leftText = UB.translate(item.category)
    end
    self.AddDoubleText(leftText, rightText)
end

local function setCallingText(self, item)
    local text = ""
    local callings = split(item.requiredCalling)
    table.sort(callings, function(a, b)
        return UB.getCallingOrder(a) < UB.getCallingOrder(b) end)
    for i, v in ipairs(callings) do
        text = text .. UB.translate(v) .. " "
    end
    self.AddText(string.format(UB.translate("requiredCalling"), text),
        string.find(item.requiredCalling, Ux.playerInfo.calling) and UB.color.white or UB.color.red)
end

local function getDamagePerSecond(damageMin, damageMax, speed)
    return round((damageMin + damageMax) / 2 / speed, 1)
end

local function setDamageText(self, item)
    local text 
    local speed = round(item.damageDelay, 2)
    text = string.format(UB.translate("damage"), speed, item.damageMin, item.damageMax)
    text = text .. "\n" .. string.format(UB.translate("damagePerSecond"), 
        getDamagePerSecond(item.damageMin, item.damageMax, speed))
    self.AddText(text)
end

local function setStatsText(self, item)
    local text = ""
    for k, v in pairsByKeys(item.stats, 
        function(a, b) return UB.getStatsOrder(a) < UB.getStatsOrder(b) end) do
        text = text .. string.format("%s +%d\n", UB.translate(k), v)
    end
    self.AddText(text)
end

local function setStatsRuneText(self, item)
    local text = "附魔:\n"
    for k, v in pairsByKeys(item.statsRune,
        function(a, b) return UB.getStatsOrder(a) <= UB.getStatsOrder(b) end) do
        text = text .. string.format("    %s +%d\n", UB.translate(k), v)
    end
    self.AddText(text, UB.color.green)
end

local itemDetailList = {
    {name = "name", 
        func = function(self, item) 
            self.AddText(item.name, UB.rarityColor[item.rarity or "common"], 16)
        end,},
    {name = "bind", 
        func = function(self, item)
            local text
            if item.bound then
                text = UB.translate("bound")
            elseif item.bind then
                text = UB.translate(item.bind)
            end
            self.AddText(text)
        end,},
    {name = "crafter", 
        func = function(self, item) 
            self.AddText(string.format(UB.translate("crafter"), item.crafter))
        end,},
    {name = "category", func = setCategoryText,},
    {name = "damageMin", func = setDamageText,},
    {name = "range", 
        func = function(self, item) 
            self.AddText(string.format(UB.translate("range"), item.range))
        end,},
    {name = "stats", func = setStatsText},
    {name = "statsRune", func = setStatsRuneText},
    {name = "description", 
        func = function(self, item)
            self.AddText(item.description)
        end,},
    {name = "flavor", 
        func = function(self, item)
            self.AddText(item.flavor, UB.color.yellow)
        end,},
    {name = "requiredSkill", 
        func = function(self, item) 
            self.AddText(string.format(UB.translate("requiredSkill"), 
                UB.translate(item.requiredSkill), item.requiredSkillLevel or 1))
        end,},
    {name = "requiredLevel", 
        func = function(self, item) 
            self.AddText(string.format(UB.translate("requiredLevel"), item.requiredLevel),
                (item.requiredLevel <= Ux.playerInfo.level) and UB.color.white or UB.color.red)
        end,},
    {name = "requiredCalling", 
        func = setCallingText,},
    {name = "sell", 
        func = function(self, item)
            self.money:Update(item.sell * (item.stack or 1))
            self.AddFrame(self.money)
        end,},
}

local function setItemDetail(self, item)
    for i, v in ipairs(itemDetailList) do
        if item[v.name] then
            if v.func then v.func(self, item) end
        end
    end
end

local function arrangeLines(self)
    local width = self:GetWidth()
    for i, line in ipairs(self.lines) do 
        line:SetWidth(width - self.padding*2)
        line:SetVisible(true)
        if i == 1 then 
            line:SetPoint("TOPLEFT", self, "TOPLEFT", self.padding, self.padding)
        else 
            line:SetPoint("TOPLEFT", self.lines[i - 1], "BOTTOMLEFT", 0, 0)
        end
    end
end

local function adjustHeight(self)
    local top = self:GetTop()
    local bottom = self.lines[#self.lines]:GetBottom()
    local height = bottom - top + self.padding*2
    self:SetHeight(height)
end

local function createText(self, text, color, fontsize)
    color = color or {}
    
    local this = UI.CreateFrame("Text", "text", self)
    this:SetFontColor(color.r or 1, color.g or 1, color.b or 1)
    this:SetFontSize(fontsize or 14)
    this:SetWordwrap(true)
    this:ClearAll()
    this:SetText(text or " ")
    return this
end

local function createDoubleText(self, lefttext, righttext, leftcolor, rightcolor, fontsize)
    local this = UI.CreateFrame("Frame", "doubletext", self)
    this.left = createText(this, lefttext, leftcolor, fontsize)
    this.left:SetPoint("TOPLEFT", this, "TOPLEFT", 0, 0)
    this.left:SetWordwrap(false)
    this.right = createText(this, righttext, rightcolor, fontsize)
    this.right:SetPoint("TOPRIGHT", this, "TOPRIGHT", 0, 0)
    this.right:SetWordwrap(false)
    this:SetHeight(this.left:GetHeight())
    return this
end

local function createTexture(self, source, texture)
    local this = UI.CreateFrame("Texture", "texture", self)
    this:SetTexture(source, texture)
    return this
end

local function createTooltipFrame(parent)
    local frame = UI.CreateFrame("Frame", "tooltip.frame", parent)
    frame:SetVisible(false)
    
    frame.top = UI.CreateFrame("Mask", "tooltip.frame.top", frame)
    frame.top:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    frame.top:SetLayer(-2)
    local texture = UI.CreateFrame("Texture", "tooltip.texture", frame.top)
	texture:SetPoint("TOPLEFT", frame.top, "TOPLEFT", 0, 0)
	texture:SetTexture(addon.identifier, "textures/tooltip.png")
	
	frame.bottom = UI.CreateFrame("Mask", "tooltip.frame.bottom", frame)
    frame.bottom:SetHeight(10)
    frame.bottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    frame.bottom:SetLayer(-1)
    local texture = UI.CreateFrame("Texture", "tooltip.texture", frame.bottom)
	texture:SetPoint("BOTTOMLEFT", frame.bottom, "BOTTOMLEFT", 0, 0)
	texture:SetTexture(addon.identifier, "textures/tooltip.png")
	
	frame.SetHeightNative = frame.SetHeight
    function frame:SetHeight(height)
	    self:SetHeightNative(height)
	    self.top:SetHeight(height - 10)
	end
	frame.SetWidthNative = frame.SetWidth
    function frame:SetWidth(width)
        self:SetWidthNative(width)
        self.top:SetWidth(width)
        self.bottom:SetWidth(width)
    end
    frame.SetPointNative = frame.SetPoint
    function frame:SetPoint(x, y)
        return self:SetPointNative("TOPLEFT", UIParent, "TOPLEFT", x, y)
    end
    
    return frame
end

local function createMoneyFrame(parent)
    local this = UI.CreateFrame("Frame", "tooltip.money", parent)
    
    this.text = createText(this, UB.translate("sell"))
    this.text:SetWordwrap(false)
    this.text:SetPoint("TOPLEFT", this, "TOPLEFT", 0, 0)
    this.money = Ux.MoneyFrame.New(this)
    this.money:SetFontSize(14)
    this.money:SetHeight(22)
    this.money:SetPoint("TOPLEFT", this.text, "TOPRIGHT", 0, 0)
    this:SetHeight(this.text:GetHeight())
    function this:Update(money)
        this.money:Update(money)
        this.money:AdjustWidth()
    end
    return this
end

local function createTooltip(parent)
    local self = createTooltipFrame(parent)
    self:SetWidth(256)
    self.money = createMoneyFrame(self)
    self.lines = { }
    self.padding = 10
    
    function self.ClearLines()
        for i = 1, #self.lines do
            self.lines[i]:SetVisible(false)
            self.lines[i] = nil
        end
    end
    function self.SetItem(item)
        setItemDetail(self, item)
    end
    function self.Show()
        arrangeLines(self)
        adjustHeight(self)
        self:SetVisible(true)
    end
    function self.Hide()
        self:SetVisible(false)
    end
    function self.SetPadding(padding)
        self.padding = padding
    end
    function self.AddText(text, color, fontsize)
        self.lines[#self.lines + 1] = createText(self, text, color, fontsize)
    end
    function self.AddDoubleText(lefttext, righttext, leftcolor, rightcolor, fontsize)
        self.lines[#self.lines + 1] = 
            createDoubleText(self, lefttext, righttext, leftcolor, rightcolor, fontsize)
    end
    function self.AddTexture(source, texture)
        self.lines[#self.lines + 1] = createText(self, source, texture)
    end
    function self.AddFrame(frame)
        self.lines[#self.lines + 1] = frame
    end
    
    return self
end

local function setCompareDetail(self, item, comp)
    self.ClearLines()
    self.AddText("当前装备")
    self.SetItem(item)
    if comp and getTableCount(comp) > 0 then 
        self.AddText("替换此物品会改变:", UB.color.yellow, 13)
        for k, v in pairsByKeys(comp,
            function(a, b) return UB.getStatsOrder(a) < UB.getStatsOrder(b) end) do
            local text = string.format("%s %+d", UB.translate(k), v)
            self.AddText(text, v > 0 and UB.color.green or UB.color.red, 13)
        end
    end
end

local function getCompareItems(category)
    local ct = split(category)
    local slot1, slot2
    if ct[1] == "weapon" then
        if ct[2] == "ranged" then
            slot1 = "ranged"
        else
            slot1 = "handmain"
            slot2 = "handoff"
        end
    elseif ct[1] == "armor" then
        if ct[3] == "ring" then
            slot1 = "ring1"
            slot2 = "ring2"
        elseif ct[3] == "head" then
            slot1 = "helmet"
        elseif ct[3] == "hands" then
            slot1 = "gloves"
        elseif ct[3] == "waist" then
            slot1 = "belt"
        else
            slot1 = ct[3]
        end
    end
    local item1, item2
    if slot1 then item1 = Inspect.Item.Detail(Utility.Item.Slot.Equipment(slot1)) end
    if slot2 then item2 = Inspect.Item.Detail(Utility.Item.Slot.Equipment(slot2)) end
    return item1, item2
end

local function compareDamagePerSecond(main, comp)
    local dpsMain = getDamagePerSecond(main.damageMin or 0, main.damageMax or 0, main.damageDelay or 1)
    local dpsComp = getDamagePerSecond(comp.damageMin or 0, comp.damageMax or 0, comp.damageDelay or 1)
    return dpsMain - dpsComp
end

local function compareItemStats(main, comp)
    local result = {}
    main = main or {}
    comp = comp or {}
    for k, v in pairs(comp) do
        local tmp = (main[k] or 0) - v
        if tmp ~= 0 then result[k] = tmp end
    end
    for k, v in pairs(main) do 
        if not comp[k] then result[k] = v end 
    end 
    return result
end

local function compare(main, comp)
    local result = compareItemStats(main.stats, comp.stats)
    local dps = compareDamagePerSecond(main, comp)
    if dps ~= 0 then result["damagePerSecond"] = dps end
    return result
end

local function getTooltipPosition(tipSize, target)
    local targetLeft, targetTop, targetRight, targetBottom  = target:GetBounds()
    local postion = {}
    local padding = 10
    
    postion.top = targetTop - tipSize.height + padding
    if postion.top > 0 then
        -- target top
        postion.left = targetLeft - tipSize.width + padding
        if postion.left >= 0 then 
            postion.orientation = "topleft"
        else
            postion.left = targetRight - padding
            postion.orientation = "topright"
        end
    else 
        -- target bottom
        postion.left = targetLeft - tipSize.width + padding
        if postion.left >= 0 then
            postion.top = targetBottom - padding
            postion.orientation = "bottomleft"
        else
            postion.left = targetRight - padding
            postion.top = targetBottom - padding
            postion.orientation = "bottomright"
        end
    end
    postion.bottom = postion.top + tipSize.height
    postion.right = postion.left + tipSize.width
    return postion
end

local function getTooltipsSize(list)
    local size = {width = 0, height = 0,}
    for i, v in ipairs(list) do
        size.height = math.max(size.height, v:GetHeight())
        size.width = size.width + v:GetWidth()
    end
    return size
end

local function arrangTooltips(list, target)
    local pos = getTooltipPosition(getTooltipsSize(list), target)
    for i, v in ipairs(list) do
        if pos.orientation == "topright" then
            v:SetPoint(pos.left, pos.bottom - v:GetHeight())
            pos.left = pos.left + v:GetWidth()
        elseif pos.orientation == "topleft" then
            pos.right = pos.right - v:GetWidth()
            v:SetPoint(pos.right, pos.bottom - v:GetHeight())
        elseif pos.orientation == "bottomright" then
            v:SetPoint(pos.left, pos.top)
            pos.left = pos.left + v:GetWidth()
        elseif pos.orientation == "bottomleft" then
            pos.right = pos.right - v:GetWidth()
            v:SetPoint(pos.right, pos.top)
        else
            print("ERROR: pos.orientation = " .. pos.orientation)
        end
    end
end

local context = UI.CreateContext(addon.identifier)
context:SetStrata("topmost")
local tooltip_main = createTooltip(context)
local tooltip_comp1 = createTooltip(context)
local tooltip_comp2 = createTooltip(context)
local showlist = {}

local function setItem(item)
    tooltip_main.SetItem(item)
    table.insert(showlist, tooltip_main)
    
    local compItem1, compItem2 = getCompareItems(item.category)
    if compItem1 then 
        setCompareDetail(tooltip_comp1, compItem1, compare(item, compItem1))
        table.insert(showlist, tooltip_comp1)
    end
    if compItem2 then 
        setCompareDetail(tooltip_comp2, compItem2, compare(item, compItem))
        table.insert(showlist, tooltip_comp2)
    end
end

local function hide()
    for i, v in ipairs(showlist) do 
        v.Hide() 
        showlist[i] = nil
    end
end

local function show(target)
    for i, v in ipairs(showlist) do v.Show() end
    arrangTooltips(showlist, target)
end

ItemTooltip = {
    ClearLines = tooltip_main.ClearLines,
    SetItem = setItem,
    Show = show,
    Hide = hide,
    SetPadding = tooltip_main.SetPadding,
    AddText = tooltip_main.AddText,
    AddDoubleText = tooltip_main.AddDoubleText,
    AddTexture = tooltip_main.AddTexture,
    AddFrame = tooltip_main.AddFrame,
}