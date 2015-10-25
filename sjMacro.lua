
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

-- Addon table
sjMacro = sjMacro or {}

-- ----------------------------------------------------------------------------
-- Smart Buff Rank
-- ----------------------------------------------------------------------------
-- Buffs cannot be cast on targets that are a level less than the level that 
-- the rank of the buff was learned at minus 10 and only seems to apply to
-- spells which are instant cast (most buffs).
-- e.g. target is level 13; can cast Power Word: Shield (Rank 3) because it was
-- learned at level 18 (13 is less than 18 minus 10 or 8) but cannot cast Power
-- Word: Fortitude (Rank 3) because it was learned at level 24 (13 is not less
-- than 24 minus 10 or 14)

local _, class = UnitClass("player")

if (class == "PRIEST") then
    print("Initializing Priest mode")

    -- Disc
    local DS = "Divine Spirit"
    local PWF = "Power Word: Fortitude"
    local PWS = "Power Word: Shield"
    -- Holy
    local R = "Renew"
    -- Shadow
    local SP = "Shadow Protection"

    -- Textures
    local DS_T  = "Interface\\Icons\\Spell_Holy_DivineSpirit"
    local PWF_T = "Interface\\Icons\\Spell_Holy_WordFortitude"
    local PWS_T = "Interface\\Icons\\Spell_Holy_PowerWordShield"
    local R_T   = "Interface\\Icons\\Spell_Holy_Renew"
    local SP_T  = "Interface\\Icons\\Spell_Shadow_AntiShadow"

    sjMacro.spells_level_learned = {
        -- Disc
        [DS]  = { 40, 42, 56 },
        [PWF] = {  1, 12, 24, 36, 48, 60 },
        [PWS] = {  6, 12, 18, 24, 30, 36, 42, 48, 54, 60 },
        [R]   = {  1, 14, 20, 26, 32, 38, 44, 50, 56 },
        [SP]  = { 30, 42, 56 }
    }

    sjMacro.spells_best_rank = {
        -- Disc
        [DS]  = nil,
        [PWF] = nil,
        [PWS] = nil,
        [R] = nil,
        [SP]  = nil
    }

    local spells_level_learned = sjMacro.spells_level_learned
    local spells_best_rank = sjMacro.spells_best_rank

    -- Catalogs the player's best ranks of spells
    function sjMacro_UpdateBestBuffRanks()
        local texture

        -- Holy
        local _, _, tab1_offset, tab1_num_spells = GetSpellTabInfo(2)
        local DS_rank, PWF_rank, PWS_rank = 0, 0, 0
        for i = 1, tab1_num_spells do
            texture = GetSpellTexture(tab1_offset + i, "spell")
            if (texture == DS_T) then
                DS_rank = DS_rank + 1
            elseif (texture == PWF_T) then
                PWF_rank = PWF_rank + 1
            elseif (texture == PWS_T) then
                PWS_rank = PWS_rank + 1
            end
        end

        -- Disc
        local _, _, tab2_offset, tab2_num_spells = GetSpellTabInfo(3)
        local R_rank = 0
        for i = 1, tab2_num_spells do
            texture = GetSpellTexture(tab2_offset + i, "spell")
            if (texture == R_T) then
                R_rank = R_rank + 1
            end
        end

        -- Shadow
        local _, _, tab3_offset, tab3_num_spells = GetSpellTabInfo(4)
        local SP_rank = 0
        for i = 1, tab3_num_spells do
            texture = GetSpellTexture(tab3_offset + i, "spell")
            if (texture == SP_T) then
                SP_rank = SP_rank + 1
            end
        end

        -- Update ranks
        spells_best_rank[DS]  = DS_rank
        spells_best_rank[PWF] = PWF_rank
        spells_best_rank[PWS] = PWS_rank
        spells_best_rank[R]   = R_rank
        spells_best_rank[SP]  = SP_rank
    end

    -- Initial run
    sjMacro_UpdateBestBuffRanks()

    function sjMacro_SmartSpellRank(spell, target)
        assert(spells_level_learned[spell])
        assert(UnitExists(target))
        local target_level = UnitLevel(target)
        local use_rank = false
        for rank, level in ripairs(spells_level_learned[spell]) do
            if (target_level >= level - 10) then
                use_rank = rank
                break
            end
        end
        return use_rank
    end
end

-- ----------------------------------------------------------------------------
-- Global functions
-- ----------------------------------------------------------------------------

-- Returns the unitID of what to cast on and whether the player already has
-- a target (in order to target last target correctly).
-- reaction: Minimum reaction required for target
-- TODO: Implement customizable priority
local function GetSmartTarget(reaction)
    local have_target = UnitExists("target")
    local target = "player"
    local f = GetMouseFocus()
    if (f.unit and UnitReaction(f.unit, "player") > reaction) then
        target = f.unit
    elseif (UnitExists("mouseover") and UnitReaction("player", "mouseover") > reaction) then
        target = "mouseover"
    elseif (UnitExists("target") and UnitReaction("player", "target") > reaction) then
        target = "target"
    end
    return target, have_target
end

-- Casts a spell on the specified unitID and targets last target if have_target
-- is true.
-- spell: Spell to cast
-- target: unitID to cast on
-- have_target: If currently have a target (for target last target)
local function SmartCastHelper(spell, target, have_target)
    if (UnitIsUnit(target, "target")) then
        CastSpellByName(spell)
    else
        TargetUnit(target)
        CastSpellByName(spell)
        if (have_target) then
            TargetLastTarget()
        else
            ClearTarget()
        end
    end
end

-- Smart cast spell
-- spell: Spell to cast
-- reaction: Minimum reaction required for target
function sjMacro_SmartCast(spell, reaction)
    local target, have_target = GetSmartTarget(reaction)
    SmartCastHelper(spell, target, have_target)
    --print(format("spell : %q", spell))
    --print(format("target : %q (have_target : %q)", target, tostring(have_target)))
end

-- Smart cast buff
function sjMacro_SmartBuff(spell)
    local target, have_target = GetSmartTarget(4)
    local rank = sjMacro_SmartSpellRank(spell, target)
    local full_spell = format("%s(Rank %s)", spell, rank)
    SmartCastHelper(full_spell, target, have_target)
    --print(format("spell : %q", spell))
    --print(format("full_spell : %q", full_spell))
    --print(format(" target : %q (have_target: %q)", target, tostring(have_target)))
end

-- Global function aliases
SmartBuff = sjMacro_SmartBuff
SmartCast = sjMacro_SmartCast

-- ----------------------------------------------------------------------------
-- Deprecated code
-- ----------------------------------------------------------------------------

-- Smart cast spell
--function sjMacro_SmartCast(spell)
    --local haveTarget = UnitExists("target")
    --local target = "player"
    --local f = GetMouseFocus()
    --if (f.unit) then
        --target = f.unit
    --elseif (UnitExists("mouseover")) then
        --target = "mouseover"
    --elseif (UnitExists("target")) then
        --target = "target"
    --end
    --if (UnitIsUnit(target, "target")) then
        --CastSpellByName(spell)
    --else
        --TargetUnit(target)
        --CastSpellByName(spell)
        --if (haveTarget) then
            --TargetLastTarget()
        --else
            --ClearTarget()
        --end
    --end
    --return target
--end

-- Smart cast friend spell
--function sjMacro_SmartCastFriend(spell)
    --local haveTarget = UnitExists("target")
    --local target = "player"
    --local f = GetMouseFocus()
    --if (f.unit and UnitReaction(f.unit, "player") > 4) then
        --target = f.unit
    --elseif (UnitExists("mouseover") and UnitReaction("player", "mouseover") > 4) then
        --target = "mouseover"
    --elseif (UnitExists("target") and UnitReaction("player", "target") > 4) then
        --target = "target"
    --end
    --if (UnitIsUnit(target, "target")) then
        --CastSpellByName(spell)
    --else
        --TargetUnit(target)
        --CastSpellByName(spell)
        --if (haveTarget) then
            --TargetLastTarget()
        --else
            --ClearTarget()
        --end
    --end
    --return target
--end

