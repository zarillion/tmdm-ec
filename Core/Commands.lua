-------------------------------------------------------------------------------
---------------------------------- COMMANDS -----------------------------------
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------

local function DebugMRTNote()
    DevTools_Dump(ns.ParseMRTNote())
end

-------------------------------------------------------------------------------

-- Addon message prefixes
local VERSION_PREFIX = "TMDM_ECWAvc"

-- Register the user's client to send/receive our addon messages
C_ChatInfo.RegisterAddonMessagePrefix(VERSION_PREFIX)

local VERSIONS = {}

local function SendVersionMessage(message, channel, target)
    C_ChatInfo.SendAddonMessage(VERSION_PREFIX, message, channel, target)
end

local function InitializeVersion(unit)
    local player = ns.GetFullUnitName(unit)
    if player then
        VERSIONS[player] = 0
    end
end

local function RunVersionCheck()
    print("Running TMDM:EC version check (v" .. ns.addon.version .. ")...")
    table.wipe(VERSIONS)

    if IsInRaid() then
        for i = 1, 40 do
            InitializeVersion("raid" .. i)
        end
        SendVersionMessage("request", "RAID")
    elseif IsInGroup() then
        for i = 1, 4 do
            InitializeVersion("party" .. i)
        end
        SendVersionMessage("request", "PARTY")
    else
        -- Not in a group, just sent to ourselves =)
        SendVersionMessage("request", "WHISPER", UnitName("player"))
    end

    C_Timer.After(3, function()
        local current = {}
        local outdated = {}
        local missing = {}

        for name, version in pairs(VERSIONS) do
            if version == ns.addon.version then
                current[#current + 1] = ns.Colorize(name)
            elseif version == 0 then
                missing[#missing + 1] = ns.Colorize(name)
            else
                outdated[#outdated + 1] = ns.Colorize(name) .. " (" .. version .. ")"
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
end

ns.prefixes[VERSION_PREFIX] = function(message, _, sender)
    if message == "request" then
        SendVersionMessage(ns.addon.version, "WHISPER", sender)
    else
        VERSIONS[sender] = message
    end
end

-------------------------------------------------------------------------------

local function SendCustomMessage(target, ...)
    local message = strjoin(" ", ...)

    print("Sending custom message to " .. target .. " (length=" .. #message .. ")")

    if target == "PARTY" or target == "RAID" then
        ns.Emit(message, target)
    else
        ns.Emit(message, "WHISPER", target)
    end
end

-------------------------------------------------------------------------------

local LOCKED = true

local function ToggleFrameLocks()
    if LOCKED then
        for frame in ns.addon:Frames() do
            frame:Unlock()
        end
    else
        for frame in ns.addon:Frames() do
            frame:Lock()
        end
    end
    LOCKED = not LOCKED
end

local function ResetFramePositions()
    for frame in ns.addon:Frames() do
        frame:Reset()
    end
end

-------------------------------------------------------------------------------

local TEST_MESSAGE = {
    "m={rt2} TEST MESSAGE {rt5}",
    "s=569593", -- level up sound
    "c=YELL:{rt1} TEST {rt2}!",
    "e=This is a test emote.",
    "b=player:1:5",
    "z=" .. strjoin(
        ",",
        unpack({
            -- top row
            "t:-75:50",
            "s:-25:50",
            "m:25:50",
            "d:75:50",

            -- middle row
            "c:-50::0:0.7:0",
            "g",
            "x:50::0.7:0:0",

            -- bottom row
            "p:-75:-50",
            "h:-25:-50",
            "y:25:-50",
            "o:75:-50",
        })
    ),
    "g=",
}

local function SendTestMessage(target)
    target = target or UnitName("target") or UnitName("player")
    if target and UnitIsFriend("player", target) then
        TEST_MESSAGE[#TEST_MESSAGE] = "g=" .. target
        ns.Emit(strjoin(";", unpack(TEST_MESSAGE)), "WHISPER", target)
    end
end

-------------------------------------------------------------------------------

local ICON = "|TInterface/Addons/" .. ADDON_NAME .. "/Resources/Textures/tmdm.png:0|t"

ns.addon:RegisterChatCommand("tmdm", function(string)
    local args = { strsplit(" ", string) }
    local command = table.remove(args, 1)

    if command == "note" then
        DebugMRTNote()
    elseif command == "send" then
        SendCustomMessage(unpack(args))
    elseif command == "test" then
        SendTestMessage(unpack(args))
    elseif command == "lock" then
        ToggleFrameLocks()
    elseif command == "reset" then
        ResetFramePositions()
    elseif command == "vc" then
        RunVersionCheck()
    else
        print(ICON .. " TMDM Encounter Client:")
        print(" ")
        print("    /tmdm note - Debug note assignments.")
        print("    /tmdm send <target> <message> - Send a custom message.")
        print("    /tmdm test [player] - Send a test message.")
        print("    /tmdm lock - Toggle frame highlights allowing them to be moved.")
        print("    /tmdm reset - Reset positions of all TMDM frames.")
        print("    /tmdm vc - Run a version check for all group members.")
        print(" ")
    end
end)
