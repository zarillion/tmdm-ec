--[[

This version (v1) of the addon message format allows simple field=value pairs to define
actions the encounter client should take. Each pair is separated by a semicolon.

    field=value;field=value;field=value

The available fields are (all optional):

    b   Track a unit resource on the special bar
    c   The chat message to emit
    d   The display duration (default 5s)
    e   An emote to put in the chat frame
    g   Glow player unit frames
    m   The aura message to be displayed (also m1,m2,m3)
    s   The sound to play
    l   Draw one or more lines
    z   Draw one or more shapes

Some examples:

    "m={skull} SOAK MECHANIC {skull}"
    "m=GO IN THE CAGE; d=10"
    "s=airhorn"
    "m=RUN TO {diamond};s=moan"
    "c=SAY Something is on me...;s=bikehorn"
    "m=|cff00ff00COLOR TEST|r MESSAGE"

Caveats:

  * All messages received are assumed to be for us. This means the WHISPER channel must
    be used to direct individuals, which does not work cross-realm.
  * The message is limited to 255 characters as no serializer/compression or comms API
    is used to split the messages.
  * Duration is applied to both the glow and display if sent in the same message.

]]

local ADDON_NAME, ns = ...

local function tospecialbar(value)
    -- value == "UNIT:RESOURCE[:TIMER]"
    if value == "" then
        return { timer = 0 }
    end
    local unit, resource, timer = strsplit(":", value)
    return { unit = unit, resource = tonumber(resource), timer = tonumber(timer) }
end

local function tochat(value)
    -- value == "CHANNEL [TARGET] MESSAGE"; TARGET only set for WHISPER channel
    local channel, message = strsplit(" ", value, 2)
    local target = nil

    if #channel > 0 and #message > 0 then
        if channel == "WHISPER" then
            target, message = strsplit(" ", message, 2)
        end
        return { channel = channel, message = message, target = target }
    end
end

local function toplayerlist(value)
    -- value == PlayerName1,PlayerName2,PlayerName3
    local players = {}
    for i, name in ipairs({ strsplit(",", value) }) do
        players[#players + 1] = strtrim(name)
    end
    return players
end

local function tolines(value)
    -- value == "line,line,line,..."
    -- line == "x:y:x:y[:thickness:r:g:b:a]"
    local lines = {}
    for i, line in ipairs({ strsplit(",", value) }) do
        local x1, y1, x2, y2, thickness, r, g, b, a = strsplit(":", line)
        lines[i] = {
            position = {
                x1 = tonumber(x1),
                y1 = tonumber(y1),
                x2 = tonumber(x2),
                y2 = tonumber(y2),
            },
            color = {
                r = tonumber(r) or 1,
                g = tonumber(g) or 1,
                b = tonumber(b) or 1,
                a = tonumber(a) or 1,
            },
            thickness = tonumber(thickness) or 4,
        }
    end
    return lines
end

local function toshapes(value)
    -- value == "shape,shape,shape,..."
    -- shape == "type[:x:y:r:g:b:a:scale:angle]"
    local shapes = {}
    for i, shape in ipairs({ strsplit(",", value) }) do
        local type, x, y, r, g, b, a, scale, angle = strsplit(":", shape)
        shapes[i] = {
            type = type,
            position = {
                x = tonumber(x) or 0,
                y = tonumber(y) or 0,
            },
            color = {
                r = tonumber(r) or 1,
                g = tonumber(g) or 1,
                b = tonumber(b) or 1,
                a = tonumber(a) or 1,
            },
            scale = tonumber(scale) or 1,
            angle = tonumber(angle) or 0,
        }
    end
    return shapes
end

local addonMessageFields = {
    b = { "bar", tospecialbar },
    c = { "chat", tochat },
    d = { "duration", tonumber },
    e = { "emote", tostring },
    g = { "glow", toplayerlist },
    m = { "message2", tostring },
    m1 = { "message1", tostring },
    m2 = { "message2", tostring },
    m3 = { "message3", tostring },
    s = { "sound", tostring },
    l = { "lines", tolines },
    z = { "shapes", toshapes },
}

--[[ parseField

Parse a field from the addon message. Each supported field has a mapped
full-name to be used in the resulting data table, and an optional cast
function.

]]
local function parseField(field, value)
    local name, cast = unpack(addonMessageFields[field] or {})
    if name then
        return name, (cast or tostring)(value)
    end
    print(('TMDM-EC ERROR: unknown field "%s"'):format(field))
end

--[[ processMessage

Parse the addon message into its separate client instructions and then execute
each of them. Ignore instruction types that are unrecognized.

]]
local function processMessage(addonMessage)
    -- print("Parsing:", addonMessage, ("(length=%d)"):format(#addonMessage))

    -- convert the message to a table of instructions
    local data = {}
    for i, chunk in ipairs({ strsplit(";", addonMessage) }) do
        local field, value = parseField(strsplit("=", chunk, 2))
        if field and value then
            data[field] = value
        end
    end

    if data.chat then
        ns.actions:ChatMessage(data.chat.message, data.chat.channel, data.chat.target)
    end

    if data.emote then
        ns.actions:EmoteMessage(data.emote)
    end

    if data.sound then
        ns.actions:SoundFile(data.sound)
    end

    if data.glow then
        for _, name in ipairs(data.glow) do
            ns.actions:FrameGlow(name, data.duration or 5)
        end
    end

    if data.bar then
        ns.actions:SpecialBar(data.bar.unit, data.bar.resource, data.bar.timer)
    end

    if data.lines or data.shapes then
        ns.actions:Diagram(data.lines, data.shapes, data.duration or 5)
    end

    for i = 1, 3 do
        if data["message" .. i] then
            ns.actions:BannerMessage(i, data["message" .. i], data.duration or 5)
        end
    end
end

local VALID_CHANNELS = { "PARTY", "RAID", "WHISPER" }

--[[ isValidMessage

Only allow messages from the PARTY, RAID and WHISPER channels, and only if they
originate from the current group leader. All other messages are assumed to be
malicious and ignored.

]]
local function isValidMessage(channel, sender)
    local name, _ = strsplit("-", sender)
    local fromSelf = name == UnitName("player") -- for testing
    local validChannel = ns.Contains(VALID_CHANNELS, channel)
    return validChannel and (fromSelf or UnitIsGroupLeader(name))
end

-- Addon message prefixes
local MESSAGE_PREFIX = "TMDM_ECWAv1"

-- Register the user's client to send/receive our addon messages
C_ChatInfo.RegisterAddonMessagePrefix(MESSAGE_PREFIX)

ns.prefixes[MESSAGE_PREFIX] = function(message, channel, sender)
    if isValidMessage(channel, sender) then
        return processMessage(message)
    end
end
