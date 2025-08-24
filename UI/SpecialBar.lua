-------------------------------------------------------------------------------
--------------------------------- SPECIAL BAR ---------------------------------
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------

local HEALTH_COLOR = CreateColor(0.4, 0.9, 0.4)
local ABSORB_COLOR = CreateColor(0.2, 0.7, 0.9)

local RESOURCES = {
    HEALTH = 1,
    POWER = 2,
    DAMAGE_ABSORB = 3,
    HEALING_ABSORB = 4,
}

local function GetMaxResource(unit, resource)
    if resource == RESOURCES.HEALTH then
        return UnitHealthMax(unit)
    elseif resource == RESOURCES.POWER then
        return UnitPowerMax(unit) -- main power type only
    elseif resource == RESOURCES.DAMAGE_ABSORB then
        return UnitGetTotalAbsorbs(unit)
    elseif resource == RESOURCES.HEALING_ABSORB then
        return UnitGetTotalHealAbsorbs(unit)
    end
    error("TMDM: Unknown special bar resource: " .. (resource or "(nil)"))
end

local function GetCurrentResource(unit, resource)
    if resource == RESOURCES.HEALTH then
        return UnitHealth(unit)
    elseif resource == RESOURCES.POWER then
        return UnitPower(unit) -- main power type only
    elseif resource == RESOURCES.DAMAGE_ABSORB then
        return UnitGetTotalAbsorbs(unit)
    elseif resource == RESOURCES.HEALING_ABSORB then
        return UnitGetTotalHealAbsorbs(unit)
    end
    error("TMDM: Unknown special bar resource: " .. (resource or "(nil)"))
end

local function GetResourceColor(unit, resource)
    if resource == RESOURCES.HEALTH then
        return HEALTH_COLOR:GetRGB()
    elseif resource == RESOURCES.POWER then
        local _, token = UnitPowerType(unit)
        local color = PowerBarColor[token]
        return color.r, color.g, color.b
    elseif resource == RESOURCES.DAMAGE_ABSORB then
        return ABSORB_COLOR:GetRGB()
    elseif resource == RESOURCES.HEALING_ABSORB then
        return ABSORB_COLOR:GetRGB()
    end
    error("TMDM: Unknown special bar resource: " .. (resource or "(nil)"))
end

-------------------------------------------------------------------------------

TMDM_SpecialBarMixin = {}

function TMDM_SpecialBarMixin:OnLoad()
    self.length = self:GetWidth() - 2
    TMDM_BaseDisplayMixin.OnLoad(self)
end

function TMDM_SpecialBarMixin:DisplayUnit(unit, resource, timer, color)
    self.unit = unit
    self.resource = resource

    if timer then
        self.timer = timer
        self.start = GetTime()

        self.Spark:ClearAllPoints()
        self.Spark:SetPoint("TOPRIGHT", -1, -1)
        self.Spark:SetPoint("BOTTOMRIGHT", -1, 1)
        self.Spark:Show()
    else
        self.Spark:Hide()
    end

    self.max = GetMaxResource(unit, resource)
    self.current = GetCurrentResource(unit, resource)

    if color.r and color.g and color.b then
        self.Bar:SetColorTexture(color.r, color.g, color.b, color.a)
    else
        self.Bar:SetColorTexture(GetResourceColor(unit, resource))
    end

    self:SetScript("OnUpdate", self.OnUpdateUnit)
    self:Show()
end

function TMDM_SpecialBarMixin:OnUpdateUnit()
    self.current = GetCurrentResource(self.unit, self.resource)
    self.Bar:SetWidth(self.length * min(1, self.current / self.max))
    self.Text:SetText(AbbreviateLargeNumbers(self.current))

    if self.timer then
        local progress = (GetTime() - self.start) / self.timer
        if progress > 1 then
            self:Stop()
            return
        end

        local offset = (self.length - self.Spark:GetWidth()) * progress
        self.Spark:ClearAllPoints()
        self.Spark:SetPoint("TOPRIGHT", -1 - offset, -1)
        self.Spark:SetPoint("BOTTOMRIGHT", -1 - offset, 1)
    end
end

function TMDM_SpecialBarMixin:DisplayTimer(timer, color)
    self.timer = timer
    self.start = GetTime()
    self.Spark:Hide()
    self.Bar:SetColorTexture(color.r or 1, color.g or 1, color.b or 1, color.a)

    self:SetScript("OnUpdate", self.OnUpdateTimer)
    self:Show()
end

function TMDM_SpecialBarMixin:OnUpdateTimer()
    local elapsed = GetTime() - self.start
    local remaining = self.timer - elapsed
    local progress = elapsed / self.timer

    if progress > 1 then
        self:Stop()
        return
    end

    self.Bar:SetWidth(self.length * (1 - progress))
    self.Text:SetText(format("%.1f", remaining))
end

function TMDM_SpecialBarMixin:Stop()
    self.unit = nil
    self.resource = nil
    self.max = nil
    self.current = nil
    self.timer = nil

    self:SetScript("OnUpdate", nil)
    self.Spark:Hide()
    TMDM_BaseDisplayMixin.Stop(self)
end

function TMDM_SpecialBarMixin:Unlock()
    self.Bar:SetColorTexture(ABSORB_COLOR:GetRGB())
    self.Text:SetText("TIMER")
    TMDM_BaseDisplayMixin.Unlock(self)
end

function TMDM_SpecialBarMixin:SetDefaultAnchors()
    self:SetPoint("TOP", "TMDM_MessageFrame", "BOTTOM", 0, -5)
end
