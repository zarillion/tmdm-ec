-------------------------------------------------------------------------------
---------------------------------- NAMESPACE ----------------------------------
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

local EMBEDS = { "AceComm-3.0", "AceConsole-3.0", "AceEvent-3.0" }

ns.addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, unpack(EMBEDS))
ns.addon.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "version")

ns.prefixes = {}

ns.addon:RegisterEvent("CHAT_MSG_ADDON", function(_, prefix, message, channel, sender)
    local callback = ns.prefixes[prefix]
    if callback then
        callback(message, channel, sender)
    end
end)

-- Handler for messages over 255 characters
ns.addon:RegisterComm("TMDMv2", function(_, message, channel, sender)
    ns.addon.HandleMessage(message, channel, sender)
end)

ns.GUIDs = {} -- lookup table for group members

ns.addon:RegisterEvent("ENCOUNTER_START", function()
    table.wipe(ns.GUIDs)
    for unit in ns.IterateGroupMembers() do
        ns.GUIDs[UnitGUID(unit)] = unit
    end
end)

ns.addon:RegisterEvent("ENCOUNTER_END", function()
    -- Hide all displays when an encounter ends
    for frame in ns.addon:Frames() do
        frame:Stop()
    end
end)

ns.addon:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    -- Helps glows work on the first message after logging/reloading
    LibStub("LibGetFrame-1.0").ScanForUnitFrames()
end)

function ns.addon:Frames()
    local i = 0
    local frames = {
        _G["TMDM_MessageFrame"],
        _G["TMDM_SpecialBar"],
        _G["TMDM_DiagramFrame"],
    }
    return function()
        i = i + 1
        if i <= #frames then
            return frames[i]
        end
    end
end

_G.TMDM = ns
