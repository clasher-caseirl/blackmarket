--- @module custom.configs.levels
--- @description Handles all data for levels; change these.

return {

    [1] = { -- Level
        label = "Unknown", -- Label for level
        range = { min = 0, max = 999 } -- Min and max rep range required for the level
    },
    
    [2] = {
        label = "Known",
        range = { min = 1000, max = 2999 }
    },

    [3] = {
        label = "Recognized",
        range = { min = 3000, max = 6999 }
    },

    [4] = {
        label = "Trusted",
        range = { min = 7000, max = 14999 }
    },

    [5] = {
        label = "Reliable",
        range = { min = 15000, max = 30999 }
    },

    [6] = {
        label = "Loyal",
        range = { min = 31000, max = 62999 }
    },

    [7] = {
        label = "Veteran",
        range = { min = 63000, max = 126999 }
    },

    [8] = {
        label = "Elite",
        range = { min = 127000, max = 255999 }
    },

    [9] = {
        label = "Legend",
        range = { min = 256000, max = 511999 }
    },

    [10] = {
        label = "Kingpin",
        range = { min = 512000, max = 99999999 }
    },

}