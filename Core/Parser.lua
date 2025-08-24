-------------------------------------------------------------------------------
------------------------------- MESSAGE PARSER --------------------------------
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

local function tospecialbar(value)
    -- value == "UNIT:RESOURCE[:TIMER][:R:G:B:A]"
    if value == "" then
        return { timer = 0 }
    end
    local unit, resource, timer, r, g, b, a = strsplit(":", value)
    return {
        unit = unit,
        resource = tonumber(resource),
        timer = tonumber(timer),
        color = {
            r = tonumber(r),
            g = tonumber(g),
            b = tonumber(b),
            a = tonumber(a) or 1,
        },
    }
end

local function tochat(value)
    -- value == "CHANNEL [TARGET] MESSAGE"; TARGET only set for WHISPER channel
    local channel, message = strsplit(":", value, 2)
    local target = nil

    if #channel > 0 and #message > 0 then
        if channel == "WHISPER" then
            target, message = strsplit(":", message, 2)
        end
        return { channel = channel, message = message, target = target }
    end
end

local function tofilters(value)
    -- value == TARGET,TARGET,TARGET
    local filters = {
        players = {},
        roles = {},
        classes = {},
        specs = {},
    }

    for _, filter in ipairs({ strsplit(",", value) }) do
        if filter:find(":") then
            local type, target = strsplit(":", filter)
            if type == "r" then
                table.insert(filters.roles, target)
            elseif type == "c" then
                table.insert(filters.classes, target)
            elseif type == "s" then
                table.insert(filters.specs, target)
            end
        else
            local name, _ = strsplit("-", filter) -- remove realm if present
            table.insert(filters.players, name)
        end
    end

    return filters
end

local function toglows(value)
    -- value == glow,glow,glow
    -- glow = unit:[type=1]:[r:g:b:a]:[freq]:[scale]
    local glows = {}
    for i, glow in ipairs({ strsplit(",", value) }) do
        local unit, type, r, g, b, a, freq, scale = strsplit(":", glow)

        glows[i] = {
            unit = strtrim(unit),
            type = abs(tonumber(type) or 1),
            frequency = tonumber(freq),
            scale = tonumber(scale),
            nameplate = (tonumber(type) or 1) < 0,
        }

        local rn = tonumber(r)
        local gn = tonumber(g)
        local bn = tonumber(b)
        local an = tonumber(a)

        if rn and gn and bn then
            glows[i].color = { rn, gn, bn, an or 1 }
        end
    end
    return glows
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

local function totexts(value)
    -- value == "text,text,text"
    -- text == "TEXT[:x:y:size:angle]"
    local texts = {}
    for i, v in ipairs({ strsplit(",", value) }) do
        local text, x, y, size, angle = strsplit(":", v)
        texts[i] = {
            text = text,
            position = {
                x = tonumber(x) or 0,
                y = tonumber(y) or 0,
            },
            size = tonumber(size) or 20,
            angle = tonumber(angle) or 0,
        }
    end
    return texts
end

local addonMessageFields = {
    b = { "bar", tospecialbar },
    c = { "chat", tochat },
    d = { "duration", tonumber },
    e = { "emote", tostring },
    f = { "filters", tofilters },
    g = { "glows", toglows },
    m = { "message2", tostring },
    m1 = { "message1", tostring },
    m2 = { "message2", tostring },
    m3 = { "message3", tostring },
    s = { "sound", tostring },
    l = { "lines", tolines },
    z = { "shapes", toshapes },
    t = { "texts", totexts },
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
    addonMessage = addonMessage:gsub("||", "|") -- restore escape sequences

    -- convert the message to a table of instructions
    local data = {}
    for i, chunk in ipairs({ strsplit(";", addonMessage) }) do
        local field, value = parseField(strsplit("=", chunk, 2))
        if field and value then
            data[field] = value
        end
    end

    if data.filters then
        if not ns.actions:IsMessageRecipient(data.filters) then
            return -- this message aint for us
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

    if data.glows then
        for _, glow in ipairs(data.glows) do
            ns.actions:FrameGlow(glow, data.duration or 5)
        end
    end

    if data.bar then
        ns.actions:SpecialBar(data.bar)
    end

    if data.lines or data.shapes or data.texts then
        ns.actions:Diagram(data.lines, data.shapes, data.texts, data.duration or 5)
    end

    for i = 1, 3 do
        if data["message" .. i] then
            ns.actions:BannerMessage(i, data["message" .. i], data.duration or 5)
        end
    end
end

local VALID_CHANNELS = { "PARTY", "RAID", "WHISPER" }

--[[ HandleMessage

Only allow messages from the PARTY, RAID and WHISPER channels, and only if they
originate from the current group leader. All other messages are assumed to be
malicious and ignored.

]]
function ns.addon.HandleMessage(message, channel, sender)
    if not ns.locked then
        return -- ignore messages while frames are unlocked
    end

    local name, _ = strsplit("-", sender)
    local fromSelf = name == UnitName("player") -- for testing
    local validChannel = ns.Contains(VALID_CHANNELS, channel)
    if validChannel and (fromSelf or UnitIsGroupLeader(name)) then
        return processMessage(message)
    end
end

local MESSAGE_PREFIXES = { "TMDMv1", "TMDM_ECWAv1" } -- backward compat

for _, prefix in ipairs(MESSAGE_PREFIXES) do
    -- Register the user's client to send/receive our addon messages
    C_ChatInfo.RegisterAddonMessagePrefix(prefix)
    ns.prefixes[prefix] = ns.addon.HandleMessage
end
