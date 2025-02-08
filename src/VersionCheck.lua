-------------------------------------------------------------------------------
------------------------------- VERSION CHECKER -------------------------------
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-- Addon message prefixes
local MESSAGE_PREFIX = "TMDM_ECWAvc"

-- Register the user's client to send/receive our addon messages
C_ChatInfo.RegisterAddonMessagePrefix(MESSAGE_PREFIX)

local VERSIONS = {}

ns.addon:RegisterChatCommand("tmdmvc", function()
	print("Running TMDM ECWA version check (v" .. ns.addon.version .. ")...")
	table.wipe(VERSIONS)

	for i = 1, 40 do
		local name = ns.GetFullUnitName("raid" .. i)
		if name then
			VERSIONS[name] = 0
			C_ChatInfo.SendAddonMessage("TMDM_ECWAvc", "request", "WHISPER", name)
		end
	end

	C_Timer.After(2, function()
		local current = {}
		local outdated = {}
		local missing = {}

		for name, version in pairs(VERSIONS) do
			if version == ns.addon.version then
				current[#current + 1] = ns.Colorize(name)
			elseif version == 0 then
				missing[#missing + 1] = ns.Colorize(name)
			else
				outdated[#outdated + 1] = ns.Colorize(name)
			end
		end

		if #current > 0 then
			print("Current: " .. strjoin(", ", unpack(current)))
		end
		if #outdated > 0 then
			print("Outdated: " .. strjoin(", ", unpack(outdated)))
		end
		if #missing > 0 then
			print("Missing: " .. strjoin(", ", unpack(missing)))
		end
	end)
end)

ns.prefixes[MESSAGE_PREFIX] = function(message, _, sender)
	if message == "request" then
		C_ChatInfo.SendAddonMessage(MESSAGE_PREFIX, ns.addon.version, "WHISPER", sender)
	else
		VERSIONS[sender] = message
	end
end
