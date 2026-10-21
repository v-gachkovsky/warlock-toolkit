local _, ns = ...
local D = ns.data
local M = ns:NewModule("soulstone")

local ranks = D.stones.soulstone
local isBuff = {}
for _, id in ipairs(D.soulstoneBuffs) do isBuff[id] = true end
local pendingCasts = {}

local function LabelCfg() return ns.db.soulstoneLabel end

-- Mists / Retail: Soulstone is a spell cast on the target instead of a bag item.
local function DirectCast() return ns.IsKnown(D.soulstoneSpell) end

local function Duration()
    return DirectCast() and D.soulstoneSpellDuration or D.soulstoneDuration
end

-- nil for missing, empty or secret values.
local function Safe(v)
    if v == nil or ns.IsSecret(v) or v == "" then return nil end
    return v
end

local function ShortName(name)
    name = Safe(name)
    return name and (name:gsub("%-.*$", ""))
end

local function GUIDOf(unit)
    local ok, guid = pcall(UnitGUID, unit)
    if ok then return Safe(guid) end
end

-- "Name" for the same realm, "Name-Realm" otherwise (the form UNIT_SPELLCAST_SENT reports).
local function FullName(unit)
    local ok, name, realm = pcall(UnitName, unit)
    if not ok or not Safe(name) then return nil end
    realm = Safe(realm)
    return realm and (name .. "-" .. realm:gsub("%s", "")) or name
end

local function GroupUnits()
    local units = { "player" }
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do units[#units + 1] = "raid" .. i end
    elseif IsInGroup() then
        for i = 1, GetNumSubgroupMembers() do units[#units + 1] = "party" .. i end
    end
    return units
end

local function UnitByFullName(name)
    if not name then return nil end
    name = name:gsub("%s", "")
    for _, u in ipairs(GroupUnits()) do
        if FullName(u) == name then return u end
    end
end

local function UnitByGUID(guid)
    if not guid then return nil end
    for _, u in ipairs(GroupUnits()) do
        if GUIDOf(u) == guid then return u end
    end
end

local function ClassOf(unit)
    if not unit then return nil end
    local ok, _, class = pcall(UnitClass, unit)
    if ok then return Safe(class) end
end

local function ClassOfGUID(guid)
    if not guid or not GetPlayerInfoByGUID then return nil end
    local ok, _, class = pcall(GetPlayerInfoByGUID, guid)
    if ok then return Safe(class) end
end

------------------------------------------------------------------------
-- Tracking (persisted per character so it survives /reload).
-- The target is identified by GUID; the name is only for display.
------------------------------------------------------------------------
function M:GetTracked()
    local t = ns.cdb.soulstone
    if t and t.expires > GetServerTime() then return t end
    ns.cdb.soulstone = nil
end

-- full: "Name" / "Name-Realm", kept only as a fallback when the GUID is unknown.
function M:SetTracked(guid, name, class, expires, full)
    if not guid and not name then ns.cdb.soulstone = nil; return end
    ns.cdb.soulstone = { guid = guid, name = name, full = full, class = class, expires = expires }
end

local function IsSelf(t)
    if t.guid then return t.guid == GUIDOf("player") end
    return (t.full or t.name) == UnitName("player")
end

-- Out of combat: read real auras of the group to confirm/correct the tracked target.
function M:Scan()
    if ns.AurasSecret() or not C_UnitAuras or not C_UnitAuras.GetAuraDataByIndex then return end
    local found
    for _, u in ipairs(GroupUnits()) do
        if UnitExists(u) then
            local ok = pcall(function()
                for i = 1, 40 do
                    local a = C_UnitAuras.GetAuraDataByIndex(u, i, "HELPFUL|PLAYER")
                    if not a then break end
                    if isBuff[a.spellId] then found = { unit = u, aura = a }; return end
                end
            end)
            if ok and found then break end
        end
    end

    if found then
        local a = found.aura
        local expires
        if a.expirationTime and a.expirationTime > 0 then
            expires = GetServerTime() + math.floor(a.expirationTime - GetTime())
        else
            local t = self:GetTracked()
            expires = t and t.expires or GetServerTime() + Duration()
        end
        self:SetTracked(GUIDOf(found.unit), ShortName(UnitName(found.unit)), ClassOf(found.unit), expires)
        return
    end

    -- Not found: forget it only if we can actually see the target's auras.
    local t = self:GetTracked()
    if t then
        local u = t.guid and UnitByGUID(t.guid) or (IsSelf(t) and "player")
        if u and UnitIsVisible(u) and UnitIsConnected(u) then self:SetTracked(nil) end
    end
end

------------------------------------------------------------------------
-- Label (target name in class color + timer)
------------------------------------------------------------------------
function M:CreateLabel()
    local f = CreateFrame("Frame", "WarlockToolkit_SoulstoneLabel", UIParent)
    f:SetFrameStrata("MEDIUM")
    f:SetSize(120, 36)
    f.name = f:CreateFontString(nil, "OVERLAY")
    f.name:SetPoint("TOP", f, "TOP", 0, -2)
    f.timer = f:CreateFontString(nil, "OVERLAY")
    f.icon = f:CreateTexture(nil, "OVERLAY")
    f.icon:SetPoint("RIGHT", f.timer, "LEFT", -3, 0)
    f.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    f.icon:SetTexture(ns.SpellTexture(D.soulstoneBuffs[1]) or ns.ItemIcon(ranks[#ranks].items[1]) or ns.QUESTION_ICON)
    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetAllPoints()
    f.bg:SetColorTexture(0, 0, 0, 1)
    ns.MakeMovable(f, LabelCfg)

    local elapsed = 0
    f:SetScript("OnUpdate", function(self, dt)
        elapsed = elapsed + dt
        if elapsed < 0.25 then return end
        elapsed = 0
        local remain = (self.expires or 0) - GetServerTime()
        if remain < 0 then remain = 0 end
        self.timer:SetFormattedText("%d:%02d", math.floor(remain / 60), remain % 60)
    end)
    f:Hide()
    self.label = f
end

-- name == nil with `expires` set: Soulstone is on the caster, show only the timer.
function M:ShowLabel(name, class, expires)
    local f, cfg = self.label, LabelCfg()
    if not expires or not cfg.enabled then f:Hide(); return end
    local iconSize = cfg.timerSize + 2
    local nameHeight = 0
    if name then
        local color = class and (C_ClassColor and C_ClassColor.GetClassColor(class) or RAID_CLASS_COLORS[class])
        f.name:SetText(name)
        if color then f.name:SetTextColor(color.r, color.g, color.b) else f.name:SetTextColor(1, 1, 1) end
        nameHeight = cfg.nameSize + 2
    end
    f.name:SetShown(name ~= nil)
    f.timer:SetTextColor(1, 1, 1)
    f.timer:ClearAllPoints()
    f.timer:SetPoint("TOP", f, "TOP", cfg.showIcon and (iconSize + 3) / 2 or 0, -(nameHeight + 3))
    f.expires = expires
    local timerWidth = math.max(f.timer:GetStringWidth(), 30) + (cfg.showIcon and (iconSize + 3) or 0)
    local w = math.max(name and f.name:GetStringWidth() or 0, timerWidth) + 12
    f:SetSize(w, nameHeight + math.max(cfg.timerSize, cfg.showIcon and iconSize or 0) + 6)
    f.bg:SetAlpha(cfg.bgAlpha)
    f:SetAlpha(ns.FrameAlpha())
    f:EnableMouse(not cfg.locked and not ns.ClickThrough())
    f:Show()
end

------------------------------------------------------------------------
-- Module
------------------------------------------------------------------------
function M:Init()
    self.button = ns.CreateActionIcon("soulstone", "Soulstone")
    self.button.previewState = "use"
    self.button.hint = function(tt)
        if M.button.state == "create" then
            tt:AddLine("No Soulstone in bags. Click to create the strongest one.", 1, 0.3, 0.3)
        else
            tt:AddLine("Soulstone is not applied. Click to use it on your", 1, 0.82, 0)
            tt:AddLine("friendly target (or yourself if none).", 1, 0.82, 0)
        end
    end
    self:CreateLabel()

    ns:RegisterEvent("UNIT_SPELLCAST_SENT", function(_, unit, target, castGUID, spellID)
        if unit ~= "player" or ns.IsSecret(spellID) or not isBuff[spellID] then return end
        pendingCasts[castGUID] = Safe(target) or false
    end)
    ns:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", function(_, unit, castGUID, spellID)
        if unit ~= "player" or ns.IsSecret(spellID) or not isBuff[spellID] then return end
        local target = pendingCasts[castGUID]
        pendingCasts[castGUID] = nil
        -- No target name means the stone went on the caster.
        local u = target and UnitByFullName(target) or "player"
        local guid = u and GUIDOf(u)
        M:SetTracked(guid, ShortName(target) or UnitName("player"), u and ClassOf(u) or ClassOfGUID(guid),
            GetServerTime() + Duration(), target)
        M:Update()
    end)
    ns:RegisterEvent("GROUP_ROSTER_UPDATE", function() M:Update() end)
    ns:RegisterEvent("UNIT_AURA", function(_, unit)
        if unit == "player" or (unit and (unit:match("^party") or unit:match("^raid"))) then
            M.needScan = true
        end
    end)
    self.needScan = true
end

function M:ApplySettings()
    local cfg, f = LabelCfg(), self.label
    ns.ApplyFont(f.name, cfg.font, cfg.nameSize, cfg.outline)
    ns.ApplyFont(f.timer, cfg.font, cfg.timerSize, cfg.outline)
    -- Small Soulstone icon left of the timer; shift the timer so the pair stays centered.
    local iconSize = cfg.timerSize + 2
    f.icon:SetSize(iconSize, iconSize)
    f.icon:SetShown(cfg.showIcon)
    ns.ApplyPoint(f, cfg.point)
    self.needScan = true
end

function M:Update()
    local b = self.button
    if not ns.db.soulstone.enabled then
        b:SetState(nil)
        self.label:Hide()
        return
    end

    if self.needScan and not ns.AurasSecret() then
        self.needScan = false
        self:Scan()
    end

    local t = self:GetTracked()
    if t and not IsSelf(t) then
        if not t.class then t.class = ClassOf(UnitByGUID(t.guid)) or ClassOfGUID(t.guid) end
        self:ShowLabel(t.name, t.class, t.expires)
    elseif t then
        self:ShowLabel(nil, nil, LabelCfg().showSelf and t.expires or nil)
    elseif ns.db.preview then
        local _, class = UnitClass("player")
        self:ShowLabel("Soulstone target", class, GetServerTime() + Duration())
    else
        self:ShowLabel(nil, nil, nil)
    end

    if DirectCast() then
        local name = ns.SpellName(D.soulstoneSpell)
        local macro = string.format("/cast [help,nodead] %s; [@player] %s", name, name)
        b:SetAction({ type1 = "macro", macrotext1 = macro }, ns.SpellTexture(D.soulstoneSpell), D.soulstoneSpell)
        b:SetState(not t and "use" or nil)
        return
    end

    -- State 2: a Soulstone is in the bags but not applied -> use it.
    local item
    for i = #ranks, 1, -1 do
        if ns.ItemCount(ranks[i].items[1]) > 0 then item = ranks[i].items[1]; break end
    end

    if item then
        local macro = string.format("/use [help,nodead] item:%d; [@player] item:%d", item, item)
        b:SetAction({ type1 = "macro", macrotext1 = macro }, ns.ItemIcon(item), nil, item)
        b:SetState(not t and "use" or nil)
        return
    end

    -- State 1: no Soulstone in the bags -> create one.
    local spell, rank = ns.HighestKnown(ranks)
    if spell then
        b:SetSpell(spell, ns.ItemIcon(ranks[rank].items[1]))
        b:SetState((not t or ns.db.soulstone.createWhileApplied) and "create" or nil)
    else
        b:SetAction(nil)
        b:SetState(nil)
    end
end
