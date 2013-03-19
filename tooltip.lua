local addon, shared = ...

Ux = Ux or { }
Ux.Tooltip = { }

----------- Private -----------
local tooltips = { }
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
    green = {r = 0.01, g = 0.71, b = 0.01},
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
    damage =          "",
    damageDelay =     "",
    damagePerSecond = "",
}

local itemDetailFrame = {
    name = {},
    bind = {},
    category = {
        frametype = "Frame",
        child = {
            left = { postion = "TOPLEFT" },
            right = { postion = "TOPRIGHT" },
        },
    },
    damage = {},
    damageDelay = {},
    damagePerSecond = {},
    stats = {
        frametype = "Frame",
        child = { },
    },
    stackMax = {},
    sell = {},
}

local TOOLTIP_WIDTH = 240
local TOOLTIP_BORDER_WIDTH = 1
local TOOLTIP_BORDER_HEIGHT = 1

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

local function CreateTooltipInfoFrames(framelist, pframe)
    local info = { }
    for k, v in pairs(framelist) do
        local frametype = v.frametype or "Text"
        local frame = UI.CreateFrame(frametype, "tolltip.info", pframe)
        frame:SetVisible(false)
        if frametype == "Text" then
            frame:SetFontSize(14)
            function frame.SetTextAndColor(self, text, color)
                self:SetText(text)
                if color then 
                    self:SetFontColor(color.r or 1, color.g or 1, color.b or 1) 
                end
            end
        end
        if v.child ~= nil then
            info[k] = CreateTooltipInfoFrames(v.child, frame)
            info[k].frame = frame
        else
            info[k] = frame
        end
        frame:SetPoint(v.postion or "TOPLEFT", pframe, v.postion or "TOPLEFT", 0, 0)
    end
    return info
end

local function SetTooltipInfo(tooltip, item)
    local info = tooltip.info
    --info.name:SetTextAndColor(item.name, rarityColor[item.rarity or "common"])
    --info.name:SetFontSize(18)
    --table.insert(tooltip.showlist, info.name)
    if item.bound ~= nil then
        if item.bound then info.bind:SetText(itemDetailTrans.bound)
        else info.bind:SetText(itemDetailTrans[item.bind]) end
        table.insert(tooltip.showlist, info.bind)
    end
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
    
    function tooltip.Update(self, item)
        self:SetBorderColor(rarityColor[item.rarity or "common"])
        SetTooltipInfo(self, item)
    end
    
    function tooltip.Show(self)
        self.frame:SetVisible(true)
        for k, v in pairs(self.showlist) do v:SetVisible(true) end
    end

    function tooltip.Hide(self)
        self.frame:SetVisible(false)
        for k, v in pairs(self.showlist) do v:SetVisible(false) end
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

function Ux.Tooltip.Show(item, target)
    tooltips.main:Update(item)
    tooltips.main:Show()
    local x, y = GetTooltipPosition(tooltips.main, target)
    tooltips.main.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
    tooltips.main.frame:SetVisible(true)
end

function Ux.Tooltip.Hide()
    tooltips.main:Hide()
    tooltips.comp1:Hide()
    tooltips.comp2:Hide()
end
