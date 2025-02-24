-------------------------------------------------------------------------------
----------------------------------- MESSAGE -----------------------------------
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------

TMDM_MessageMixin = {
    timers = {},
}

function TMDM_MessageMixin:IsDisplayed()
    for index = 1, 3 do
        if self.timers[index] then
            return true
        end
    end
    return false
end

function TMDM_MessageMixin:Display(index, message, duration)
    local frame = self["Text" .. index]
    if frame then
        frame:SetText(message)
        self:Show()

        if self.timers[index] then
            self.timers[index]:Cancel()
        end

        self.timers[index] = C_Timer.NewTimer(duration, function()
            self:Remove(index)
            if not self:IsDisplayed() then
                self:Hide()
            end
        end)
    end
end

function TMDM_MessageMixin:Remove(index)
    local frame = self["Text" .. index]
    local timer = self.timers[index]
    if timer then
        timer:Cancel()
    end
    frame:SetText("")
    self.timers[index] = nil
end

function TMDM_MessageMixin:Stop()
    self:Remove(1)
    self:Remove(2)
    self:Remove(3)
    self:Hide()
end
