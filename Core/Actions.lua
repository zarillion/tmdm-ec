-------------------------------------------------------------------------------
----------------------------------- ACTIONS -----------------------------------
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

ns.actions = {}

local LCG = LibStub("LibCustomGlow-1.0")
local LGF = LibStub("LibGetFrame-1.0")
local LSM = LibStub("LibSharedMedia-3.0")

-------------------------------------------------------------------------------

local MELEE = { 65, 66, 70, 71, 72, 73, 103, 104, 250, 251, 252, 255, 259, 260, 261, 263, 268, 269, 270, 577, 581 }
local RANGED = { 62, 63, 64, 102, 105, 253, 254, 256, 257, 258, 262, 264, 265, 266, 267, 1467, 1468, 1473 }

function ns.actions:IsMessageRecipient(filters)
    -- Check players
    if ns.Contains(filters.players, UnitName("player")) then
        return true
    end

    -- Check classes
    if ns.Contains(filters.classes, select(2, UnitClass("player"))) then
        return true
    end

    -- Check specs
    local spec, _, _, _, role = GetSpecializationInfo(GetSpecialization())
    if ns.Contains(filters.specs, spec) then
        return true
    end

    -- Check roles
    if ns.Contains(filters.roles, role) then
        return true
    elseif ns.Contains(filters.roles, "MELEE") and ns.Contains(MELEE, spec) then
        return true
    elseif ns.Contains(filters.roles, "RANGED") and ns.Contains(RANGED, spec) then
        return true
    end

    return false
end

-------------------------------------------------------------------------------

function ns.actions:ChatMessage(message, channel, target)
    SendChatMessage(message, channel, nil, target)
end

-------------------------------------------------------------------------------

function ns.actions:EmoteMessage(message)
    local emote = ChatTypeInfo["EMOTE"]
    DEFAULT_CHAT_FRAME:AddMessage(message, emote.r, emote.g, emote.b)
end

-------------------------------------------------------------------------------

local function ResolveSoundPath(sound)
    if not (sound:match("^%d+$") or sound:find("[/\\]")) then
        sound = sound:lower():gsub(" ", "")
        for name, path in pairs(LSM:HashTable("sound")) do
            if sound == name:lower():gsub(" ", "") then
                return path
            end
        end
    end

    return sound
end

local LAST_PLAYED = {}

function ns.actions:SoundFile(sound)
    -- sound = FileDataID, sound name or sound file path
    sound = ResolveSoundPath(sound)

    local last = LAST_PLAYED[sound] or 0
    if GetTime() - last > 1 then
        PlaySoundFile(sound, "Master")
        LAST_PLAYED[sound] = GetTime()
    end
end

-------------------------------------------------------------------------------

local GLOW_COLOR = { 0.95, 0.95, 0.32, 1 } -- yellowish

function ns.actions:FrameGlow(glow, duration)
    local frame = LGF.GetUnitFrame(glow.unit)
    if frame then
        if frame._unglowTimer then
            frame._unglowTimer:Cancel()
            frame._unglow(frame)
        end

        local color = glow.color or GLOW_COLOR

        if glow.type == 1 then
            LCG.PixelGlow_Start(frame, color, nil, glow.frequency, nil, glow.scale)
            frame._unglow = LCG.PixelGlow_Stop
        elseif glow.type == 2 then
            LCG.AutoCastGlow_Start(frame, color, 12, glow.frequency, glow.scale)
            frame._unglow = LCG.AutoCastGlow_Stop
        else -- glow.type == 3
            LCG.ButtonGlow_Start(frame, color, glow.frequency)
            frame._unglow = LCG.ButtonGlow_Stop
        end

        frame._unglowTimer = C_Timer.NewTimer(duration, function()
            frame._unglow(frame)
            frame._unglow = nil
            frame._unglowTimer = nil
        end)
    end
end

-------------------------------------------------------------------------------

local function getIconTexture(n)
    return ("|TInterface/TARGETINGFRAME/UI-RaidTargetingIcon_%d.png:0|t"):format(n)
end

local RAID_ICONS = {
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

local function RenderMessage(message)
    for name, texture in pairs(RAID_ICONS) do
        local pattern = ("{(%s)}"):format(name)
        message = message:gsub(pattern, texture)
    end
    return message
end

function ns.actions:BannerMessage(index, message, duration)
    local frame = _G["TMDM_MessageFrame"]
    frame:Display(index, RenderMessage(message), duration)
end

-------------------------------------------------------------------------------

function ns.actions:SpecialBar(data)
    local frame = _G["TMDM_SpecialBar"]
    if data.timer == 0 then
        frame:Stop()
    elseif data.unit ~= "" then
        frame:DisplayUnit(data.unit, data.resource, data.timer, data.color)
    elseif data.timer then
        frame:DisplayTimer(data.timer, data.color)
    end
end

-------------------------------------------------------------------------------

local TEXTURES = "Interface/Addons/" .. ADDON_NAME .. "/Resources/Textures/"
local SHAPES = {
    c = TEXTURES .. "circle.png",
    x = TEXTURES .. "cross.png",
    d = TEXTURES .. "diamond.png",
    y = TEXTURES .. "heptagon.png",
    h = TEXTURES .. "hexagon.png",
    m = TEXTURES .. "moon.png",
    o = TEXTURES .. "octogon.png",
    p = TEXTURES .. "pentagon.png",
    s = TEXTURES .. "star.png",
    t = TEXTURES .. "triangle.png",
    g = TEXTURES .. "tmdm.png",
    -- q = square
    rt1 = "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_1.png",
    rt2 = "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_2.png",
    rt3 = "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_3.png",
    rt4 = "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_4.png",
    rt5 = "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_5.png",
    rt6 = "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_6.png",
    rt7 = "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_7.png",
    rt8 = "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_8.png",
}

function ns.actions:Diagram(lines, shapes, texts, duration)
    if shapes then
        for _, shape in ipairs(shapes) do
            if shape.type:match("^%-?%d+$") then
                local id = tonumber(shape.type)
                if id and id > 0 then
                    shape.texture = id
                elseif id then
                    shape.texture = TEXTURES .. string.format("DB/%03d.png", abs(id))
                end
            else
                shape.texture = SHAPES[shape.type]
            end
        end
    end
    local frame = _G["TMDM_DiagramFrame"]
    frame:Display(lines, shapes, texts, duration)
end
