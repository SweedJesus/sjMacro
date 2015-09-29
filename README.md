Adds a couple Lua functions for mouse-over casting (healing in particular).

The function `SmartCastFriend` is modeled after `CastSpellByName` and takes a
spell name string (e.g. `"Renew"` or `"Renew(Rank 5"`). It attempts to cast the
spell on the first unit in this order of priority: "mouseover", "target",
"player". Obviously it will only work if the spell can be cast on friendlies.
The function then returns the unit token and unit name of what the spell was
casted on.

## Examples

-   Renew
```
/run SmartCastFriend("Renew")
```

-   Renew with modifier for downrank
```
/run if(IsAltKeyDown())then SmartCastFriend("Renew(Rank 5)")else SmartCastFriend("Renew")end
```

-   Resurrect with yell announce
```
/run local t=SmartCastFriend("Resurrection")if(t and UnitIsDead(t))then SendChatMessage("Resurrection on "..UnitName(t),"YELL")end
```
