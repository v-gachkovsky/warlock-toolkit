local _, ns = ...
local D = ns.data
local M = ns:NewModule("armor")

local allIDs, isArmor = {}, {}
for _, list in pairs(D.armor) do
    for _, id in ipairs(list) do allIDs[#allIDs + 1] = id; isArmor[id] = true end
end

function M:Init()
    self.button = ns.CreateActionIcon("armor", "Demon Armor")
    self.button.hint = function(tt) tt:AddLine("Missing Demon Skin / Demon Armor / Fel Armor. Click to cast.", 0, 1, 0) end

    ns:RegisterEvent("UNIT_AURA", function(_, unit) if unit == "player" then M:Update() end end)
    ns:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", function(_, unit, _, spellID)
        if unit == "player" and not ns.IsSecret(spellID) and isArmor[spellID] then
            M.lastHas = true
            M:Update()
        end
    end)
end

function M:ApplySettings() end

function M:Update()
    local b = self.button
    -- Mists and Retail have no armor spells: the icon stays off.
    local spell = ns.HighestKnown(D.armor.felArmor) or ns.HighestKnown(D.armor.demonArmor)
        or ns.HighestKnown(D.armor.demonSkin)
    if not spell then
        b:SetAction(nil)
        b:SetState(nil)
        return
    end
    b:SetSpell(spell)

    local has = ns.PlayerHasAura(allIDs)
    if has == nil then has = self.lastHas end -- auras unreadable right now: keep last known
    self.lastHas = has
    b:SetState(has == false and "missing" or nil)
end
