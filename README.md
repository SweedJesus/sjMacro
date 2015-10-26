Adds a couple Lua functions for mouse-over casting and smart buffing.

>   Currently not implemented:
>   1.  Paladins
>   2.  Druid Mark/Gift of the Wild (use the same icon)

Functions in this addon intentionally break if not used correctly so refer to
this readme for usage examples. This is to keep the functions as small as
possible to keep that fast.

## Current functions:

### 1. `SmartCast(spell, reaction)`
-   `spell` is the string of the spell to cast (can include a specific rank)
-   `reaction` is the minimum reaction of the target for the spell to be casted
    on. If an expected target is below, continues to the next expected target
    (e.g. targeting an enemy while casting heal with `reaction = 4`: enemy is
    below reaction level 4, so casts on player instead).
-   Returns the [unitID](http://wowprogramming.com/docs/api_types#unitID) of
    the target the spell was casted on (unfortunately regardless of whether the
    spell actually cast; can't think of a way to address this)

### 2. `SmartBuff(spell)`
-   `spell` is the string of the buff to cast (do not include a specific
    rank!). The spell rank is added in after reconciling the target level with
    the highest available rank of the buff to cast.
-   For use with friend only instant buffs which require down-ranking for lower
    level targets, and...
-   **Instant heals (e.g. Renew, Rejuvenation) are included in this category**
-   Only works on friendly targets (reaction 4 or greater)

## Examples:

### Greater Heal
```
/run SmartCast("Greater Heal",4)
```

### Heal (included downrank)
```
/run SmartCast("Heal(Rank 2)",4)
```

### Flash Heal (with Alt modifier for downrank)
```
/run if(IsAltKeyDown())then SmartCast("Flash Heal(Rank 1)",4)else SmartCast("Flash Heal",4)end
```

### Renew (automatic downrank)
```
/run SmartBuff("Renew")
```

### Power Word: Fortitude (with Alt modifier for Prayer of Fortitude)
```
/run if(IsAltKeyDown())then SmartCast("Prayer of Fortitude")else SmartBuff("Power Word: Fortitude")end
```

### Resurrection (say name of unit casted on if actually dead)
```
/run local t=SmartCast("Resurrection",4)if(UnitIsDead(t))then SendChatMessage("Resurrection on "..UnitName(t),"SAY")end
```

## My Macros:

```
MACRO 16777234 " " Spell_Holy_PrayerOfHealing02
/run if nil then CastSpellByName("Prayer of Healing") end
/run if(IsAltKeyDown())then CastSpellByname("Prayer of Healing(Rank 1)")else CastSpellByName("Prayer of Healing")end
END
MACRO 16777225 " " Spell_Nature_NullifyDisease
/run if nil then CastSpellByName("Abolish Disease") end
/run SmartCast("Abolish Disease",4)
END
MACRO 16777227 " " Spell_Holy_DispelMagic
/run if nil then CastSpellByName("Dispel Magic") end
/run SmartCast("Dispel Magic",4)
END
MACRO 16777233 " " Spell_Holy_DivineSpirit
/run if nil then CastSpellByName("Divine Spirit") end
/run if(IsAltKeyDown())then SmartCast("Prayer of Spirit")else SmartBuff("Divine Spirit")end
END
MACRO 16777228 " " Spell_Holy_FlashHeal
/run if nil then CastSpellByName("Flash Heal") end
/run if(IsAltKeyDown())then SmartCast("Flash Heal(Rank 1)",4)else SmartCast("Flash Heal",4)end
END
MACRO 16777232 " " Spell_Holy_GreaterHeal
/run if nil then CastSpellByName("Greater Heal") end
/run if(IsAltKeyDown())then SmartCast("Greater Heal(Rank 1)",4)else SmartCast("Greater Heal",4)end
END
MACRO 16777238 " " Spell_Holy_Heal
/run if nil then CastSpellByName("Heal") end
/run SmartCast("Heal(Rank 2)",4)
END
MACRO 16777229 " " Spell_Shadow_AntiShadow
/run if nil then CastSpellByName("Shadow Protection") end
/run if(IsAltKeyDown())then SmartCast("Prayer of Shadow Protection")else SmartBuff("Shadow Protection")end
END
MACRO 16777231 " " Spell_Holy_HolyNova
/run if nil then CastSpellByName("Holy Nova") end
/run if not IsAltKeyDown()then CastSpellByName("Holy Nova")else CastSpellByName("Holy Nova(Rank 1)")end
END
MACRO 16777239 " " Spell_Holy_PowerInfusion
/run if nil then CastSpellByName("Power Infusion") end
/run local t=UnitName(SmartCastFriend("Power Infusion"))SendChatMessage("Power Infusion on YOU","whisper","orcish",t)
END
MACRO 16777221 " " Spell_Holy_WordFortitude
/run if nil then CastSpellByName("Power Word: Fortitude") end
/run if(IsAltKeyDown())then SmartCast("Prayer of Fortitude")else SmartBuff("Power Word: Fortitude")end
END
MACRO 16777220 " " Spell_Holy_PowerWordShield
/run if nil then CastSpellByName("Power Word: Shield") end
/run SmartCastFriend("Power Word: Shield")
END
MACRO 16777219 " " Spell_Holy_Renew
/run if nil then CastSpellByName("Flash Heal") end
/run if(IsAltKeyDown())then SmartCast("Renew(Rank 5)",4)else SmartBuff("Renew")end
END
MACRO 16777222 " " Spell_Holy_Resurrection
/run if nil then CastSpellByName("Resurrection") end
/run local t=SmartCast("Resurrection",4)if(UnitIsDead(t))then SendChatMessage("Resurrection on "..UnitName(t),"SAY")end
END
```
