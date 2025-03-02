-------------------------------------------------------------------------------
----------------------------------- ACTIONS -----------------------------------
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

ns.actions = {}

local LCG = LibStub("LibCustomGlow-1.0")
local LGF = LibStub("LibGetFrame-1.0")
local LSM = LibStub("LibSharedMedia-3.0")

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
    if not sound:find("[/\\]") then
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

-- TODO: Create TMDM config UI for these
local GLOW_TYPE = 3 -- 2,3
local GLOW_COLOR = { 0.95, 0.95, 0.32, 1 } -- yellowish

LGF.ScanForUnitFrames()

function ns.actions:FrameGlow(unit, duration)
    local frame = LGF.GetUnitFrame(unit)
    if frame then
        if frame._unglowTimer then
            frame._unglowTimer:Cancel()
            frame._unglow(frame)
        end

        if GLOW_TYPE == 1 then
            LCG.AutoCastGlow_Start(frame, GLOW_COLOR, 12)
            frame._unglow = LCG.AutoCastGlow_Stop
        elseif GLOW_TYPE == 2 then
            LCG.ButtonGlow_Start(frame, GLOW_COLOR)
            frame._unglow = LCG.ButtonGlow_Stop
        else -- glowType == 3
            LCG.PixelGlow_Start(frame, GLOW_COLOR)
            frame._unglow = LCG.PixelGlow_Stop
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
    return ("|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_%d.png:0|t"):format(n)
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
    message = message:gsub("||", "|") -- restore escape sequences
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

function ns.actions:SpecialBar(unit, resource, timer)
    local frame = _G["TMDM_SpecialBar"]
    if timer == 0 then
        frame:Stop()
    else
        frame:Init(unit, resource, timer)
    end
end

-------------------------------------------------------------------------------

local SHAPES = {
    c = "Interface\\Addons\\" .. ADDON_NAME .. "\\Resources\\Textures\\circle.png",
    x = "Interface\\Addons\\" .. ADDON_NAME .. "\\Resources\\Textures\\cross.png",
    d = "Interface\\Addons\\" .. ADDON_NAME .. "\\Resources\\Textures\\diamond.png",
    y = "Interface\\Addons\\" .. ADDON_NAME .. "\\Resources\\Textures\\heptagon.png",
    h = "Interface\\Addons\\" .. ADDON_NAME .. "\\Resources\\Textures\\hexagon.png",
    m = "Interface\\Addons\\" .. ADDON_NAME .. "\\Resources\\Textures\\moon.png",
    o = "Interface\\Addons\\" .. ADDON_NAME .. "\\Resources\\Textures\\octogon.png",
    p = "Interface\\Addons\\" .. ADDON_NAME .. "\\Resources\\Textures\\pentagon.png",
    s = "Interface\\Addons\\" .. ADDON_NAME .. "\\Resources\\Textures\\star.png",
    t = "Interface\\Addons\\" .. ADDON_NAME .. "\\Resources\\Textures\\triangle.png",
    g = "Interface\\Addons\\" .. ADDON_NAME .. "\\Resources\\Textures\\tmdm.png",
    -- q = square
    -- l = line
}

function ns.actions:Diagram(lines, shapes, duration)
    for _, shape in ipairs(shapes) do
        shape.texture = SHAPES[shape.type]
    end
    local frame = _G["TMDM_DiagramFrame"]
    frame:Display(lines, shapes, duration)
end
