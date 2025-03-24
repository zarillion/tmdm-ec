-------------------------------------------------------------------------------
---------------------------------- UTILITIES ----------------------------------
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

local LOR = LibStub("LibOpenRaid-1.0")

-------------------------------------------------------------------------------

function ns.Contains(values, value)
    for _, v in ipairs(values) do
        if v == value then
            return true
        end
    end
    return false
end

function ns.IndexOf(values, value)
    for i, v in ipairs(values) do
        if v == value then
            return i
        end
    end
    return nil
end

function ns.GetFullUnitName(unit)
    local name, realm = UnitName(unit)
    if name then
        if not realm or realm == "" then
            realm = GetNormalizedRealmName()
        end
        return name .. "-" .. realm
    end
end

function ns.Colorize(name, upper)
    local name, realm = strsplit("-", name)

    local color = "FFBBBBBB"
    local class = UnitClassBase(name)
    if class then
        color = RAID_CLASS_COLORS[class].colorStr
    end

    if realm and realm ~= GetNormalizedRealmName() then
        name = name .. "-" .. realm
    end

    if upper then
        name = string.upper(name)
    end

    return string.format("|c%s%s|r", color, name)
end

function ns.ParseMRTNote()
    if C_AddOns.IsAddOnLoaded("MRT") and VExRT.Note.Text1 then
        local text = VExRT.Note.Text1
        local yaml = false
        local data = ""

        for line in text:gmatch("[^\r\n]+") do
            line = line:gsub("||", "|")
            if line == ">>>" then
                yaml = true
            elseif line == "<<<" then
                return TMDM.YAML.eval(data)
            elseif yaml then
                data = data .. line .. "\r\n"
            end
        end
    end
end

function ns.Frames()
    local i = 0
    local frames = {
        _G["TMDM_MessageFrame"],
        _G["TMDM_SpecialBar"],
        _G["TMDM_DiagramFrame"],
    }
    return function()
        i = i + 1
        if i <= #frames then
            return frames[i]
        end
    end
end

------------------------------- DIAGRAM SHAPES --------------------------------

local Shape = {}

function Shape:Serialize()
    local fields = {
        self.type,
        self.x or "",
        self.y or "",
        self.r or "",
        self.g or "",
        self.b or "",
        self.a or "",
        self.scale or "",
        self.angle or "",
    }
    return strtrim(strjoin(":", unpack(fields)), ":"):gsub(":0%.", ":.")
end

setmetatable(Shape, {
    __call = function(self, object)
        object = object or {}
        setmetatable(object, self)
        self.__index = self
        return object
    end,
})

ns.Shape = Shape

------------------------------- PLAYER SORTING --------------------------------

-- https://github.com/WeakAuras/WeakAuras2/blob/main/WeakAuras/AuraEnvironment.lua#L52
function ns.IterateGroupMembers(reversed, forceParty)
    local unit = (not forceParty and IsInRaid()) and "raid" or "party"
    local numGroupMembers = unit == "party" and GetNumSubgroupMembers() or GetNumGroupMembers()
    local i = reversed and numGroupMembers or (unit == "party" and 0 or 1)
    return function()
        local ret
        if i == 0 and unit == "party" then
            ret = "player"
        elseif i <= numGroupMembers and i > 0 then
            ret = unit .. i
        end
        i = i + (reversed and -1 or 1)
        return ret
    end
end

function ns.UnitSpec(unit)
    local info = LOR.GetUnitInfo(unit)
    if info then
        return info.specId
    end
end

function ns.GUIDSpec(guid)
    local unit = ns.GUIDs[guid]
    if unit then
        return ns.UnitSpec(unit)
    end
end

function ns.SortPlayersBySpec(guids, specs)
    table.sort(guids, function(a, b)
        local specA = ns.GUIDSpec(a) or specs[#specs]
        local specB = ns.GUIDSpec(b) or specs[#specs]
        return ns.IndexOf(specs, specA) < ns.IndexOf(specs, specB)
    end)
end
