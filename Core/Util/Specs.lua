-------------------------------------------------------------------------------
------------------------------- SPEC UTILITIES --------------------------------
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------

ns.SPECS = {}

ns.SPECS.POSITION = {
    [62] = "RANGED", -- Arcane Mage
    [63] = "RANGED", -- Fire Mage
    [64] = "RANGED", -- Frost Mage
    [65] = "MELEE", -- Holy Paladin
    [66] = "MELEE", -- Protection Paladin
    [70] = "MELEE", -- Retribution Paladin
    [71] = "MELEE", -- Arms Warrior
    [72] = "MELEE", -- Fury Warrior
    [73] = "MELEE", -- Protection Warrior
    [102] = "RANGED", -- Balance Druid
    [103] = "MELEE", -- Feral Druid
    [104] = "MELEE", -- Guardian Druid
    [105] = "RANGED", -- Restoration Druid
    [250] = "MELEE", -- Blood Death Knight
    [251] = "MELEE", -- Frost Death Knight
    [252] = "MELEE", -- Unholy Death Knight
    [253] = "RANGED", -- Beast Mastery Hunter
    [254] = "RANGED", -- Marksmanship Hunter
    [255] = "MELEE", -- Survival Hunter
    [256] = "RANGED", -- Discipline Priest
    [257] = "RANGED", -- Holy Priest
    [258] = "RANGED", -- Shadow Priest
    [259] = "MELEE", -- Assassination Rogue
    [260] = "MELEE", -- Outlaw Rogue
    [261] = "MELEE", -- Subtlety Rogue
    [262] = "RANGED", -- Elemental Shaman
    [263] = "MELEE", -- Enhancement Shaman
    [264] = "RANGED", -- Restoration Shaman
    [265] = "RANGED", -- Affliction Warlock
    [266] = "RANGED", -- Demonology Warlock
    [267] = "RANGED", -- Destruction Warlock
    [268] = "MELEE", -- Brewmaster Monk
    [269] = "MELEE", -- Windwalker Monk
    [270] = "MELEE", -- Mistweaver Monk
    [577] = "MELEE", -- Havoc Demon Hunter
    [581] = "MELEE", -- Vengeance Demon Hunter
    [1467] = "RANGED", -- Devastation Evoker
    [1468] = "RANGED", -- Preservation Evoker
    [1473] = "RANGED", -- Augmentation Evoker
}

-- Class spec IDs by mobility
ns.SPECS.MOBILITY = {

    -- Mobility by position
    POSITION = {
        RANGED = {
            62, -- Arcane Mage
            63, -- Fire Mage
            64, -- Frost Mage
            253, -- Beast Mastery Hunter
            254, -- Marksmanship Hunter
            1467, -- Devastation Evoker
            1468, -- Preservation Evoker
            1473, -- Augmentation Evoker
            102, -- Balance Druid
            105, -- Restoration Druid
            262, -- Elemental Shaman
            264, -- Restoration Shaman
            265, -- Affliction Warlock
            266, -- Demonology Warlock
            267, -- Destruction Warlock
            258, -- Shadow Priest
            256, -- Discipline Priest
            257, -- Holy Priest
        },

        MELEE = {
            577, -- Havoc Demon Hunter
            581, -- Vengeance Demon Hunter
            268, -- Brewmaster Monk
            269, -- Windwalker Monk
            270, -- Mistweaver Monk
            260, -- Outlaw Rogue
            71, -- Arms Warrior
            72, -- Fury Warrior
            73, -- Protection Warrior
            255, -- Survival Hunter
            259, -- Assassination Rogue
            261, -- Subtlety Rogue
            103, -- Feral Druid
            104, -- Guardian Druid
            263, -- Enhancement Shaman
            65, -- Holy Paladin
            66, -- Protection Paladin
            70, -- Retribution Paladin
            250, -- Blood Death Knight
            251, -- Frost Death Knight
            252, -- Unholy Death Knight
        },
    },

    -- Mobility by role
    ROLE = {
        HEALER = {
            270, -- Mistweaver Monk
            1468, -- Preservation Evoker
            105, -- Restoration Druid
            65, -- Holy Paladin
            264, -- Restoration Shaman
            256, -- Discipline Priest
            257, -- Holy Priest
        },

        RANGED = {
            62, -- Arcane Mage
            63, -- Fire Mage
            64, -- Frost Mage
            253, -- Beast Mastery Hunter
            254, -- Marksmanship Hunter
            1467, -- Devastation Evoker
            1473, -- Augmentation Evoker
            102, -- Balance Druid
            262, -- Elemental Shaman
            265, -- Affliction Warlock
            266, -- Demonology Warlock
            267, -- Destruction Warlock
            258, -- Shadow Priest
        },

        MELEE = {
            577, -- Havoc Demon Hunter
            269, -- Windwalker Monk
            260, -- Outlaw Rogue
            71, -- Arms Warrior
            72, -- Fury Warrior
            255, -- Survival Hunter
            259, -- Assassination Rogue
            261, -- Subtlety Rogue
            103, -- Feral Druid
            263, -- Enhancement Shaman
            70, -- Retribution Paladin
            251, -- Frost Death Knight
            252, -- Unholy Death Knight
        },

        TANK = {
            581, -- Vengeance Demon Hunter
            268, -- Brewmaster Monk
            73, -- Protection Warrior
            104, -- Guardian Druid
            66, -- Protection Paladin
            250, -- Blood Death Knight
        },
    },
}
