```markdown
# Items Configuration

Items are the meat and veg of the system. Configure what players can buy in `custom/configs/items.lua`.

Each item has defaults you can override: reputation gates, prices, quantities, delivery methods, stock amounts, XP rewards. Mix and match.

**Key things:**
- **Reputation gating:** Set `required_level` to lock items behind rep thresholds
- **Price scaling:** Rep gives discounts. Set `rep_discount` and `max_discount`
- **Quantity scaling:** Rep increases quantities. Set `rep_increase` and `max_increase`
- **Delivery method:** Each item picks `find_object` (small packages) or `search_vehicle` (big shipments)
- **XP rewards:** Players earn rep on successful drops, lose rep on failures

Change `_defaults` to affect all items. Override specific settings per item. Add as many items as you want.

```lua
--- @module custom.config.items
--- @description Holds all config defs for items the vendor can sell
--- By default this covers qbcore items, if you are using this on another framework make sure you change them
--- Changing values is encouraged and add more items! Have fun with it, don't be boring

--- @section Module

return {

    --- @section Default Settings

    --- You can override any of these by adding the sections to your items
    --- Refer to the other items below for examples
    _defaults = {
        reputation = { -- Reputation settings
            required_level = 1, -- Level required to purchase
            xp_on_success = { min = 5, max = 12 }, -- XP rewarded when player completes a drop
            xp_on_fail = { min = 2, max = 7 } -- XP removed if player fails a drop
        },

        stock = { -- Stock amounts for item
            start_amount = 2000, -- Amount store starts with the first time script is ran
            max_amount = 2000, -- Max amount store can have - useful for limiting what players can sell back
            restock_percentage = 25, -- Amount to restock every 30min
            auto_drain = false, -- If true item will auto drain; if false stock will remain
            drain_percentage = 25 -- Amount to drain every 30min             
        },

        price = { -- Price settings
            payment_method = "bank", -- Payment method to use 
            base = 200, -- Base purchase price
            rep_discount = 5, -- 5% discount per reputation level
            max_discount = 50, -- Maximum 50% discount at high reputation
            disable_scaling = false, -- Disables reputation scaling for item price
        },

        quantity = { -- Quantity settings
            base = 1, -- Base amount to offer player
            rep_increase = 5, -- 5% increase per reputation level
            max_increase = 50, -- Maximum 50% increase at high reputation
            disable_scaling = false, -- Disables reputation scaling for item quantity
        },

        delivery = { -- Delivery method settings
            method = "find_object", -- Method to use: "find_object" | "search_vehicle"
            models = { "prop_ld_case_01", "hei_prop_hei_security_case" }, -- Models to use for method: "find_object" us any object models | "search_vehicle" use any vehicle models
        }
    },

    --- @section Items

    lockpick = { -- Unique item id
        label = "Lockpick", -- Label to display on phone menu; try keep them short since the phone screen has limited space
        price = { base = 100 } -- Overriding base price
    },

    nitrous = {
        label = "NOS",
        price = { base = 350 },
        quantity = { disable_scaling = true }, -- Override quantity
        delivery = { -- Override delivery
            method = "search_vehicle", -- Use search vehicle method instead
            models = { "comet3" } -- Vehicle models that can spawn to search
        }
    },

    weapon_crowbar = {
        label = "Crowbar",
        price = { base = 80 },
        quantity = { disable_scaling = true }
    }, 

    oxy = {
        label = "Oxy",
        price = { base = 30 },
        quantity = { base = 5 },
        reputation = { required_level = 2 } -- Override reputation
    },

    xtcbaggy = {
        label = "XTC",
        price = { base = 20 },
        quantity = { base = 10 },
    },

    weed_brick = {
        label = "Weed Brick",
        price = { base = 250 },
        reputation = { required_level = 3 }
    },

    coke_brick = {
        label = "Coke Brick",
        price = { base = 750 },
        reputation = { required_level = 4 }
    }

}
```