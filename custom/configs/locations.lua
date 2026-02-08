--- @module custom.config.locations
--- @description Holds all config defs for locations; you should customise these, dont be boring, change it up :) 

--- @section Module 

return {
    
    find_object = { -- "find_object" delivery method settings
        {
            label = "Pacific Bluffs", -- Readable label
            zone = { -- Settings for the search area shown to players *(the big circle zone on map)*
                coords = vector3(-2928.54, 33.34, 11.61), -- Coordinates for the zone
                radius = 100.0, -- Size of the zone
                colour = 1, -- Blip colour; https://docs.fivem.net/docs/game-references/blips/
            },
            spawns = { -- Spawn locations
                vector4(-2875.89, 39.03, 12.27, 68.69), -- Spawn coordinates
                vector4(-2878.21, 39.95, 12.27, 67.27)
                -- Add as many spawn locations as you want **dont forget the comma**
            }
        }
        -- Add as many locations as you like just copy the above and edit **dont forget the comma**
    },

    search_vehicle = { -- "search_vehicle" method
        {
            label = "Pacific Bluffs",
            zone = { coords = vector3(-3026.92, 110.06, 11.62), radius = 100.0, colour = 1 },
            spawns = {
                vector4(-3032.24, 136.01, 11.61, 294.57),
                vector4(-3040.12, 152.46, 11.61, 296.01)
            }
        }
    }

}