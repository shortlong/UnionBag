local addon = ...

Ux = Ux or {}
Ux.SplitLine = Ux.SplitLine or {}

local splitLine = {
    lines = {},
    count = 0,
}

local function createSplitLine(parent)
    local this = UI.CreateFrame("Texture", "splitline", parent)
    this:SetTexture(addon.identifier, "textures/tooltip_line.png")
    this:SetVisible(false)
    return this
end

function Ux.SplitLine.Get(parent)
    --print("lines " .. #splitLine.lines)
    for i, v in ipairs(splitLine.lines) do
        if not v:GetVisible() then
            v:SetVisible(true)
            return v
        end
    end
    local line = createSplitLine(parent)
    line:SetVisible(true)
    splitLine.lines[#splitLine.lines + 1] = line
    return line
end