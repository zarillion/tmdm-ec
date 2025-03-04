-------------------------------------------------------------------------------
----------------------------------- MESSAGE -----------------------------------
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------

local TEXTURE_SIZE = 32 -- all shape textures are 32x32

TMDM_DiagramMixin = {
    textures = {},
    lines = {},
    timer = nil,
}

function TMDM_DiagramMixin:OnLoad()
    for i = 1, 16 do
        local texture = self["Texture" .. string.format("%02d", i)]
        if texture then
            self.textures[#self.textures + 1] = texture
        end
    end

    for i = 1, 10 do
        local line = self["Line" .. string.format("%02d", i)]
        if line then
            self.lines[#self.lines + 1] = line
        end
    end
end

function TMDM_DiagramMixin:Display(lines, shapes, duration)
    if self.timer then
        self:Stop()
        self.timer:Cancel()
    end

    if lines then
        for i, line in ipairs(lines) do
            local color = line.color
            local texture = self.lines[i]

            texture:SetColorTexture(color.r, color.g, color.b, color.a)
            texture:SetThickness(line.thickness)
            texture:SetStartPoint("CENTER", line.position.x1, line.position.y1)
            texture:SetEndPoint("CENTER", line.position.x2, line.position.y2)
        end
    end

    if shapes then
        for i, shape in ipairs(shapes) do
            local color = shape.color
            local texture = self.textures[i]

            if shape.texture then
                texture:SetTexture(shape.texture)
                texture:SetVertexColor(color.r, color.g, color.b, color.a)
            else
                texture:SetColorTexture(color.r, color.g, color.b, color.a)
            end

            texture:ClearAllPoints()
            texture:SetPoint("CENTER", shape.position.x, shape.position.y)
            texture:SetRotation(shape.angle)
            texture:SetSize(TEXTURE_SIZE * shape.scale, TEXTURE_SIZE * shape.scale)
        end
    end

    self.timer = C_Timer.NewTimer(duration, function()
        self:Stop()
    end)

    self:Show()
end

function TMDM_DiagramMixin:Stop()
    for _, texture in ipairs(self.textures) do
        texture:SetTexture()
        texture:ClearAllPoints()
        texture:SetRotation(0)
        texture:SetVertexColor(1, 1, 1, 1)
    end
    for _, line in ipairs(self.lines) do
        line:SetStartPoint("CENTER", 0, 0)
        line:SetEndPoint("CENTER", 0, 0)
        line:SetThickness(4)
        line:SetVertexColor(1, 1, 1, 1)
    end
    self:Hide()
end
