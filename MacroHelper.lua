function print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end


function ToggleHelm()
    ShowHelm(not ShowingHelm())
end


function ToggleCloak()
    ShowCloak(not ShowingCloak())
end


function SmartCast(spell)
    local haveTarget = UnitExists("target")
    local target = "player"
    local f = GetMouseFocus()
    if (f.unit) then
        target = f.unit
    elseif (UnitExists("mouseover")) then
        target = "mouseover"
    elseif (UnitExists("target")) then
        target = "target"
    end
    if (UnitIsUnit(target, "target")) then
        CastSpellByName(spell)
    else
        TargetUnit(target)
        CastSpellByName(spell)
        if (haveTarget) then
            TargetLastTarget()
        else
            ClearTarget()
        end
    end
    return target
end


function SmartCastFriend(spell)
    local haveTarget = UnitExists("target")
    local target = "player"
    local f = GetMouseFocus()
    if (f.unit and UnitReaction(f.unit, "player") > 4) then
        target = f.unit
    elseif (UnitExists("mouseover") and UnitReaction("player", "mouseover") > 4) then
        target = "mouseover"
    elseif (UnitExists("target") and UnitReaction("player", "target") > 4) then
        target = "target"
    end
    if (UnitIsUnit(target, "target")) then
        CastSpellByName(spell)
    else
        TargetUnit(target)
        CastSpellByName(spell)
        if (haveTarget) then
            TargetLastTarget()
        else
            ClearTarget()
        end
    end
    return target
end


