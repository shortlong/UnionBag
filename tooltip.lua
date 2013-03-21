local addon, shared = ...

Ux = Ux or { }
Ux.Tooltip = { }

----------- Private -----------
local tooltips = {}
tooltips.context = UI.CreateContext(addon.identifier)
tooltips.context:SetStrata("topmost")

local rarityColor = {
    common =       {r = 1, g = 1, b = 1},
    epic =         {r = 0.6, g = 0.26, b = 088},
    quest =        {r = 0.8, g = 0.8, b = 0},
    rare =         {r = 0.13, g = 0.42, b = 0.81},
    relic =        {r = 0.86, g = 0.53, b = 0.01},
    sellable =     {r = 0.5, g = 0.5, b = 0.5},
    transcendant = {r = 0, g = 1, b = 0},
    uncommon =     {r = 0.01, g = 0.71, b = 0.01},
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
    consumable =      "消耗品",
    container =       "容器",
    onehand =         "单手",
    twohand =         "双手",
    staff =           "法杖",
    wand =            "魔杖",
    dagger =          "匕首",
    ranged =          "远程",
    range =           "攻击范围",
    bow =             "弓",
    leather =         "皮甲",
    plate =           "板甲",
    chain =           "锁甲",
    accessory =       "饰品",
    ring =            "戒指",
    legs =            "双腿",
    chest =           "胸甲",
    shoulders =       "肩部",
    head =            "头盔",
    feet =            "脚部",
    hands =           "手套",
    neck =            "颈部",
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
    crafting =        "制造材料",
    planar =          "位面精华",
    greater =         "高级",
    powerSpell =      "法术强度",
    critSpell =       "法术暴击率",
}

local TOOLTIP_WIDTH = 240
local TOOLTIP_BORDER_WIDTH = 1
local TOOLTIP_BORDER_HEIGHT = 1

local function Translate(word)
    return itemDetailTrans[word] or word
end

local function CreateTooltipFrame(pframe)
    local frame
    frame = UI.CreateFrame("Frame", "tooltip.frame", pframe)
    frame:SetWidth(TOOLTIP_WIDTH)
    frame:SetVisible(false)
    frame:SetBackgroundColor(0.04, 0.15, 0.10, 0.9)
    return frame
end

local function CreateTooltipBorder(pframe)
    local border = { }
    border.top = UI.CreateFrame("Frame", "tooltip.border", pframe)
    border.top:SetWidth(TOOLTIP_WIDTH)
    border.top:SetHeight(TOOLTIP_BORDER_HEIGHT)
    border.top:SetBackgroundColor(1, 1, 1)
    border.top:SetPoint("TOPLEFT", pframe, "TOPLEFT", 0, 0)
    
    border.bottom = UI.CreateFrame("Frame", "tooltip.border", pframe)
    border.bottom:SetWidth(TOOLTIP_WIDTH)
    border.bottom:SetHeight(TOOLTIP_BORDER_HEIGHT)
    border.bottom:SetBackgroundColor(1, 1, 1)
    border.bottom:SetPoint("BOTTOMLEFT", pframe, "BOTTOMLEFT", 0, -1)

    border.left = UI.CreateFrame("Frame", "tooltip.border", pframe)
    border.left:SetWidth(TOOLTIP_BORDER_WIDTH)
    border.left:SetHeight(pframe:GetHeight())
    border.left:SetBackgroundColor(1, 1, 1)
    border.left:SetPoint("TOPLEFT", pframe, "TOPLEFT", 0, 0)

    border.right = UI.CreateFrame("Frame", "tooltip.border", pframe)
    border.right:SetWidth(TOOLTIP_BORDER_WIDTH)
    border.right:SetHeight(pframe:GetHeight())
    border.right:SetBackgroundColor(1, 1, 1)
    border.right:SetPoint("TOPRIGHT", pframe, "TOPRIGHT", -1, 0)
    return border
end

local itemDetailFrame = {
    "name",
    "bind",
    "damage",
    "damageDelay",
    "damagePerSecond",
    "stackMax",
    "sell",
    "range",
    "crafter",
    "requiredCalling",
    "requiredLevel",
    "requiredSkill",
}

local function CreateText(parent)
    local frame = UI.CreateFrame("Text", "tolltip.info", parent)
    frame:SetVisible(false)
    frame:SetWidth(TOOLTIP_WIDTH - TOOLTIP_BORDER_WIDTH*2 - 5)
    frame:SetFontSize(14)
    return frame
end

local function CreateFrame(parent)
    local frame = UI.CreateFrame("Frame", "tolltip.info", parent)
    frame:SetVisible(false)
    frame:SetWidth(TOOLTIP_WIDTH - TOOLTIP_BORDER_WIDTH*2 - 5)
    return frame
end

local function CreateCategoryFrame(parent)
    local category = { }
    category.frame = CreateFrame(parent)
    category.left = CreateText(category.frame)
    category.left:SetPoint("TOPLEFT", category.frame, "TOPLEFT", 0, 0)
    category.left:SetText("1")
    category.right = CreateText(category.frame)
    category.right:SetPoint("TOPRIGHT", category.frame, "TOPRIGHT", 0, 0)
    category.right:SetWidth(40)
    category.frame:SetHeight(category.left:GetHeight())
    return category
end

local function CreateTooltipInfoFrames(framelist, parent)
    local info = { }
    for i, v in ipairs(framelist) do
        info[v] = CreateText(parent)
    end
    info.category = CreateCategoryFrame(parent) 
    info.description = CreateText(parent)
    info.description:SetWordwrap(true)
    info.flavor = CreateText(parent)
    info.flavor:SetWordwrap(true)
    return info
end

local function SetStatsInfo(tooltip, stats)
    local info = tooltip.info

    for k, v in pairsByKeys(stats) do
        if not info[k] then info[k] = CreateText(tooltip.frame) end
        local text = Translate(k) .. " +" .. v
        table.insert(tooltip.showlist, {info[k], text, Color.white, 14})
    end
end

local function SetWeaponInfo(tooltip, categorys, item)
    local info = tooltip.info
    info.category.left:SetText(Translate(categorys[2]))
    info.category.right:SetText(Translate(categorys[3]))
    info.category.right:SetVisible(true)
    info.category.left:SetVisible(true)

    local text = Translate("damage") .. ": " .. item.damageMin .. " - " .. item.damageMax
    table.insert(tooltip.showlist, {info.damage, text, Color.white, 14})
    local speed = round(item.damageDelay, 2)
    text = Translate("damageDelay") .. ": " .. speed
    table.insert(tooltip.showlist, {info.damageDelay, text, Color.white, 14})
    text = Translate("damagePerSecond") .. ": " .. round((item.damageMin + item.damageMax) / 2 / speed, 1)
    table.insert(tooltip.showlist, {info.damagePerSecond, text, Color.white, 14})
    if item.range then
        text = Translate("range") .. ": " .. item.range
        table.insert(tooltip.showlist, {info.range, text, Color.white, 14})
    end
end

local function SetArmorInfo(tooltip, categorys, item)
    local info = tooltip.info
    info.category.left:SetText(Translate(categorys[3]))
    info.category.right:SetText(Translate(categorys[2]))
    info.category.right:SetVisible(true)
    info.category.left:SetVisible(true)
end

local function SetDefaultInfo(tooltip, categorys, item)
    local info = tooltip.info
    info.category.left:SetText(Translate(categorys[1]))
    info.category.right:SetVisible(false)
    info.category.left:SetVisible(true)
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

local function SetTooltipInfo(tooltip, item)
    local info = tooltip.info
    table.insert(tooltip.showlist, {info.name, item.name, rarityColor[item.rarity or "common"], 16})
    if item.bound then
        table.insert(tooltip.showlist, {info.bind, Translate("bound"), Color.white, 14})
    elseif item.bind then
        table.insert(tooltip.showlist, {info.bind, Translate(item.bind), Color.white, 14})
    end
    table.insert(tooltip.showlist, {info.category.frame, nil, nil, nil})
    
    local categorys = split(item.category)
    if categorys[1] == "weapon" then
        SetWeaponInfo(tooltip, categorys, item)
    elseif categorys[1] == "armor" then
        SetArmorInfo(tooltip, categorys, item)
    else
        SetDefaultInfo(tooltip, categorys, item)
    end
    
    if item.stats then
        SetStatsInfo(tooltip, item.stats)
    end
    if item.description then
        table.insert(tooltip.showlist, {info.description, item.description, Color.white, 14})
    end
    if item.flavor then
        table.insert(tooltip.showlist, {info.flavor, "'" .. item.flavor .. "'", Color.yellow, 14})
    end
    if item.requiredLevel then
        table.insert(tooltip.showlist, {info.requiredLevel, Translate("requiredLevel") .. ": " .. item.requiredLevel, Color.white, 14})
    end
    if item.requiredCalling then
        table.insert(tooltip.showlist, {info.requiredCalling, Translate("requiredCalling") .. ": " .. item.requiredCalling, Color.white, 14})
    end
    if item.stackMax then 
        table.insert(tooltip.showlist, {info.stackMax, Translate("stackMax") .. ": " .. item.stackMax, Color.white, 14})
    end
    if item.crafter then
        table.insert(tooltip.showlist, {info.crafter, string.format("由<%s>制造", item.crafter), Color.white, 14})
    end
    if item.sell then 
        table.insert(tooltip.showlist, {info.sell, GetSellText(item.sell), Color.white, 14})
    end
end

local function ShowTooltipInfo(tooltip)
    for i, element in ipairs(tooltip.showlist) do 
        local frame = element[1]
        frame:SetVisible(true)
        if element[2] then frame:SetText(element[2]) end
        if element[3] then frame:SetFontColor(element[3].r, element[3].g, element[3].b) end
        if element[4] then frame:SetFontSize(element[4]) end
        if i == 1 then 
            frame:SetPoint("TOPLEFT", tooltip.frame, "TOPLEFT", 5, 5)
        else 
            frame:SetPoint("TOPLEFT", tooltip.showlist[i - 1][1], "BOTTOMLEFT", 0, 0)
        end
    end
end

local function AdjustTooltipSize(tooltip)
    local top = tooltip.frame:GetTop()
    local bottom = tooltip.showlist[#tooltip.showlist][1]:GetBottom()
    local height = bottom - top + TOOLTIP_BORDER_HEIGHT + 4 
    tooltip.frame:SetHeight(height)
    tooltip.border.left:SetHeight(height)
    tooltip.border.right:SetHeight(height)
end

local function CreateTooltip()
    local tooltip = {}
    tooltip.showlist = { }
    tooltip.frame = CreateTooltipFrame(tooltips.context)
    tooltip.border = CreateTooltipBorder(tooltip.frame)
    tooltip.info = CreateTooltipInfoFrames(itemDetailFrame, tooltip.frame)
    
    function tooltip.SetBorderColor(self, color)
        if color == nil then return end
        for k, v in pairs(self.border) do
            v:SetBackgroundColor(color.r, color.g, color.b)
        end
    end
    
    function tooltip.Show(self, item)
        self.frame:SetVisible(true)
        self:SetBorderColor(rarityColor[item.rarity or "common"])
        SetTooltipInfo(self, item)
        ShowTooltipInfo(self)
        AdjustTooltipSize(self)
    end

    function tooltip.Hide(self)
        self.frame:SetVisible(false)
        for k, v in pairs(self.showlist) do v[1]:SetVisible(false) end
        self.showlist = { }
    end
    return tooltip
end

local function GetTooltipPosition(tooltip, target)
    local targetTop = target:GetTop()
    local targetBottom = target:GetBottom()
    local targetLeft = target:GetLeft()
    local targetRight = target:GetRight()
    local tooltipWidth = tooltip.frame:GetWidth()
    local tooltipHeight = tooltip.frame:GetHeight()
    local windowWidth = UIParent:GetWidth()

    local x, y
    y = targetTop - tooltipHeight
    if y > 0 then
        -- target top
        if targetRight + tooltipWidth < windowWidth then
            return targetRight, y
        else
            return targetLeft - tooltipWidth, y
        end
    else 
        -- target bottom
        if targetRight + tooltipWidth < windowWidth then
            return targetRight, targetBottom
        else
            return targetLeft - tooltipWidth, targetBottom
        end
    end
end

----------- Pubic -----------
function Ux.Tooltip.Init()
    tooltips.main = CreateTooltip()
    tooltips.comp1 = CreateTooltip()
    tooltips.comp2 = CreateTooltip()
end

function Ux.Tooltip.Show(slotid, target)
    Ux.Tooltip.Hide()
    local item = Inspect.Item.Detail(slotid)
    tooltips.currentSlot = slotid
    tooltips.main:Show(item)
    
    local x, y = GetTooltipPosition(tooltips.main, target)
    tooltips.main.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
end

function Ux.Tooltip.Hide(slotid)
    if slotid and slotid ~= tooltips.currentSlot then
        return
    else
        tooltips.main:Hide()
        tooltips.comp1:Hide()
        tooltips.comp2:Hide()
    end
end
