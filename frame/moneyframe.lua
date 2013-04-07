local addon = ...

Ux = Ux or {}
Ux.MoneyFrame = Ux.MoneyFrame or {}

local function createMoneyFrame(parent)
    local this = UI.CreateFrame("Frame", "Ux.MoneyFrame", parent)
        
    this.sliver = Ux.IconText.New("RIGHT", this)
    this.sliver:SetIcon(addon.identifier, "textures/sliver.png")
    this.sliver:SetPoint("TOPRIGHT", this, "TOPRIGHT", 0, 0)
    
    this.gold = Ux.IconText.New("RIGHT", this)
    this.gold:SetIcon(addon.identifier, "textures/gold.png")
    this.gold:SetPoint("TOPRIGHT", this.sliver, "TOPLEFT", 0, 0)
    
    this.platinum = Ux.IconText.New("RIGHT", this)
    this.platinum:SetIcon(addon.identifier, "textures/platinum.png")
    this.platinum:SetPoint("TOPRIGHT", this.gold, "TOPLEFT", 0, 0)
    
    return this
end

local function updateMoney(self, money)
    local sliver, gold, platinum
    sliver = money % 100
    gold = math.floor(money % 10000 / 100)
    platinum = math.floor(money / 10000)
    
    self.sliver:SetText("" .. sliver)
    if (platinum ~= 0) or (gold ~= 0) then
        self.gold:SetVisible(true)
        self.gold:SetText("" .. gold)
    else
        self.gold:SetVisible(false)
    end
    if platinum ~= 0 then 
        self.platinum:SetVisible(true)
        self.platinum:SetText("" .. platinum) 
    else
        self.platinum:SetVisible(false)
    end
end

local function adjustWidth(self)
    local width = self.sliver:GetVisible() and self.sliver:GetWidth() or 0
    width = width + (self.gold:GetVisible() and self.gold:GetWidth() or 0)
    width = width + (self.platinum:GetVisible() and self.platinum:GetWidth() or 0)
    self:SetWidth(width)
end

function Ux.MoneyFrame.New(parent)
    local this = createMoneyFrame(parent)

    function this:SetFontSize(size)
        this.sliver:SetFontSize(size)
        this.gold:SetFontSize(size)
        this.platinum:SetFontSize(size)
    end
    
    this.Update = updateMoney
    this.AdjustWidth = adjustWidth
    
    return this
end