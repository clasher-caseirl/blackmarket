# Settings Configuration

All core settings are in `custom/settings.lua`. 
All the actual fun stuff (items, locations, prices, rep levels, police alert chances) lives in `custom/configs/`.

```lua
--- @module custom.settings
--- @description Handles core settings

return {
    language = "en", -- Language/localization file to use
    debug = true, -- Toggle debug logging throughout
    startup_message = true, -- Prints start up message to console if enabled
    phone_prop = "prop_v_m_phone_o1s", -- Prop model to attach to player when using phone
    menu_order_cooldown = 600, -- Cooldown time for placing new orders in seconds 600 = 10min, 1200 = 20min etc
    police_jobs = { "police" }, -- Table of police jobs to send alerts too
    on_duty_only_alerts = false, -- If alerts should only be sent to on duty players
    required_police = 2, -- Amount of police officers required online to do a dead drop
    on_duty_only_required = false, -- If police officers have to be on duty to be counted
    rear_engine_vehicles = { -- List of rear engine vehicles
        adder = true,
        ardent = true,
        autarch = true,
        bullet = true,
        cheetah = true,
        cheetah2 = true,
        comet2 = true,
        comet3 = true,
        entityxf = true,
        fmj = true,
        gp1 = true,
        infernus = true,
        italigtb = true,
        italirsx = true,
        jester = true,
        jester2 = true,
        monroe = true,
        nero = true,
        nero2 = true,
        ninef = true,
        ninef2 = true,
        osiris = true,
        penetrator = true,
        pfister811 = true,
        prototipo = true,
        re7b = true,
        reaper = true,
        stingergt = true,
        surfer = true,
        surfer2 = true,
        t20 = true,
        tempesta = true,
        turismo2 = true,
        turismor = true,
        tyrant = true,
        tyrus = true,
        vacca = true,
        vagner = true,
        zentorno = true
    }
}
```