--- @module custom.configs.scumminess
--- @description Holds all config defs for each "scumminess" level; https://docs.fivem.net/natives/?_0x5F7B268D15BA0739

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