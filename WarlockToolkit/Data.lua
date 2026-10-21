local _, ns = ...

-- Spell / item IDs. Lists are ordered lowest rank -> highest rank (Classic Era, then TBC ranks).
-- Unknown IDs are harmless: only learned spells are used. New ranks or stones can be added here.
ns.data = {
    SOUL_SHARD = 6265,

    armor = {
        felArmor   = { 28176, 28189 },                            -- TBC; preferred when learned
        demonArmor = { 706, 1086, 11733, 11734, 11735, 27260 },
        demonSkin  = { 687, 696 },
    },
    armorDuration = 1800, -- all three last 30 minutes

    -- Demons the Pet icon can summon. `shard` = costs a Soul Shard.
    -- `list` holds replacements, last learned wins: Grimoire of Supremacy (Mists), Sayaad (Retail).
    demons = {
        { key = "imp",        spell = 688,   shard = false, list = { 688, 112866 } },
        { key = "voidwalker", spell = 697,   shard = true,  list = { 697, 112867 } },
        { key = "succubus",   spell = 712,   shard = true,  list = { 712, 112868, { spell = 366222, name = "Summon Sayaad" } } },
        { key = "felhunter",  spell = 691,   shard = true,  list = { 691, 112869 } },
        -- Not in Classic Era; `name` lets the addon find it by name if Forever uses another ID.
        { key = "incubus",    spell = 365349, shard = true, name = "Summon Incubus" },
        { key = "felguard",   spell = 30146, shard = true,  list = { 30146, 112870 } },
    },

    -- Grimoire of Sacrifice buff (Mists, Retail): the demon is sacrificed on purpose.
    petSacrificeBuffs = { 108503, 196099 },

    -- The counter shows once Soul Shards can be gained.
    drainSoul = { 1120, 8288, 8289, 11675, 27217 },

    ritualOfSummoning = 698,

    -- Before Cataclysm every stone costs one Soul Shard to create.
    -- Mists and Retail only keep Create Healthstone (6201, item 5512).
    stones = {
        healthstone = {
            { spell = 6201,  items = { 5512, 19004, 19005, 224464 } }, -- Minor; Healthstone / Demonic Healthstone in Retail
            { spell = 6202,  items = { 5511, 19006, 19007 } }, -- Lesser
            { spell = 5699,  items = { 5509, 19008, 19009 } }, -- Healthstone
            { spell = 11729, items = { 5510, 19010, 19011 } }, -- Greater
            { spell = 11730, items = { 9421, 19012, 19013 } }, -- Major
            { spell = 27230, items = { 22103, 22104, 22105 } }, -- Master (TBC)
        },
        soulstone = {
            { spell = 693,   items = { 5232 } },  -- Minor
            { spell = 20752, items = { 16892 } }, -- Lesser
            { spell = 20755, items = { 16893 } }, -- Soulstone
            { spell = 20756, items = { 16895 } }, -- Greater
            { spell = 20757, items = { 16896 } }, -- Major
            { spell = 27238, items = { 22116 } }, -- Master (TBC)
        },
        firestone = {
            { spell = 6366,  items = { 1254 } },  -- Lesser
            { spell = 17951, items = { 13699 } }, -- Firestone
            { spell = 17952, items = { 13700 } }, -- Greater
            { spell = 17953, items = { 13701 } }, -- Major
            { spell = 27250, items = { 22128 } }, -- Master (TBC)
        },
        spellstone = {
            { spell = 2362,  items = { 5522 } },  -- Spellstone
            { spell = 17727, items = { 13602 } }, -- Greater
            { spell = 17728, items = { 13603 } }, -- Major
            { spell = 28172, items = { 22646 } }, -- Master (TBC)
        },
    },
    stoneOrder = { "healthstone", "soulstone", "firestone", "spellstone" },

    -- "Soulstone Resurrection" buff applied by using a Soulstone item.
    soulstoneBuffs = { 20707, 20762, 20763, 20764, 20765, 27239 },
    soulstoneDuration = 1800,
    -- Mists and Retail: Soulstone is a spell cast straight on the target (same ID as the buff).
    soulstoneSpell = 20707,
    soulstoneSpellDuration = 900,
}
