-- LuaFormatter off
ignore = {"ADDON_NAME"}
max_line_length = false
redefined = false
unused_args = false

read_globals = {
    -- LUA / helper functions
    "strtrim",

    -- WoW API functions
    "GetAddOnMetadata",
    "UnitName",
    "UnitIsGroupLeader",

    -- WoW Widget Functions

    -- WoW UI Frames & Mixins

    -- WoW Global variables
    "C_ChatInfo",

    -- Third-Party libraries/addons
    "LibStub",
}

globals = {}

-- LuaFormatter on
