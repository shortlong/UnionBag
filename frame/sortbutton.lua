local addon, shared = ...

Ux.SortButton = Ux.SortButton or { }

function Ux.SortButton.New(parent)
    local button = UI.CreateFrame("Texture", "sort button", parent)
    button:SetTexture(addon.identifier, "textures/icon_menu_sort.png")
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, 16)
    button:SetWidth(40)
    button:SetHeight(40)
    
    function button.Event:MouseIn()
        button:SetTexture(addon.identifier, "textures/icon_menu_sort_enable.png")
    end
    function button.Event:MouseOut()
        button:SetTexture(addon.identifier, "textures/icon_menu_sort.png")
    end
    return button
end