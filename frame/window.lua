local addon, shared = ...

Ux.Window = Ux.Window or { }

----------- Private -----------
local function CreateCloseButton(parent)
    local closeButton = UI.CreateFrame("RiftButton", "close button", parent)
    closeButton:SetSkin("close")
    closeButton:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, 16)

    function closeButton.Event:LeftClick()
        parent:SetVisible(false)
    end
end

local function createTitle(parent)
    local this = UI.CreateFrame("Text", "windowtitle", parent)
    this:SetFontSize(18)
    this:SetFontColor(0, 0, 0)
    
    function this.Event:LeftDown()
        self.leftDown = true
        local point = Inspect.Mouse()
        self.x = point.x - parent:GetLeft()
        self.y = point.y - parent:GetTop()
    end
    function this.Event:LeftUp()
        self.leftDown = false
    end
    function this.Event:LeftUpoutside()
        self.leftDown = false
    end
    function this.Event:MouseMove()
        if self.leftDown then
            local dx, dy
            local point = Inspect.Mouse()
            dx = point.x - self.x
            dy = point.y - self.y
            parent:SetPoint(dx, dy)
        end
    end
    return this
end

----------- Public ------------
function Ux.Window.New(parent)
    local window = UI.CreateFrame("RiftWindow", "window", parent)
    window:SetVisible(false)
    window:SetTitle("")
    window.title = createTitle(window)
    window.title:SetPoint("TOPCENTER", window, "TOPCENTER", 0, 15)
    CreateCloseButton(window)

    function window:SetTitle(text)
        self.title:ClearWidth()
        self.title:SetText(text)
    end
    function window:Show()
        self:SetVisible(true)
    end
    function window:Hide()
        self:SetVisible(false)
        Ux.Tooltip.Hide()
    end
    function window:SetParentLayer(layer)
        self:GetParent():SetLayer(layer)
    end
    function window:SetSize(width, height)
        self:SetWidth(width)
        self:SetHeight(height)
    end
    window.SetPointNative = window.SetPoint
    function window:SetPoint(x, y)
        self:SetPointNative("TOPLEFT", parent,"TOPLEFT", x, y)
    end

    return window
end
