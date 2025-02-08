-------------------------------------------------------------------------------
---------------------------------- NAMESPACE ----------------------------------
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

ns.addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
ns.addon.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "version")

ns.prefixes = {}

ns.addon:RegisterEvent("CHAT_MSG_ADDON", function(event, prefix, message, channel, sender)
	local callback = ns.prefixes[prefix]
	if callback then
		callback(message, channel, sender)
	end
end)

_G.TMDM = ns
