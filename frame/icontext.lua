
Ux = Ux or {}
Ux.IconText = Ux.IconText or {}

local textAnchorToIcon = {
    LEFT = "CENTERRIGHT",
    RIGHT = "CENTERLEFT",
    TOP = "BOTTOMCENTER",
    BOTTOM = "TOPCENTER",
}

local anchor = {
    LEFT = "CENTERLEFT",
    RIGHT = "CENTERRIGHT",
    BOTTOM = "BOTTOMCENTER",
    TOP = "TOPCENTER",
}

local function createIconText(iconPos, parent)
    local this = UI.CreateFrame("Frame", "Ux.IconText", parent)
    
    this.icon = UI.CreateFrame("Texture", "Ux.IconText.icon", this)
    this.icon:SetPoint(anchor[iconPos], this, anchor[iconPos], 0, 0)
    
    this.text = UI.CreateFrame("Text", "Ux.IconText.text", this)
    this.text:SetPoint(anchor[iconPos], this.icon, textAnchorToIcon[iconPos], 0, 2)
    
    return this
end

local function adjustFrameSize(self)
    local top = math.min(self.icon:GetTop(), self.text:GetTop())
    local bottom = math.max(self.icon:GetBottom(), self.text:GetBottom())
    local left = math.min(self.icon:GetLeft(), self.text:GetLeft())
    local right = math.max(self.icon:GetRight(), self.text:GetRight())
    self:SetWidth(right - left)
    self:SetHeight(bottom - top)
end

function Ux.IconText.New(iconPos, parent)
    local this = createIconText(iconPos, parent)
    
    function this:SetIcon(source, texture)
        self.icon:SetTexture(source, texture)
        adjustFrameSize(self)
    end
    function this:SetText(text)
        self.text:SetText(text)
        adjustFrameSize(self)
    end
    function this:SetFontSize(size)
        self.text:SetFontSize(size)
        adjustFrameSize(self)
    end
    function this:SetFontColor(rgba)
        self.text:SetFontColor(rgba.r or 0, rgba.g or 0, rgba.b or 0, rgba.a or 1)
    end
    
    return this
end