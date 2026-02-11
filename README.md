# QBCore Community Clash Event #1: Blackmarket

A blackmarket script built for QBCore Community Clash Event #1 that's probably a little "more" than really needed.

> This isn't your typical "phone menu that spawns items" script.  
> This is a full supply chain. From burner phones to police chases. From rep grinding to zone-aware heat mechanics.  
> It's what happens when you actually care about how a system works instead of just how it looks in a 30-second video.

---

## What You're Getting

- **Phone-based ordering system:** Burner phone item, menus scaled by reputation, real-time pricing adjustments.
- **Full dead drop system:** Two methods to grab your goods. Small packages hidden in zones, big shipments stashed in vehicles. You get coords, you go find it.
- **Player-vs-player risk:** Other players can steal your shipment before you get there. Risk and reward built in.
- **Zone-aware police heat:** Scumminess mechanic tied to GTA's actual zone system. Your drops in Vinewood Hills? Better watch out for cops.
- **Reputation grinding:** Actually meaningful progression. Better rep = better prices, better quantities, better items unlocked.
- **Modular as hell:** Every config is editable. Every hook is replaceable. If you want to swap out your dispatch system? Change a function. Done.
- **Built to last:** Everything's server-validated. No client-side fuckery. You know the system works because it actually works.

---

## Core Features

### Phone System
- Usable burner phone item
- Dynamic menu based on player reputation
- Real-time price scaling tied to rep points
- Item availability gated by reputation requirements
- Cooldown system to prevent spam ordering

### Dead Drops Methods
1. **Find Object:** Search zone radius for hidden package
2. **Search Vehicle:** Loot a spawned vehicle for goods

### Police Alerts
- Automatic zone scumminess detection
- RNG-based alert system (not every deal gets hot)
- Blip creation with 20-second fade
- Sound + notification feedback
- Configurable alert jobs (police, fib, swat, etc.)

### Reputation System
- Persistent reputation tracking per player
- Reputation affects pricing (up to 50% discount)
- Reputation affects quantity (up to 50% more goods)
- Reputation gates items (can't buy until you hit the threshold)
- Reputation levels with custom labels

### Anti-Spam & Validation
- Active delivery checks (can't order while already delivering)
- Police count requirements (need X officers online)
- Rep requirement checks
- Inventory space validation
- Affordability checks
- On-duty police filtering

---

## Why This Script Slaps

- **Because other blackmarket scripts are lazy:** Most are just phone menus. This one actually has mechanics.
- **Because zone-aware heat is actually cool:** Your players will learn fast: expensive areas = heat. Poor areas = quiet. Strategy.
- **Because rep actually matters:** It's not a padding number. It gates items, adjusts prices, changes quantities. You earn it, you get rewarded. That's the loop.
- **Because PvP risk is real:** Other players can intercept your drops if they are lucky. You've got to be smart about that timing. That's the tension.
- **Because it's built to last:** Every config is documented. Every hook is replaceable. Every system is modular. If you want to change something in 6 months? Five minute job.
- **Because it's not oversimplified:** But it's also not a micromanagement sim. You order, you collect, you get away. That's the flow.

---

## Dependencies
- oxmysql

### Optional

Script is technically standalone aside for `oxmysql` everything framework related runs through a single `hooks.lua` file.
Change this file to whatever you need for your server and this will run on anything. 

- QBCore framework
- qb-inventory
- qb-minigames

---

## Quick Install
 
1. Add `blackmarket` into your server resources
2. Add `ensure blackmarket` into your `server.cfg`
3. Copy images from `.INSTALL/images/` into your inventory folder (qb users: `qb-inventory/html/images/`)
4. Copy the item entry from `.INSTALL/images/README.md` into your core items (qb users: `qb-core/shared/items.lua`)
5. Restart and you're good to go

For customising, creating zones etc refer to the `.DOCUMENTATION` folder for full guides.

---

## Support

This is not really something I plan to support heavily.
However, you can always give me a shout in either:

[BOII Development Discord](https://discord.gg/sFtEcrCzH6) or [My Personal Dev Discord - That I barely use...](https://discord.gg/UtVY38ZRGn)