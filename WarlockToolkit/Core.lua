local ADDON, ns = ...
_G.WarlockToolkit = ns

ns.moduleList = {}
ns.modules = {}
ns.icons = {}
ns.ready = false

local L_PREFIX = "|cff9482c9Warlock Toolkit|r: "
function ns.Print(...) print(L_PREFIX .. string.format(...)) end

------------------------------------------------------------------------
-- Defaults
------------------------------------------------------------------------
local function Icon(x, y, extra)
    local t = {
        enabled = true, locked = false, size = 40,
        point = { "CENTER", "CENTER", x, y },
        glow = true, glowColor = { 1, 0.82, 0, 1 },
        sound = false, soundName = "RAID_WARNING",
    }
    for k, v in pairs(extra or {}) do t[k] = v end
    return t
end

ns.defaults = {
    preview = false,
    previewCombat = false, -- show the in-combat look (opacity, highlight, hiding) out of combat
    glowStyle = "proc",
    glowMode = "outline",
    fillAlpha = 0.4,
    moveWith = "right",
    snap = { enabled = true, distance = 10, gap = 2 },
    -- Opacity of all addon frames in / out of combat; click-through in combat.
    combat = { clickThrough = false, alpha = 1, idleAlpha = 1, glow = true, hide = false },
    minimap = { hide = false, locked = false, angle = 215 },
    armor = Icon(-135, 160),
    healthstone = Icon(-90, 160),
    soulstone = Icon(-45, 160, {
        createWhileApplied = false,
        states = {
            use    = { glow = true, glowColor = { 1, 0.82, 0, 1 }, sound = false, soundName = "READY_CHECK" },
            create = { glow = true, glowColor = { 1, 0.1, 0.1, 1 }, sound = false, soundName = "RAID_WARNING" },
        },
    }),
    pet = Icon(0, 160, {
        -- "none" = plain click; other keys are modifier prefixes. Value "default" = same as plain click.
        bindings = { none = "imp", shift = "voidwalker", ctrl = "succubus", alt = "felhunter", meta = "default" },
    }),
    soulstoneLabel = {
        enabled = true, locked = false,
        point = { "CENTER", "CENTER", -45, 120 },
        font = "Fonts\\FRIZQT__.TTF", outline = "OUTLINE",
        nameSize = 14, timerSize = 12,
        showIcon = true, bgAlpha = 0.3, showSelf = true,
    },
    shards = {
        enabled = true, locked = false,
        point = { "CENTER", "CENTER", 60, 160 },
        showIcon = true, iconSize = 32, bgAlpha = 0.3,
        font = "Fonts\\FRIZQT__.TTF", fontSize = 20, outline = "OUTLINE",
        color = { 1, 1, 1, 1 }, lowColor = { 1, 0.25, 0.25, 1 },
        showDesired = true,
        autoThreshold = true, threshold = 3,
        spare = 1, includeRitual = false,
        glow = true, glowColor = { 1, 0.2, 0.2, 1 },
        sound = false, soundName = "RAID_WARNING",
    },
}

local function CopyDefaults(src, dst)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then dst[k] = {} end
            CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
    return dst
end

function ns:ResetDB()
    wipe(WarlockToolkitDB)
    CopyDefaults(self.defaults, WarlockToolkitDB)
    self:ApplyAll()
end

------------------------------------------------------------------------
-- Events
------------------------------------------------------------------------
local eventFrame = CreateFrame("Frame")
local handlers = {}

function ns:RegisterEvent(event, fn)
    if not handlers[event] then
        -- Unknown events throw on the Forever client, so register defensively.
        if not pcall(eventFrame.RegisterEvent, eventFrame, event) then return false end
        handlers[event] = {}
    end
    table.insert(handlers[event], fn)
    return true
end

eventFrame:SetScript("OnEvent", function(_, event, ...)
    local list = handlers[event]
    if not list then return end
    for i = 1, #list do
        xpcall(list[i], geterrorhandler(), event, ...)
    end
end)

------------------------------------------------------------------------
-- Modules
------------------------------------------------------------------------
function ns:NewModule(name)
    local m = { name = name }
    self.modules[name] = m
    table.insert(self.moduleList, m)
    return m
end

function ns:UpdateAll()
    if not self.active then return end
    for _, m in ipairs(self.moduleList) do
        if m.Update then xpcall(m.Update, geterrorhandler(), m) end
    end
end

-- Re-apply settings (sizes, fonts, positions) and refresh state.
function ns:ApplyAll()
    if not self.active then return end
    for _, m in ipairs(self.moduleList) do
        if m.ApplySettings then xpcall(m.ApplySettings, geterrorhandler(), m) end
    end
    self:UpdateAll()
end

function ns:TogglePreviewCombat()
    self.db.previewCombat = not self.db.previewCombat
    self:ApplyAll()
    self.Print("simulated combat look %s.", self.db.previewCombat and "on" or "off")
end

function ns:SetAllLocked(locked)
    for _, key in ipairs({ "armor", "healthstone", "soulstone", "pet", "soulstoneLabel", "shards", "minimap" }) do
        self.db[key].locked = locked
    end
    self:ApplyAll()
end

-- Classic Era, Forever and TBC keep Soul Shards as bag items. From Cataclysm on
-- (Mists, Retail) they are a resource with its own game UI, so there's no shard counter.
ns.SHARD_ITEMS = select(4, GetBuildInfo()) < 40000

------------------------------------------------------------------------
-- Helpers: spells, items, auras, secrets
------------------------------------------------------------------------
function ns.IsSecret(v)
    return issecretvalue ~= nil and issecretvalue(v) or false
end

function ns.IsKnown(id)
    if not id then return false end
    if IsPlayerSpell then
        local ok, r = pcall(IsPlayerSpell, id)
        if ok and r then return true end
    end
    if C_SpellBook and C_SpellBook.IsSpellKnown then
        local ok, r = pcall(C_SpellBook.IsSpellKnown, id)
        if ok and r then return true end
    end
    if IsSpellKnown then
        local ok, r = pcall(IsSpellKnown, id)
        if ok and r then return true end
    end
    return false
end

function ns.SpellName(id)
    if C_Spell and C_Spell.GetSpellName then return C_Spell.GetSpellName(id) end
    if GetSpellInfo then return (GetSpellInfo(id)) end
end

function ns.SpellTexture(id)
    if C_Spell and C_Spell.GetSpellTexture then return C_Spell.GetSpellTexture(id) end
    if GetSpellTexture then return GetSpellTexture(id) end
end

function ns.ItemIcon(id)
    if C_Item and C_Item.GetItemIconByID then return C_Item.GetItemIconByID(id) end
    if GetItemIcon then return GetItemIcon(id) end
end

function ns.ItemCount(id)
    local f = (C_Item and C_Item.GetItemCount) or GetItemCount
    local ok, n = pcall(f, id)
    if ok and type(n) == "number" and not ns.IsSecret(n) then return n end
    return 0
end

-- Highest known spell from a rank list (ids or {spell=id} entries).
-- Falls back to a lookup by localized name in case Forever uses different IDs.
local knownCache = {}
function ns.HighestKnown(list)
    local cached = knownCache[list]
    if cached ~= nil then
        if cached == false then return nil end
        return cached[1], cached[2]
    end
    local function idAt(i) local e = list[i]; return type(e) == "table" and e.spell or e end
    local function nameAt(i) local e = list[i]; return ns.SpellName(idAt(i)) or (type(e) == "table" and e.name) end
    for i = #list, 1, -1 do
        if ns.IsKnown(idAt(i)) then
            knownCache[list] = { idAt(i), i }
            return idAt(i), i
        end
    end
    if C_Spell and C_Spell.GetSpellInfo then
        for i = #list, 1, -1 do
            local name = nameAt(i)
            local ok, info = pcall(C_Spell.GetSpellInfo, name or "")
            if ok and info and info.spellID and ns.IsKnown(info.spellID) then
                knownCache[list] = { info.spellID, i }
                return info.spellID, i
            end
        end
    end
    knownCache[list] = false
end

function ns.ResetKnownCache() wipe(knownCache) end

-- Spell ID of a learned demon summon (see ns.data.demons), or nil.
function ns.DemonSpell(demon)
    if not demon then return nil end
    demon.list = demon.list or { demon }
    return (ns.HighestKnown(demon.list))
end

-- true / false, or nil when auras are unreadable (secret in combat).
function ns.PlayerHasAura(ids)
    if not C_UnitAuras then return nil end
    local unknown = false
    for _, id in ipairs(ids) do
        local ok, aura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, id)
        if not ok then unknown = true elseif aura then return true end
    end
    if C_UnitAuras.GetAuraDataBySpellName then
        for _, id in ipairs(ids) do
            local name = ns.SpellName(id)
            if name then
                local ok, aura = pcall(C_UnitAuras.GetAuraDataBySpellName, "player", name, "HELPFUL")
                if not ok then unknown = true elseif aura then return true end
            end
        end
    end
    if unknown then return nil end
    return false
end

function ns.AurasSecret()
    if InCombatLockdown() then return true end
    if C_Secrets and C_Secrets.ShouldAurasBeSecret then
        local ok, s = pcall(C_Secrets.ShouldAurasBeSecret)
        if ok and s then return true end
    end
    return false
end

------------------------------------------------------------------------
-- Boot
------------------------------------------------------------------------
ns:RegisterEvent("ADDON_LOADED", function(_, name)
    if name ~= ADDON then return end
    WarlockToolkitDB = WarlockToolkitDB or {}
    WarlockToolkitCharDB = WarlockToolkitCharDB or {}
    CopyDefaults(ns.defaults, WarlockToolkitDB)
    ns.db = WarlockToolkitDB
    ns.cdb = WarlockToolkitCharDB
end)

ns:RegisterEvent("PLAYER_LOGIN", function()
    local _, class = UnitClass("player")
    if class ~= "WARLOCK" then
        -- Not a Warlock: nothing is created, everything stays disabled.
        ns.active = false
        return
    end
    ns.active = true
    for _, m in ipairs(ns.moduleList) do
        if m.Init then xpcall(m.Init, geterrorhandler(), m) end
    end
    if ns.InitOptions then ns.InitOptions() end
    ns:ApplyAll()
    C_Timer.NewTicker(1, function() ns:UpdateAll() end)
end)

ns:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    if not ns.active then return end
    ns.ResetKnownCache()
    ns:UpdateAll()
    -- Don't fire alert sounds for the state found right after loading.
    C_Timer.After(3, function() ns.ready = true end)
end)

ns:RegisterEvent("SPELLS_CHANGED", function()
    if not ns.active then return end
    ns.ResetKnownCache()
    ns:UpdateAll()
end)

ns:RegisterEvent("BAG_UPDATE_DELAYED", function() ns:UpdateAll() end)

-- Fires right before combat lockdown: last chance to show protected icons so
-- they can still appear (via alpha) during combat.
ns:RegisterEvent("PLAYER_REGEN_DISABLED", function()
    ns.inCombat = true
    ns:UpdateAll()
    for _, b in ipairs(ns.icons) do b:PrepareForCombat() end
end)

ns:RegisterEvent("PLAYER_REGEN_ENABLED", function()
    ns.inCombat = false
    ns:ApplyAll()
end)

-- Lowest opacity allowed in combat: an (almost) invisible icon would still catch clicks.
ns.MIN_COMBAT_ALPHA = 0.2

-- Real combat, or the "simulate combat" preview (looks and click-through).
function ns.CombatLook()
    return ns.inCombat or (ns.db and ns.db.previewCombat) or false
end

-- Opacity for addon frames in the current combat state.
function ns.FrameAlpha()
    local c = ns.db.combat
    if ns.CombatLook() then return math.max(c.alpha, ns.MIN_COMBAT_ALPHA) end
    return c.idleAlpha
end

-- Whether addon frames should ignore the mouse right now.
function ns.ClickThrough()
    return ns.CombatLook() and ns.db.combat.clickThrough
end

------------------------------------------------------------------------
-- Slash commands
------------------------------------------------------------------------
SLASH_WARLOCKTOOLKIT1 = "/wlt"
SLASH_WARLOCKTOOLKIT2 = "/warlocktoolkit"
SlashCmdList.WARLOCKTOOLKIT = function(msg)
    if not ns.active then
        ns.Print("disabled: this character is not a Warlock.")
        return
    end
    msg = (msg or ""):lower():match("^%s*(.-)%s*$")
    if msg == "lock" then
        ns:SetAllLocked(true); ns.Print("all frames locked.")
    elseif msg == "unlock" then
        ns:SetAllLocked(false); ns.Print("all frames unlocked (%s icons to move).", ns.MoveModeText():lower())
    elseif msg == "preview" then
        ns.db.preview = not ns.db.preview; ns:ApplyAll()
        ns.Print("preview %s.", ns.db.preview and "on" or "off")
    elseif msg == "combat" then
        ns:TogglePreviewCombat()
    elseif msg == "reset" then
        if InCombatLockdown() then ns.Print("cannot reset in combat."); return end
        ns:ResetDB(); ns.Print("settings reset.")
    else
        ns.ToggleOptions()
    end
end
