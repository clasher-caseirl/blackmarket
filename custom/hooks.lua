--- @script custom.hooks
--- @description Allows for hooking into resource logic, this is extremely important for frameworks since this operates standalone.
--- You should customise the functions in this file to fit your framework. 
--- Most of this is trivial, and full information is provided within the docs `docs/guides_using_hooks.md`
--- It has been done this way to remove the need for a bridge, edit this one file if you change your core and it will still work.

local hooks = {}

if core.is_server then

    local QBCore = exports["qb-core"]:GetCoreObject()

    --- Is used to register items as usable inventories
    --- This is **extremely** important or items wont be usable
    --- @param item_id string: The string ID for item
    --- @param func function: The custom function attached to item
    function hooks.register_usable_item(item_id, func)
        if not item_id or not func then return end

        --- @example QBCore
        QBCore.Functions.CreateUseableItem(item_id, function(source)
            func(source)
        end)
    end

    --- Is used to get the players character identifer to insert database entries
    --- This is **extremely** important, do not leave this on GetPlayerName modify it to your core
    --- @return id: Players unique identifier
    function hooks.get_player_identifier(source)

        --- @example QBCore
        local player = QBCore.Functions.GetPlayer(source)
        if not player then log("error", "Player missing.") return end
        
        return player.PlayerData.citizenid
    end

    --- Check if player can afford a payment
    --- @param source number: Player source
    --- @param payment_method string: Payment method ID (cash, bank, etc)
    --- @param payment_type string: "balance" or "item"
    --- @param amount number: Amount to check
    --- @return boolean: Can afford
    function hooks.can_afford(source, payment_method, payment_type, amount)

        --- @example QBCore
        local player = QBCore.Functions.GetPlayer(source)
        if not player then log("error", "Player missing.") return false end

        if payment_type == "balance" then
            return player.PlayerData.money[payment_method] >= amount
        end

        if payment_type == "item" then
            local item = player.Functions.GetItemByName(payment_method)
            return item and item.amount >= amount
        end

        return false
    end

    --- Check if player has item
    --- @param source number: Player source
    --- @param item_id string: Item ID
    --- @param quantity number: Quantity to check
    --- @return boolean: Has item
    function hooks.has_item(source, item_id, quantity)
        if not source or not item_id or not quantity then return end

        --- @example QBCore
        local player = QBCore.Functions.GetPlayer(source)
        if not player then log("error", "Player missing.") return false end

        local item = player.Functions.GetItemByName(item_id)
        return item and item.amount >= quantity
    end

    --- Check if player has inventory space
    --- @param source number: Player source
    --- @param item_id string: Item ID
    --- @param quantity number: Quantity to add
    --- @return boolean: Has space
    function hooks.has_inventory_space(source, item_id, quantity)

        --- @example QBCore
        local player = QBCore.Functions.GetPlayer(source)
        if not player then log("error", "Player missing.") return false end

        local item_info = QBCore.Shared.Items[item_id]
        if not item_info then 
            log("error", ("Item not found in QBCore.Shared.Items: %s"):format(item_id))
            return false 
        end

        local item_weight = (item_info.weight or 1) * quantity
        local free_weight = exports["qb-inventory"]:GetFreeWeight(source)

        return free_weight >= item_weight
    end

    --- Remove payment from player
    --- @param source number: Player source
    --- @param payment_method string: Payment method ID
    --- @param payment_type string: "balance" or "item"
    --- @param amount number: Amount to remove
    --- @return boolean: Success
    function hooks.remove_payment(source, payment_method, payment_type, amount)

        --- @example QBCore
        local player = QBCore.Functions.GetPlayer(source)
        if not player then log("error", "Player missing.") return false end

        if payment_type == "balance" then
            return player.Functions.RemoveMoney(payment_method, amount)
        end

        if payment_type == "item" then
            return player.Functions.RemoveItem(payment_method, amount)
        end

        return false
    end

    --- Add item to player
    --- @param source number: Player source
    --- @param item_id string: Item ID
    --- @param quantity number: Quantity to add
    --- @return boolean: Success
    function hooks.add_item(source, item_id, quantity)

        --- @example QBCore
        local player = QBCore.Functions.GetPlayer(source)
        if not player then log("error", "Player missing.") return false end

        local item_info = QBCore.Shared.Items[item_id]
        TriggerClientEvent("qb-inventory:client:ItemBox", source, item_info, "add", quantity)

        return player.Functions.AddItem(item_id, quantity)
    end

    --- Remove item from player
    --- @param source number: Player source
    --- @param item_id string: Item ID
    --- @param quantity number: Quantity to remove
    --- @return boolean: Success
    function hooks.remove_item(source, item_id, quantity)

        --- @example QBCore
        local player = QBCore.Functions.GetPlayer(source)
        if not player then log("error", "Player missing.") return false end

        local item_info = QBCore.Shared.Items[item_id]
        TriggerClientEvent("qb-inventory:client:ItemBox", source, item_info, "remove", quantity)

        return player.Functions.RemoveItem(item_id, quantity)
    end

    --- Checks if a player has a specified job from a table of job names
    --- Optionally check if the player is "on duty"
    --- @param source number: Player source
    --- @param job_names table: Table of applicable jobs "{ "police", "fib" }"
    --- @param check_on_duty boolean: True only counts if on duty
    --- @return boolean: Success
    function hooks.player_has_job(source, job_names, check_on_duty) 
        local player = QBCore.Functions.GetPlayer(source)
        if not player then return false end

        local job = player.PlayerData.job
        
        for _, job_name in ipairs(job_names) do
            if job.name == job_name then
                if check_on_duty then
                    return job.onduty == true
                end
                return true
            end
        end
        
        return false
    end

    --- Gets the amount of players with jobs from a table of job names
    --- Optionally only count players who are "on duty"
    --- @param job_names table: Table of applicable jobs "{ "police", "fib" }"
    --- @param check_on_duty boolean: True counts on duty, will return both values
    --- @return number, number: Total players with job; total on duty
    function hooks.count_players_by_job(job_names, check_on_duty) 
        local players = QBCore.Functions.GetPlayers()
        local total_with_job = 0
        local total_on_duty = 0

        for _, player_source in ipairs(players) do
            local player = QBCore.Functions.GetPlayer(player_source)
            
            if player then
                local job = player.PlayerData.job
                for _, job_name in ipairs(job_names) do
                    if job.name == job_name then
                        total_with_job = total_with_job + 1
                        if job.onduty then
                            total_on_duty = total_on_duty + 1
                        end
                        break
                    end
                end
            end
        end

        return total_with_job, total_on_duty
    end

    --- Sends a police alert to all police jobs
    --- @param coords vector3: World coordinates of the alert
    --- @param job_names table: Table of job names to alert
    --- @param on_duty boolean: Only send to on duty players
    --- @param label string: Alert message/label
    function hooks.send_police_alert(coords, job_names, on_duty, label)

        --- @example QBCore
        local players = QBCore.Functions.GetPlayers()
        
        for _, player_source in ipairs(players) do
            if hooks.player_has_job(player_source, job_names, on_duty) then
                TriggerClientEvent("blackmarket:cl:police_alert", player_source, coords, label)
            end
        end
    end

    --- Handles sending notifications to players
    --- Modify this function to integrate with your framework"s notification system
    --- The default implementation uses the built-in notification system
    --- Inbound options:
    ---   type: "info" | "success" | "error" | "warning" (default: "info")
    ---   header: Optional header text above the message
    ---   message: The notification message (required)
    ---   duration: Auto-close time in milliseconds, 0 for sticky (default: 4000)
    ---
    --- @param source number: Player source id
    --- @param opts table: Notification options
    function hooks.send_notification(source, opts)
        if not source or not opts then return end

        --- @example QBCore
        local notify_type = opts.type == "info" and "primary" or opts.type

        TriggerClientEvent("QBCore:Notify", source, opts.message, notify_type, opts.duration or 4000)
    end

end

--- @section Client Functions

if not core.is_server then

    local QBCore = exports["qb-core"]:GetCoreObject()

    --- Handles displaying notifications on the client
    --- Modify this function to integrate with your framework"s notification system
    --- The default implementation uses the built-in notification system 
    --- Inbound options:
    ---   type: "info" | "success" | "error" | "warning" (default: "info")
    ---   header: Optional header text above the message
    ---   message: The notification message (required)
    ---   duration: Auto-close time in milliseconds, 0 for sticky (default: 4000)
    ---
    --- @param opts table: Notification options
    function hooks.send_notification(opts)
        if not opts then return end

        --- @example QBCore
        local notify_type = opts.type == "info" and "primary" or opts.type

        QBCore.Functions.Notify(opts.message, notify_type, opts.duration or 4000)
    end

    --- Start lockpick minigame
    --- @param callback function: Callback with result
    function hooks.lockpick_minigame(callback)
        if not callback then return { success = false } end 

        --- @example QBCore
        local rng = math.floor(math.random(2, 6))

        local success = exports["qb-minigames"]:Lockpick(rng)
        callback({ success = success })
    end

    --- Displays a police alert on the client
    --- Handles notification, sound, and blip creation
    --- @param opts table: Alert options containing coords and label
    function hooks.display_police_alert(opts)
        if not opts or not opts.coords or not opts.label then return end

        --- @example Standalone Method
        hooks.send_notification({ type = "info", header = "DISPATCH ALERT", message = opts.label, duration = 5000 })

        PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)

        local blip = AddBlipForCoord(opts.coords)
        SetBlipSprite(blip, 161)
        SetBlipColour(blip, 1)
        SetBlipScale(blip, 2.0)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(opts.label)
        EndTextCommandSetBlipName(blip)

        local alpha = 250
        local duration = 20000
        local start_time = GetGameTimer()
        local step_time = 100
        local steps = duration / step_time
        local alpha_decrement = alpha / steps

        CreateThread(function()
            while alpha > 0 do
                alpha = alpha - alpha_decrement
                if alpha <= 0 then
                    RemoveBlip(blip)
                    return
                end
                SetBlipAlpha(blip, math.floor(alpha))
                Wait(step_time)
            end
        end)

        CreateThread(function()
            local color_palette = {1, 29}
            local color_index = 1
            while alpha > 0 do
                color_index = color_index % #color_palette + 1
                SetBlipColour(blip, color_palette[color_index])
                Wait(750)
            end
        end)
    end 

end

return hooks