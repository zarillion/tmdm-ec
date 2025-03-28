-------------------------------------------------------------------------------
---------------------------------- NAMESPACE ----------------------------------
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

ns.addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
ns.addon.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "version")

ns.prefixes = {}

ns.addon:RegisterEvent("CHAT_MSG_ADDON", function(_, prefix, message, channel, sender)
    local callback = ns.prefixes[prefix]
    if callback then
        callback(message, channel, sender)
    end
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
    for frame in TMDM.Frames() do
        frame:Stop()
    end
end)

ns.addon:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    -- Helps glows work on the first message after logging/reloading
    LibStub("LibGetFrame-1.0").ScanForUnitFrames()
end)

_G.TMDM = ns
