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

----------- Public ------------
function Ux.Window.New(parent, title)
    local window = UI.CreateFrame("RiftWindow", "window", parent)
    window:SetVisible(false)
    if title then window:SetTitle(title) end
    CreateCloseButton(window)

    function window:SetSize(width, height)
        self:SetWidth(width)
        self:SetHeight(height)
    end
    
    function window:Toggle()
        window:SetVisible(not window:GetVisible())
    end

    local border = window:GetBorder()
    function border.Event:LeftDown()
        self.leftDown = true
        local point = Inspect.Mouse()
        self.x = point.x - self:GetLeft()
        self.y = point.y - self:GetTop()
    end
    function border.Event:LeftUp()
        self.leftDown = false
        UB_Settings.x = window:GetLeft()
        UB_Settings.y = window:GetTop()
    end
    function border.Event:MouseMove()
        if self.leftDown then
            local dx, dy
            local point = Inspect.Mouse()
            dx = point.x - self.x
            dy = point.y - self.y
            window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", dx, dy)
        end
    end
    return window
end
