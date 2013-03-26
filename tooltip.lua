local addon, shared = ...

Ux = Ux or { }
Ux.Tooltip = { }

----------- Private -----------
local tooltips = {showlist = {}}
tooltips.context = UI.CreateContext(addon.identifier)
tooltips.context:SetStrata("topmost")

local rarityColor = {
    common =       {r = 1, g = 1, b = 1},
    epic =         {r = 0.9, g = 0.26, b = 0.9},
    quest =        {r = 0.8, g = 0.8, b = 0},
    rare =         {r = 0.13, g = 0.22, b = 1.0},
    relic =        {r = 0.86, g = 0.53, b = 0.01},
    sellable =     {r = 0.5, g = 0.5, b = 0.5},
    transcendant = {r = 0, g = 1, b = 0},
    uncommon =     {r = 0.01, g = 0.91, b = 0.01},
}

local Color = {
    green =  {r = 0.01, g = 0.71, b = 0.01},
    white =  {r = 1, g = 1, b = 1},
    red =    {r = 0.8, g = 0, b = 0},
    yellow = {r = 1, g = 0.85, b = 0.19},
}

local itemDetailTrans = {
    bind =            "绑定",
    bound =           "已绑定",
    equip =           "装备后绑定",
    use =             "使用后绑定",
    pickup =          "拾取绑定",
    account =         "账户绑定",
    coin =            "售价",
    crafter =         "制作者",
    requiredCalling = "职业",
    requiredLevel =   "需要等级",
    sell =            "卖价",
    stackMax =        "最大堆叠",
    damage =          "武器伤害",
    damageDelay =     "速度",
    damagePerSecond = "每秒伤害",
    survival =        "野外生存",
    fishing =         "钓鱼",
    
    consumable =      "消耗品",
    food =            "食物",
    drink =           "饮料",
    potion =          "药水",
    enchantment =     "强化物",
    scroll =          "卷轴",
    container =       "容器",
    crafting =        "制造材料",
    material =        "材料",
    meat =            "肉",
    gem =             "宝石",
    metal =           "金属",
    wood =            "木材",
    hide =            "兽皮",
    fish =            "鱼",
    rune =            "符文",
    recipe =          "配方",
    augment =         "强化物",
    
    onehand =         "单手",
    twohand =         "双手",
    staff =           "法杖",
    wand =            "魔杖",
    sword =           "剑",
    axe =             "斧",
    mace =            "锤",
    dagger =          "匕首",
    ranged =          "远程",
    polearm =         "长柄武器",
    range =           "攻击范围",
    bow =             "弓",
    gun =             "枪",
    totem =           "图腾",
    shield =          "盾",
    
    leather =         "皮甲",
    plate =           "板甲",
    chain =           "锁甲",
    cloth =           "布甲",
    accessory =       "饰品",
    trinket =         "饰品",
    ring =            "戒指",
    legs =            "双腿",
    chest =           "胸甲",
    shoulders =       "肩部",
    head =            "头盔",
    waist =           "腰带",
    feet =            "脚部",
    hands =           "手套",
    neck =            "颈部",
    planar =          "位面精华",
    greater =         "高级",
    lesser =          "低级",
    
    armor =           "护甲",
    dexterity =       "敏捷",
    endurance =       "耐力",
    strength =        "力量",
    dodge =           "躲闪",
    hit =             "命中",
    intelligence =    "智力",
    wisdom =          "精神",
    parry =           "招架",
    toughness =       "韧性",
    resistAll =       "全部抗性",
    resistDeath =     "死亡抗性",
    resistEarth =     "大地抗性",
    resistFire =      "火焰抗性",
    resistLife =      "生命抗性",
    resistWater =     "流水抗性",
    powerSpell =      "法术强度",
    critSpell =       "法术暴击率",
    
    mage =            "法师",
    rogue =           "游侠",
    cleric =          "牧师",
    warrior =         "战士",
    
    ["misc fishing misc"] = "鱼竿",
    ["misc other"] = "消耗品",
}

local TOOLTIP_WIDTH = 260
local TOOLTIP_INFO_PADDING = 10

local function Translate(word)
    return itemDetailTrans[word] or word
end

local function CreateTooltipFrame(pframe)
    local frame
    frame = UI.CreateFrame("Texture", "tooltip.frame", pframe)
    frame:SetTexture("Rift", "ItemToolTip_I71.dds")
    frame:SetWidth(TOOLTIP_WIDTH)
    frame:SetVisible(false)
    return frame
end

local function CreateText(parent)
    local frame = UI.CreateFrame("Text", "tolltip.info", parent)
    frame:SetVisible(false)
    frame:SetWidth(TOOLTIP_WIDTH - TOOLTIP_INFO_PADDING*2)
    frame:SetFontSize(14)
    return frame
end

local function CreateFrame(parent)
    local frame = UI.CreateFrame("Frame", "tolltip.info", parent)
    frame:SetVisible(false)
    frame:SetWidth(TOOLTIP_WIDTH - TOOLTIP_INFO_PADDING*2)
    return frame
end

local function CreateCategoryChild(parent)
    local child = { }
    child.left = CreateText(parent)
    child.left:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    child.left:SetText("1")
    child.right = CreateText(parent)
    child.right:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    child.right.SetTextNative = child.right.SetText
    function child.right:SetText(text)
        self:ClearWidth()
        self:SetTextNative(text)
    end
    parent:SetHeight(child.left:GetHeight())
    return child
end

local function CreateTooltipInfoFrames(framelist, parent)
    local info = { }
    info.category = CreateFrame(parent)
    info.categoryChild = CreateCategoryChild(info.category)
    info.description = CreateText(parent)
    info.description:SetWordwrap(true)
    info.flavor = CreateText(parent)
    info.flavor:SetWordwrap(true)
    return info
end

local function TooltipInfoAppend(tooltip, t)
    if t[1] and tooltip.info[t[1]] == nil then
        tooltip.info[t[1]] = CreateText(tooltip.frame)
    end
    table.insert(tooltip.showlist, t)
end

local function SetStatsInfo(tooltip, stats)
    for k, v in pairsByKeys(stats) do
        local text = Translate(k) .. " +" .. v
        TooltipInfoAppend(tooltip, {k, text, Color.white, 14})
    end
end

local function SetDamageInfo(tooltip, item)
    local text 
    if item.damageMin then
        text = Translate("damage") .. ": " .. item.damageMin .. " - " .. item.damageMax
        TooltipInfoAppend(tooltip, {"damage", text, Color.white, 14})
        local speed = round(item.damageDelay, 2)
        text = Translate("damageDelay") .. ": " .. speed
        TooltipInfoAppend(tooltip, {"damageDelay", text, Color.white, 14})
        text = Translate("damagePerSecond") .. ": " .. round((item.damageMin + item.damageMax) / 2 / speed, 1)
        TooltipInfoAppend(tooltip, {"damagePerSecond", text, Color.white, 14})
    end
    if item.range then
        text = Translate("range") .. ": " .. item.range
        TooltipInfoAppend(tooltip, {"range", text, Color.white, 14})
    end
end

local function SetCategory(handle, categorys)
    local ct = split(categorys)
    if ct[1] == "weapon" then
        handle.left:SetText(Translate(ct[2]))
        if ct[3] then
            handle.right:SetText(Translate(ct[3]))
            handle.right:SetVisible(true)
        else
            handle.right:SetVisible(false)
        end
    elseif ct[1] == "armor" then
        handle.left:SetText(Translate(ct[3]))
        handle.right:SetText(Translate(ct[2]))
        handle.right:SetVisible(true)
    elseif ct[1] == "planar" then
        handle.left:SetText(Translate(ct[1]))
        handle.right:SetText(Translate(ct[2]))
        handle.right:SetVisible(true)
    elseif ct[1] == "crafting" then
        if ct[2] == "ingredient" then 
            handle.left:SetText(Translate("crafting"))
            handle.right:SetVisible(false)
        else
            handle.left:SetText(Translate(ct[2]))
            if ct[3] then
                local text = Translate(ct[3])
                if ct[3] == "cloth" then text = "布" end
                handle.right:SetText(text)
                handle.right:SetVisible(true)
            else
                handle.right:SetVisible(false)
            end
        end
    elseif ct[1] == "consumable" then
        handle.left:SetText(Translate(ct[1]))
        if ct[2] then
            handle.right:SetText(Translate(ct[2]))
            handle.right:SetVisible(true)
        else
            handle.right:SetVisible(false)
        end
    else
        handle.left:SetText(Translate(categorys))
        handle.right:SetVisible(false)
    end
    handle.left:SetVisible(true)
end

local function GetSellText(sell)
    local text = itemDetailTrans.sell .. ": "
    local num = math.floor(sell / 10000)
    if num ~= 0 then text = text .. num .. "白金 " end
    num = math.floor(sell % 10000 / 100)
    if num ~= 0 then text = text .. num .. "金 " end
    num = sell % 100
    text = text .. num .. "银"
    return text
end

local function SetCompareDetail(tooltip, comp)
    TooltipInfoAppend(tooltip, {"compareTips", "替换此物品会改变:", Color.yellow, 13})
    for k, v in pairsByKeys(comp) do
        local text = string.format("%s %+d", Translate(k), v)
        TooltipInfoAppend(tooltip, {"compare" .. k, text, v > 0 and Color.green or Color.red, 13})
    end
end

local function SetCalling(tooltip, calling)
    local text = Translate("requiredCalling") .. ": "
    for i, v in ipairs(split(calling)) do
        text = text .. Translate(v) .. " "
    end
    local color = string.find(calling, Inspect.Unit.Detail("player").calling) and Color.white or Color.red
    TooltipInfoAppend(tooltip, {"requiredCalling", text, color, 14})
end

local function SetTooltipInfo(tooltip, item, comp)
    local info = tooltip.info
    if tooltip.tooltipType == "compare" then
        TooltipInfoAppend(tooltip, {"compareHead", "当前装备", Color.white, 14})
    end
    TooltipInfoAppend(tooltip, {"name", item.name, rarityColor[item.rarity or "common"], 16})
    if item.bound then
        TooltipInfoAppend(tooltip, {"bind", Translate("bound"), Color.white, 14})
    elseif item.bind then
        TooltipInfoAppend(tooltip, {"bind", Translate(item.bind), Color.white, 14})
    end
    
    SetCategory(info.categoryChild, item.category)
    TooltipInfoAppend(tooltip, {"category", nil, nil, nil})
    
    if item.requiredSkill then
        TooltipInfoAppend(tooltip, 
            {"requiredSkill", "需要" .. Translate(item.requiredSkill) .. " " .. item.requiredSkillLevel, Color.white, 14})
    end
    SetDamageInfo(tooltip, item)
    
    if item.stats then SetStatsInfo(tooltip, item.stats) end
    if item.description then
        TooltipInfoAppend(tooltip, {"description", item.description, Color.white, 14})
    end
    if item.flavor then
        TooltipInfoAppend(tooltip, {"flavor", "'" .. item.flavor .. "'", Color.yellow, 14})
    end
    if item.requiredLevel then
        TooltipInfoAppend(tooltip, {"requiredLevel", Translate("requiredLevel") .. ": " .. item.requiredLevel, Color.white, 14})
    end
    if item.requiredCalling then SetCalling(tooltip, item.requiredCalling) end
    
    if item.stackMax then 
        TooltipInfoAppend(tooltip, {"stackMax", Translate("stackMax") .. ": " .. item.stackMax, Color.white, 14})
    end
    if item.crafter then
        TooltipInfoAppend(tooltip, {"crafter", string.format("由<%s>制造", item.crafter), Color.white, 14})
    end
    if item.sell then 
        TooltipInfoAppend(tooltip, {"sell", GetSellText(item.sell), Color.white, 14})
    end
    
    if comp then SetCompareDetail(tooltip, comp) end
end

local function ShowTooltipInfo(tooltip)
    for i, element in ipairs(tooltip.showlist) do 
        local frame = tooltip.info[element[1]]
        frame:SetVisible(true)
        if element[2] then frame:SetText(element[2]) end
        if element[3] then frame:SetFontColor(element[3].r, element[3].g, element[3].b) end
        if element[4] then frame:SetFontSize(element[4]) end
        if i == 1 then 
            frame:SetPoint("TOPLEFT", tooltip.frame, "TOPLEFT", TOOLTIP_INFO_PADDING, TOOLTIP_INFO_PADDING)
        else 
            frame:SetPoint("TOPLEFT", tooltip.info[tooltip.showlist[i - 1][1]], "BOTTOMLEFT", 0, 0)
        end
    end
end

local function AdjustTooltipSize(tooltip)
    local top = tooltip.frame:GetTop()
    local bottom = tooltip.info[tooltip.showlist[#tooltip.showlist][1]]:GetBottom()
    local height = bottom - top + TOOLTIP_INFO_PADDING*2
    tooltip.frame:SetHeight(height)
end

local function CreateTooltip(tooltipType)
    local tooltip = {}
    tooltip.showlist = { }
    tooltip.tooltipType = tooltipType or "default"
    tooltip.frame = CreateTooltipFrame(tooltips.context)
    tooltip.info = CreateTooltipInfoFrames(itemDetailFrame, tooltip.frame)
    
    function tooltip.Update(self, item, comp)
        SetTooltipInfo(self, item, comp)
        ShowTooltipInfo(self)
        AdjustTooltipSize(self)
    end
    
    function tooltip.Show(self)
        self.frame:SetVisible(true)
    end

    function tooltip.Hide(self)
        self.frame:SetVisible(false)
        for k, v in pairs(self.showlist) do self.info[v[1]]:SetVisible(false) end
        self.showlist = { }
    end
    
    function tooltip.GetWidth(self)
        return self.frame:GetWidth()
    end
    
    function tooltip.GetHeight(self)
        return self.frame:GetHeight()
    end
    
    function tooltip.SetPoint(self, x, y)
        return self.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
    end
    return tooltip
end

local function GetTooltipPosition(tipSize, target)
    local targetLeft, targetTop, targetRight, targetBottom  = target:GetBounds()
    local windowWidth = UIParent:GetWidth()
    local postion = {}
    
    postion.top = targetTop - tipSize.height
    if postion.top > 0 then
        -- target top
        if targetRight + tipSize.width < windowWidth then
            postion.left = targetRight
            postion.orientation = "topright"
        else
            postion.left = targetLeft - tipSize.width
            postion.orientation = "topleft"
        end
    else 
        -- target bottom
        if targetRight + tipSize.width < windowWidth then
            postion.left = targetRight
            postion.top = targetBottom
            postion.orientation = "bottomright"
        else
            postion.left = targetLeft - tipSize.width
            postion.top = targetBottom
            postion.orientation = "bottomleft"
        end
    end
    postion.bottom = postion.top + tipSize.height
    postion.right = postion.left + tipSize.width
    return postion
end

local function GetCompareItems(category)
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

local function GetTooltipsSize(list)
    local size = {width = 0, height = 0,}
    for i, v in ipairs(list) do
        size.height = math.max(size.height, v:GetHeight())
        size.width = size.width + v:GetWidth()
    end
    return size
end

local function ArrangTooltips(list, target)
    local pos = GetTooltipPosition(GetTooltipsSize(list), target)
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
        v:Show()
    end
end

local function CompareStats(main, comp)
    local result = {}
    if main then for k, v in pairs(main) do result[k] = v end end
    if comp then
        for k, v in pairsByKeys(comp) do
            result[k] = (result[k] or 0) - v
        end
    end
    return result
end

local function ShowTooltips(slotid, target)
    local item = Inspect.Item.Detail(slotid)
    tooltips.main:Update(item)
    table.insert(tooltips.showlist, tooltips.main)
    
    local compItem1, compItem2 = GetCompareItems(item.category)
    if compItem1 then 
        tooltips.comp1:Update(compItem1, CompareStats(item.stats, compItem1.stats)) 
        table.insert(tooltips.showlist, tooltips.comp1)
    end
    if compItem2 then 
        tooltips.comp2:Update(compItem2, CompareStats(item.stats, compItem2.stats)) 
        table.insert(tooltips.showlist, tooltips.comp2)
    end
    
    ArrangTooltips(tooltips.showlist, target)
end

----------- Pubic -----------
function Ux.Tooltip.Init()
    tooltips.main = CreateTooltip()
    tooltips.comp1 = CreateTooltip("compare")
    tooltips.comp2 = CreateTooltip("compare")
end

function Ux.Tooltip.Show(slotid, target)
    Ux.Tooltip.Hide()
    tooltips.currentSlot = slotid
    ShowTooltips(slotid, target)
end

function Ux.Tooltip.Hide(slotid)
    if slotid and slotid ~= tooltips.currentSlot then
        return
    else
        for k, v in pairs(tooltips.showlist) do
            v:Hide()
        end
        tooltips.showlist = {}
    end
end
