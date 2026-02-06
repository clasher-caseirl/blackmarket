--- @module custom.configs.scumminess
--- @description Holds all config defs for each "scumminess" level; https://docs.fivem.net/natives/?_0x5F7B268D15BA0739

 
return {
    [5] = { -- Scum
        chance = 100,
        actions = { -- Action options
            gang = 90 -- Weighted chance to trigger
        }
    },
    [4] = { -- Crap
        chance = 100,
        actions = {  }
    },
    [3] = { -- Below Average
        chance = 100,
        actions = {  }
    },
    [2] = { -- Above Average
        chance = 100,
        actions = {  }
    },
    [1] = { -- Nice
        chance = 100,
        actions = {  }
    },
    [0] = { -- Posh
        chance = 100,
        actions = {  }
    }
}