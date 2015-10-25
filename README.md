Adds a couple Lua functions for mouse-over casting and smart buffing.

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
