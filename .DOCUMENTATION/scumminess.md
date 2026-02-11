# Scumminess Configuration

Police alert chances are controlled by zone scumminess; https://docs.fivem.net/natives/?_0x5F7B268D15BA0739
You can modify these in `custom/configs/scumminess.lua`.

I was planning to add something for NPC gang interactions in "scum" areas, however ran out of time, would be realtively trivial to add though.

Higher scumminess zones (poor areas) = lower alert chance.
Lower scumminess zones (rich areas) = higher alert chance.

```lua
--- @module custom.configs.scumminess
--- @description Holds all config defs for each "scumminess" level

return {
    [5] = { -- Scum
        alert_police = 10 -- Chance to alert police
    },
    [4] = { -- Crap
        alert_police = 25 
    },
    [3] = { -- Below Average
        alert_police = 40 
    },
    [2] = { -- Above Average
        alert_police = 65 
    },
    [1] = { -- Nice
        alert_police = 80 
    },
    [0] = { -- Posh
        alert_police = 95
    }
}
```