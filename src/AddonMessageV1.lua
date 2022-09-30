--------------------------------------------------------------------------------
-------------------- DEVELOPED FOR <Trash Mob Death Machine> -------------------
--------------------------------------------------------------------------------
--[[

The purpose of this weak-aura is to receive addon messages from other TMDM
weak-auras that provide information about assignments, debuffs, etc. By making
a generic client, players in the raid only need to install this weak-aura once
for all encounters. Changes to how complex abilities are assigned or what
sounds / visuals are tied to those abilities only affect the raid leader's WA
and do not require updates to this WA.

The addon can be triggered by sending it addon messages of the form:

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
-- Version of this weak-aura
local VERSION = "1.15"

-- Addon message prefixes
local CLIENT_PREFIX = "TMDM_ECWAv1"

-- Register the user's client to send/receive our addon messages
C_ChatInfo.RegisterAddonMessagePrefix(CLIENT_PREFIX)

-- Structures for tracking message channels and their timers
aura_env._message = {}
aura_env._timers = {}

-- Sound media
local LSM = LibStub("LibSharedMedia-3.0")

--[[ aura_env.handleEncounterClientMessage

Parse the addon message into its separate client instructions and then execute
each of them. Ignore instruction types that are unrecognized.

]] --

aura_env.handleEncounterClientMessage = function(addonMessage)
    -- print('Parsing:', addonMessage, ('(length=%d)'):format(#addonMessage))

    -- convert the message to a table of instructions
    local data = {}
    for i, chunk in ipairs {string.split(";", addonMessage)} do
        local field, value = aura_env.parseField(string.split("=", chunk, 2))
        if field and value then data[field] = value end
    end

    -- for k, v in pairs(data) do
    --    print(k, v)
    -- end

    if data.chat then SendChatMessage(data.chat.message, data.chat.channel) end

    if data.emote then
        local emote = ChatTypeInfo["EMOTE"]
        DEFAULT_CHAT_FRAME:AddMessage(data.emote, emote.r, emote.g, emote.b)
    end

    if data.glow then
        for i, name in ipairs(data.glow) do
            aura_env.glowFrame(name, data.duration or 5)
        end
    end

    -- play the requested sound (if any)
    if data.sound then aura_env.playSound(data.sound) end

    local m = aura_env._message
    local t = aura_env._timers

    for i = 1, 3 do
        if data["message" .. i] then
            -- set the display message for channel 1,2,3
            m[i] = data["message" .. i]
            if t[i] then t[i]:Cancel() end
            t[i] = C_Timer.NewTimer(data.duration or 5, function()
                m[i] = nil
                if not (m[1] or m[2] or m[3]) then
                    -- disable the display, no messages left
                    WeakAuras.ScanEvents("TMDM_ECWA_UNTRIGGER")
                end
            end)
        end
    end

    -- trigger display if any channels are active
    return (m[1] or m[2] or m[3])
end

--[[ aura_env.isValidMessage

Only allow messages from the PARTY, RAID and WHISPER channels, and only if they
originate from the current group leader. All other messages are assumed to be
malicious and ignored.

]] --

aura_env.isValidAddonMessage = function(prefix, channel, sender)
    if not (prefix == CLIENT_PREFIX or prefix == KEYS_PREFIX or prefix ==
        VERSION_PREFIX) then
        return false -- not an addon message we recognize
    end
    local sender, realm = string.split("-", sender)
    local fromSelf = sender == UnitName("player") -- for testing
    return (channel == "PARTY" or channel == "RAID" or channel == "WHISPER") and
               (fromSelf or UnitIsGroupLeader(sender))
end

--[[ aura_env.processAddonMessage

Process the given addon message, running whatever functions we have assigned
for prefixes we recognize.

]] --

aura_env.processAddonMessage = function(prefix, message, sender)
    -- handle core encounter client messages
    if prefix == CLIENT_PREFIX then
        return aura_env.handleEncounterClientMessage(message)
    end

    -- handle mythic+ requests by raid leader
    if prefix == KEYS_PREFIX then aura_env.printMythicPlusKey("RAID") end

    -- handle version request messages
    if prefix == VERSION_PREFIX and message == "request" then
        C_ChatInfo.SendAddonMessage(VERSION_PREFIX, VERSION, "WHISPER", sender)
    end
end

--[[ aura_env.parseField

Parse a field from the addon message. Each supported field has a mapped
full-name to be used in the resulting data table, and an optional cast
function.

]] --

local function getIconTexture(n)
    return
        ("|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%d.png:0|t"):format(
            n)
end

local raidIcons = {
    -- named versions (i.e. {circle})
    star = getIconTexture(1),
    circle = getIconTexture(2),
    diamond = getIconTexture(3),
    triangle = getIconTexture(4),
    moon = getIconTexture(5),
    square = getIconTexture(6),
    cross = getIconTexture(7),
    skull = getIconTexture(8),

    -- numeric versions (i.e. {rt3})
    rt1 = getIconTexture(1),
    rt2 = getIconTexture(2),
    rt3 = getIconTexture(3),
    rt4 = getIconTexture(4),
    rt5 = getIconTexture(5),
    rt6 = getIconTexture(6),
    rt7 = getIconTexture(7),
    rt8 = getIconTexture(8),
}

local function parseValue(value)
    if string.match(value, "%d+") then
        return tonumber(value)
    elseif value == "false" then
        return false
    elseif value == "true" then
        return true
    end
    return value
end

local function tochat(value)
    -- value == "CHANNEL MESSAGE", only allow SAY,YELL,RAID
    local channel, message = string.split(" ", value, 2)
    if message and (channel == "SAY" or channel == "YELL" or channel == "RAID") then
        return {channel = channel, message = message}
    end
end

local function tomessage(message)
    message = message:gsub("||", "|") -- restore escape sequences
    for name, texture in pairs(raidIcons) do
        local pattern = ("{(%s)}"):format(name)
        message = message:gsub(pattern, texture)
    end
    return message
end

local function toplayerlist(value)
    local players = {}
    for i, name in ipairs {strsplit(",", value)} do
        players[#players + 1] = strtrim(name)
    end
    return players
end

local function tosound(sound)
    if not sound:find("[/\\]") then
        sound = sound:lower():gsub(" ", "")
        for name, path in pairs(LSM:HashTable("sound")) do
            if sound == name:lower():gsub(" ", "") then return path end
        end
    end
    return sound
end

local addonMessageFields = {
    c = {"chat", tochat},
    d = {"duration", tonumber},
    e = {"emote", tomessage},
    g = {"glow", toplayerlist},
    m = {"message1", tomessage},
    m1 = {"message1", tomessage},
    m2 = {"message2", tomessage},
    m3 = {"message3", tomessage},
    s = {"sound", tosound},
}

aura_env.parseField = function(field, value)
    local name, cast = unpack(addonMessageFields[field] or {})
    if name then return name, (cast or tostring)(value) end
    print(("TMDM-ECWA ERROR: unknown field \"%s\""):format(field))
end

--[[ aura_env.playSound

Plays the requested sound. If the sound was recently played, the request will
be ignored. This helps prevent broken code from breaking people's ears.

]] --

local lastTimePlayed = {}
aura_env.playSound = function(sound)
    local last = lastTimePlayed[sound] or 0
    if GetTime() - last > 1 then
        PlaySoundFile(sound, "Master")
        lastTimePlayed[sound] = GetTime()
    end
end

--[[ aura_env.glowFrame

Glows the unit frame of the given player for a duration of time. If a frame is
not found for the player, nothing is done. If a glow effect is already present
on the frame from this aura, the old effect is canceled first.

]]

local LCG = LibStub("LibCustomGlow-1.0")
aura_env.glowFrame = function(unit, duration)
    local frame = WeakAuras.GetUnitFrame(unit)
    local unglow = nil
    if frame then
        if frame._unglowTimer then
            frame._unglowTimer:Cancel()
            frame._unglow(frame)
        end

        if aura_env.config.glowType == 1 then
            LCG.AutoCastGlow_Start(frame, aura_env.config.glowColor, 12)
            frame._unglow = LCG.AutoCastGlow_Stop
        elseif aura_env.config.glowType == 2 then
            LCG.ButtonGlow_Start(frame, aura_env.config.glowColor)
            frame._unglow = LCG.ButtonGlow_Stop
        else -- glowType == 3
            LCG.PixelGlow_Start(frame, aura_env.config.glowColor)
            frame._unglow = LCG.PixelGlow_Stop
        end

        frame._unglowTimer = C_Timer.NewTimer(duration, function()
            frame._unglow(frame)
            frame._unglow = nil
            frame._unglowTimer = nil
        end)
    end
end

--[[ aura_env.printMythicPlusKey

Print the player's mythic+ key (or the absense of one) to the given channel.

]] --

local KEY_ITEM_ID = 180653
aura_env.printMythicPlusKey = function(channel)
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bag) do
            if (GetContainerItemID(bag, slot) == KEY_ITEM_ID) then
                SendChatMessage(GetContainerItemLink(bag, slot), channel)
                return
            end
        end
    end
    SendChatMessage("no key", channel)
end

