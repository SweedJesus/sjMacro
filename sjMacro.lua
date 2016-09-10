-- Buffs cannot be cast on targets that are a level less than the level that
-- the rank of the buff was learned at minus 10 and only seems to apply to
-- spells which are instant cast (most buffs).
-- e.g. target is level 13; can cast Power Word: Shield (Rank 3) because it was
-- learned at level 18 (13 is less than 18 minus 10 or 8) but cannot cast Power
-- Word: Fortitude (Rank 3) because it was learned at level 24 (13 is not less
-- than 24 minus 10 or 14)

-- ----------------------------------------------------------------------------
-- Target Priority:
--
-- Edit this table to change the order of target priority for smart targeting
-- (To put spell on cursor when no valid mouseover or target are present
-- remove the "player" entry)
--
-- Valid UnitID's:
-- player, pet, target, mouseover, party1-4, partypet1-4, raid1-40, raidpet1-40

local TARGET_PRIORITY = {
    "mouseover",
    "target",
    "player"
}

-- ----------------------------------------------------------------------------

-- Print to chat frame
local function print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000sjMacro|r "..msg)
end

-- Reversed ipairs
local function ripairs(t)
    local function ripairs_it(t,i)
        i=i-1
        local v=t[i]
        if v==nil then return v end
        return i,v
    end
    return ripairs_it, t, getn(t)+1
end

-- @param unit Unit identifier string
-- @return true if unitID is visible and connected, else false
-- @return true if unitID is assistable, else false
local function UnitIsValidAssist(unit)
    return (UnitIsVisible(unit) and UnitCanAssist("player", unit)) or false
end

-- Druid
-- Balance
local T = "Thorns"
-- Restoration
local GOW = "Gift of the Wild"
local MOW = "Mark of the Wild"
local RG = "Regrowth"
local RJ = "Rejuvenation"

-- Mage
-- Arcane
local AI = "Arcane Intellect"
local AM = "Amplify Magic"
local DM = "Dampen Magic"

-- Paladin
-- Holy
local BOW = "Blessing of Wisdom"
local GBOW = "Greater Blessing of Wisdom"
-- Protection
local BOP = "Blessing of Protection"
local BOSC = "Blessing of Sacrifice"
local BOSN = "Blessing of Sanctuary"
-- Retribution
local BOM = "Blessing of Might"
local GBOM = "Greater Blessing of Might"

-- Priest
-- Discipline
local DS = "Divine Spirit"
local PWF = "Power Word: Fortitude"
local PWS = "Power Word: Shield"
-- Holy
local RN = "Renew"
-- Shadow Protection
local SP = "Shadow Protection"

-- ----------------------------------------------------------------------------
-- Functions
-- ----------------------------------------------------------------------------

function sjMacro_OnLoad()
    sjMacro:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function sjMacro_OnEvent(event)
    if event == "PLAYER_ENTERING_WORLD" then
        sjMacro_OnPlayerEnteringWorld()
    elseif event == "LEARNED_SPELL_IN_TAB" then
        sjMacro_UpdateBestBuffRanks()
    end
end

function sjMacro_OnPlayerEnteringWorld()
    local _, class = UnitClass("player")
    if not (class == "DRUID" or class == "MAGE" or class == "PRIEST" or class == "PALADIN") then
        return
    end

    sjMacro.bestBuffEnabled = true

    if class == "DRUID" then
        sjMacro.spellsLevelLearned = {
            [MOW] = {  1, 10, 20, 30, 40, 50, 60 },
            [GOW] = { 50, 60 },
            [RG]  = { 12, 18, 24, 30, 36, 42, 48, 54, 60 },
            [RJ]  = {  4, 10, 16, 22, 28, 34, 40, 46, 52, 58 },
            [T]   = {  6, 14, 24, 34, 44, 54 }
        }
    elseif class == "MAGE" then
        sjMacro.spellsLevelLearned = {
            [AM] = { 18, 30, 42, 54 },
            [AI] = {  1, 14, 28, 42, 56 },
            [DM] = { 12, 24, 36, 48, 60 }
        }
    elseif class == "PALADIN" then
        sjMacro.spellsLevelLearned = {
            [BOM]  = {  4, 12, 22, 32, 42, 52 },
            [BOP]  = { 10, 24, 38 },
            [BOSC] = { 46, 54 },
            [BOSN] = { 30, 40, 50, 60 },
            [BOW]  = { 14, 24, 34, 44, 54, 60 }
        }
    elseif class == "PRIEST" then
        sjMacro.spellsLevelLearned = {
            [DS]  = { 30, 40, 50, 60 },
            [PWF] = {  1, 12, 24, 36, 48, 60 },
            [PWS] = {  6, 12, 18, 24, 30, 36, 42, 48, 54, 60 },
            [RN]  = {  1, 14, 20, 26, 32, 38, 44, 50, 56 },
            [SP]  = { 30, 42, 56 }
        }
    end

    sjMacro.spellsBestRank = {}
    for k in pairs(sjMacro.spellsLevelLearned) do
        sjMacro.spellsBestRank[k] = 0
    end

    -- Initial update run
    sjMacro_UpdateBestBuffRanks()

    sjMacro:RegisterEvent("LEARNED_SPELL_IN_TAB")
end

-- Update list of best buff ranks
function sjMacro_UpdateBestBuffRanks()
    local i, spell, rank = 1, GetSpellName(1, "spell")
    while spell do
        if sjMacro.spellsBestRank[spell] then
            _,_,rank = string.find(rank, "Rank (%d+)")
            sjMacro.spellsBestRank[spell] = tonumber(rank)
        end
        i = i + 1
        spell, rank = GetSpellName(i, "spell")
    end
end

-- Get the buff best rank for unit
-- @param buff Buff to cast
-- @param unit Unit to cast buff on
function sjMacro_GetSmartBuffRank(buff, unit)
    if not sjMacro.spellsLevelLearned[buff] then
        local first, s = true, "|cffff0000 Error|r: Invalid spell for SmartBuff, use: "
        for k in pairs(sjMacro.spellsBestRank) do
            s = s..(not first and ", " or "")..k
            first = false
        end
        print(s)
        return
    end
    if not unit then
        return sjMacro.spellsBestRank[buff]
    end
    local targetLevel = UnitLevel(unit)
    local useRank = false
    for rank, level in ripairs(sjMacro.spellsLevelLearned[buff]) do
        if targetLevel >= level - 10 then
            useRank = rank
            break
        end
    end
    return useRank
end

-- @param assist (nil=don't care, 1=can assist, 2=can't assist)
function sjMacro_SmartTarget(assist)
    local target, haveTarget, canAssist = false, UnitExists("target")
    for i,unit in TARGET_PRIORITY do
        if unit == "mouseover" then
            unit = GetMouseFocus().unit or unit
        end
        isValidAssist = UnitIsValidAssist(unit)
        if (assist == 1 and isValidAssist) or (assist == 2 and not isValidAssist) then
            target = unit
            break
        end
    end
    --DEFAULT_CHAT_FRAME:AddMessage(format("%s %s", assist, unit))
    return target, haveTarget
end

-- Casts a spell on the specified unitID and targets last target if have_target
-- is true.
-- spell: Spell to cast
-- target: unitID to cast on
-- have_target: If currently have a target (for target last target)
local function SmartCastHelper(spell, target, haveTarget)
    if not target or UnitIsUnit(target, "target") then
        CastSpellByName(spell)
    else
        TargetUnit(target)
        CastSpellByName(spell)
        if haveTarget then
            TargetLastTarget()
        else
            ClearTarget()
        end
    end
end

-- Smart cast spell
-- @param spell Spell to cast
-- @param assist Requiring assist flag (0=don't care, 1=can assist, 2=can't
-- assist)
function sjMacro_SmartCast(spell, assist)
    local target, haveTarget = sjMacro_SmartTarget(assist)
    SmartCastHelper(spell, target, haveTarget)
    return target
end

-- Smart cast buff
-- @param spell Spell to cast (buff)
function sjMacro_SmartBuff(spell)
    if not sjMacro.bestBuffEnabled then
        print("Best buff not enabled!")
        return
    end
    local target, haveTarget = sjMacro_SmartTarget(1)
    local rank = sjMacro_GetSmartBuffRank(spell, target)
    if rank then
        if rank > sjMacro.spellsBestRank[spell] then
            rank = sjMacro.spellsBestRank[spell]
        end
        local fullSpell = format("%s(Rank %s)", spell, rank)
        SmartCastHelper(fullSpell, target, haveTarget)
    end
    return target, rank
end

-- Global function aliases
SmartBuff = sjMacro_SmartBuff
SmartCast = sjMacro_SmartCast

