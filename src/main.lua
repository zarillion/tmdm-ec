-------------------------------------------------------------------------------
---------------------------------- NAMESPACE ----------------------------------
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ...

ns.addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceEvent-3.0")
ns.addon.version = GetAddOnMetadata(ADDON_NAME, "version")

function ns.addon:HandleAddonMessage(event, ...) print(event, ...) end

ns.addon:RegisterEvent("CHAT_MSG_ADDON",
    function(...) ns.addon:HandleAddonMessage(...) end)

-- function (event, ...)
--     -- listen for addon messages from the party or raid leader
--     if event == 'CHAT_MSG_ADDON' then
--         local prefix, message, channel, sender = ...
--         if aura_env.isValidAddonMessage(prefix, channel, sender) then
--             return aura_env.processAddonMessage(prefix, message, sender)
--         end
--     end
-- end

