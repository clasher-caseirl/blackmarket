# Delivery Methods

Two dead drop methods. Both are PvP-enabled and synced server-side.

## Find Object

Server spawns a prop (briefcase, package, etc) at a random spawn point within the ordered zone.

**Player flow:**
1. Get zone coords on phone
2. Drive/walk to zone
3. Find the prop (it's somewhere in the radius)
4. Pick it up
5. Get to a vehicle
6. Get inside and open your package for reward

**PvP Risk:**
- Other players do not see the zone however they can find the props if they are lucky
- If someone else finds it first, they can take the loot
- Police get the same zone coords (different blip) if alert fires

## Search Vehicle

Server spawns a vehicle at a random spawn point within the ordered zone.

**Player flow:**
1. Get zone coords on phone
2. Drive/walk to zone
3. Find the vehicle (it's somewhere in the radius)
4. Lockpick the vehicle
5. Pop the trunk
6. Search and claim reward

**PvP Risk:**
- Other players can find and lockpick the same vehicle
- Once it's open, anyone can loot it
- You don't need to drive it, just open the trunk
- Police get the same zone coords (different blip) if alert fires

## Police Alerts

If an alert fires, police get sent to the **zone location only** not the players coords.

**Police receive:**
- Zone blip (same location as the drop)
- Zone label/alert message
- 20-second blip fade-out

**Police don't receive:**
- Your exact player position
- Which delivery method you're using
- How many items you're grabbing

This keeps it balanced: cops know where deals are happening, but it's not a player-tracking system.

## Risk vs Reward

- **Find Object:** Lower risk (prop could be anywhere), but you need a car to finish
- **Search Vehicle:** Medium risk (vehicle is the loot container), but faster if you find it
- **PvP:** Both methods can be stolen by other players. There's no protection
- **Police:** Happens during delivery, not after. Smart timing matters