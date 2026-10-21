local _, ns = ...
local D = ns.data
local M = ns:NewModule("pet")

-- Binding slots: key in db.pet.bindings -> secure attribute prefix.
M.SLOTS = {
    { key = "none",  prefix = "",       text = "Click" },
    { key = "shift", prefix = "shift-", text = "Shift + Click" },
    { key = "ctrl",  prefix = "ctrl-",  text = "Ctrl + Click" },
    { key = "alt",   prefix = "alt-",   text = "Alt + Click" },
    { key = "meta",  prefix = "meta-",  text = "Cmd + Click", mac = true },
}

local demonByKey = {}
for _, d in ipairs(D.demons) do demonByKey[d.key] = d end

function M.DemonName(key)
    local d = demonByKey[key]
    if not d then return key end
    return ns.SpellName(ns.DemonSpell(d) or d.spell) or d.name or key
end

function M.SlotAvailable(slot)
    return not slot.mac or (IsMacClient and IsMacClient())
end

-- Spell ID for a demon key, or nil if the demon is not learned.
local function DemonSpell(key)
    return ns.DemonSpell(demonByKey[key])
end

-- Same prefix format the secure action button uses for modified attributes.
local function CurrentPrefix()
    local p = ""
    if IsShiftKeyDown() then p = "shift-" .. p end
    if IsControlKeyDown() then p = "ctrl-" .. p end
    if IsAltKeyDown() then p = "alt-" .. p end
    if IsMetaKeyDown and IsMetaKeyDown() then p = "meta-" .. p end
    return p
end

-- Show the demon that a click with the currently held modifier would summon.
function M:UpdateModifierIcon()
    local b = self.button
    local attrs = b.appliedAttrs or b.wantAttrs
    if not attrs then return end
    local spell = attrs[CurrentPrefix() .. "spell1"] or attrs.spell1
    if not spell then return end
    b.icon:SetTexture(ns.SpellTexture(spell) or ns.QUESTION_ICON)
    if b.tipSpell ~= spell then
        b.tipSpell = spell
        if GameTooltip:IsOwned(b) then b:GetScript("OnEnter")(b) end
    end
end

function M:Init()
    self.button = ns.CreateActionIcon("pet", "Summon Demon")
    self.button.hint = function(tt)
        tt:AddLine("No demon summoned.", 0, 1, 0)
        local bindings = ns.db.pet.bindings
        for _, slot in ipairs(M.SLOTS) do
            if M.SlotAvailable(slot) then
                local key = bindings[slot.key]
                if key == "default" then key = bindings.none end
                if DemonSpell(key) then
                    tt:AddDoubleLine(slot.text, M.DemonName(key), 1, 1, 1, 1, 0.82, 0)
                end
            end
        end
    end
    ns:RegisterEvent("UNIT_PET", function(_, unit) if unit == "player" then M:Update() end end)
    ns:RegisterEvent("UNIT_AURA", function(_, unit) if unit == "player" then M:Update() end end)
    ns:RegisterEvent("MODIFIER_STATE_CHANGED", function() M:UpdateModifierIcon() end)
end

function M:ApplySettings() end

function M:Update()
    local b = self.button
    local bindings = ns.db.pet.bindings
    local defaultSpell = DemonSpell(bindings.none) or DemonSpell("imp")
    if not defaultSpell then
        b:SetAction(nil)
        b:SetState(nil)
        return
    end

    local attrs = {}
    for _, slot in ipairs(M.SLOTS) do
        if M.SlotAvailable(slot) then
            local key = bindings[slot.key]
            local spell = (key == "default") and defaultSpell or DemonSpell(key) or defaultSpell
            attrs[slot.prefix .. "type1"] = "spell"
            attrs[slot.prefix .. "spell1"] = spell
        end
    end
    b:SetAction(attrs, ns.SpellTexture(defaultSpell), defaultSpell)

    local hasPet = UnitExists("pet") and not UnitIsDead("pet")
    if not hasPet then
        -- Grimoire of Sacrifice: no demon on purpose. Keep the last known state while auras are unreadable.
        local sacrificed = ns.PlayerHasAura(D.petSacrificeBuffs)
        if sacrificed == nil then sacrificed = self.lastSacrificed end
        self.lastSacrificed = sacrificed
        hasPet = sacrificed
    end
    b:SetState(not hasPet and "missing" or nil)
    self:UpdateModifierIcon()
end
