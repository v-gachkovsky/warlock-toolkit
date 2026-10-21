local _, ns = ...
local D = ns.data
local M = ns:NewModule("healthstone")

local ranks = D.stones.healthstone
local allItems = {}
for _, r in ipairs(ranks) do
    for _, item in ipairs(r.items) do allItems[#allItems + 1] = item end
end

function M:Init()
    self.button = ns.CreateActionIcon("healthstone", "Healthstone")
    self.button.hint = function(tt) tt:AddLine("No Healthstone in bags. Click to create the strongest one.", 0, 1, 0) end
end

function M:ApplySettings() end

function M:Update()
    local b = self.button
    local spell, rank = ns.HighestKnown(ranks)
    if not spell then
        b:SetAction(nil)
        b:SetState(nil)
        return
    end
    b:SetSpell(spell, ns.ItemIcon(ranks[rank].items[1]))

    local have = false
    for _, item in ipairs(allItems) do
        if ns.ItemCount(item) > 0 then have = true; break end
    end
    b:SetState(not have and "missing" or nil)
end
