-------------------------------------------------------------------------------
---------------------------------- UTILITIES ----------------------------------
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

function ns.Contains(values, value)
    for _, v in ipairs(values) do
        if v == value then
            return true
        end
    end
    return false
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
