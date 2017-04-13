Adds a couple Lua functions for mouse-over casting and smart buffing.

>   Currently not implemented:
>   1.  Paladins
>   2.  Druid Mark/Gift of the Wild (use the same icon)

Functions in this addon intentionally break if not used correctly so refer to
this readme for usage examples. This is to keep the functions as small as
possible to keep that fast.

## Current target priority:

(TODO: Make this order customizable)

1.  Mouse-over
2.  Target
3.  Player

## Current functions:

### 1. `SmartCast(spell, [reaction]])`
-   `spell` is the string of the spell to cast (can include a specific rank)
-   `reaction` is the standing of the player to the target
    -   0 = don't care
    -   1 = friend only
    -   2 = enemy only
-   Healing spells can only be cast on neutral or friendly units/players
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
-   Only works on friendly targets

## Examples:

### Greater Heal
```
/run SmartCast("Greater Heal",1)
```
-   Ignores hostile targets

### Heal (included downrank)
```
/run SmartCast("Heal(Rank 2)",1)
```

### Flash Heal (with Alt modifier for downrank)
```
/run if(IsAltKeyDown())then SmartCast("Flash Heal(Rank 1)",5)else SmartCast("Flash Heal",5)end
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
/run local t=SmartCast("Resurrection",1)if(UnitIsDead(t))then SendChatMessage("Resurrection on "..UnitName(t),"SAY")end
```

