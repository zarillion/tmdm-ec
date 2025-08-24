-------------------------------------------------------------------------------
----------------------------------- MESSAGE -----------------------------------
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------

TMDM_BaseDisplayMixin = {}

function TMDM_BaseDisplayMixin:OnLoad()
    if not self:IsUserPlaced() then
        self:ResetPosition()
    end
end

function TMDM_BaseDisplayMixin:Unlock()
    self:EnableMouse(true)
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    self:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
    self.Overlay:Show()
    self:Show()
end

function TMDM_BaseDisplayMixin:Lock()
    self:EnableMouse(false)
    self:RegisterForDrag()
    self:SetScript("OnDragStart", nil)
    self:SetScript("OnDragStop", nil)
    self:Stop()
end

function TMDM_BaseDisplayMixin:Stop()
    self.Overlay:Hide()
    self:Hide()
end

function TMDM_BaseDisplayMixin:ResetPosition()
    self:ClearAllPoints()
    self:SetDefaultAnchors()
end

function TMDM_BaseDisplayMixin:SetDefaultAnchors()
    self:SetPoint("CENTER", 0, 0)
end
