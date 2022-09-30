--[[

This version (v1) of the addon message format allows simple field=value pairs to define
actions the encounter client should take. Each pair is separated by a semicolon.

    field=value;field=value;field=value

The available fields are (all optional):

    c   The chat message to emit
    d   The display duration (default 5s)
    e   An emote to put in the chat frame
    g   Glow player unit frames
    m   The aura message to be displayed (also m1,m2,m3)
    s   The sound to play

Some examples:

    "m={skull} SOAK MECHANIC {skull}"
    "m=GO IN THE CAGE; d=10"
    "s=airhorn"
    "m=RUN TO {diamond};s=moan"
    "c=SAY Something is on me...;s=bikehorn"
    "m=|cff00ff00COLOR TEST|r MESSAGE"

]] --
local ADDON_NAME, ns = ...

local function tochat(value)
    -- value == "CHANNEL MESSAGE", only allow SAY,YELL,RAID
    local channel, message = value:split(" ", 2)
    if message and (channel == "SAY" or channel == "YELL" or channel == "RAID") then
        return {channel = channel, message = message}
    end
end

local function toplayerlist(value)
    local players = {}
    for i, name in ipairs {value:split(",")} do
        players[#players + 1] = strtrim(name)
    end
    return players
end

local addonMessageFields = {
    c = {"chat", tochat},
    d = {"duration", tonumber},
    e = {"emote", tostring},
    g = {"glow", toplayerlist},
    m = {"message1", tostring},
    m1 = {"message1", tostring},
    m2 = {"message2", tostring},
    m3 = {"message3", tostring},
    s = {"sound", tostring},
}

--[[ parseField

Parse a field from the addon message. Each supported field has a mapped
full-name to be used in the resulting data table, and an optional cast
function.

]] --

local function parseField(field, value)
    local name, cast = unpack(addonMessageFields[field] or {})
    if name then return name, (cast or tostring)(value) end
    print(("TMDM-EC ERROR: unknown field \"%s\""):format(field))
end

--[[ processMessage

Parse the addon message into its separate client instructions and then execute
each of them. Ignore instruction types that are unrecognized.

]] --
local function processMessage(addonMessage)
    print("Parsing:", addonMessage, ("(length=%d)"):format(#addonMessage))

    -- convert the message to a table of instructions
    local data = {}
    for i, chunk in ipairs {addonMessage:split(";")} do
        local field, value = parseField(chunk:split("=", 2))
        if field and value then data[field] = value end
    end

    for k, v in pairs(data) do print(k, v) end

    -- ns.addon:ProcessMessageData(data)
end

--[[ isValidMessage

Only allow messages from the PARTY, RAID and WHISPER channels, and only if they
originate from the current group leader. All other messages are assumed to be
malicious and ignored.

]] --

local function isValidMessage(channel, sender)
    local sender, _ = sender:split("-")
    local fromSelf = sender == UnitName("player") -- for testing
    return (channel == "PARTY" or channel == "RAID" or channel == "WHISPER") and
               (fromSelf or UnitIsGroupLeader(sender))
end

-- Addon message prefixes
local MESSAGE_PREFIX = "TMDM_ECWAv1"

-- Register the user's client to send/receive our addon messages
C_ChatInfo.RegisterAddonMessagePrefix(MESSAGE_PREFIX)

ns.prefixes[MESSAGE_PREFIX] = function(message, channel, sender)
    if isValidMessage(channel, sender) then return processMessage(message) end
end

-- /script C_ChatInfo.SendAddonMessage("TMDM_ECWAv1", "m=test;s=moan", "WHISPER", "Zarillion")
