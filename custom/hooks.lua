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
        local free_weight = exports['qb-inventory']:GetFreeWeight(source)

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
        TriggerClientEvent('qb-inventory:client:ItemBox', source, item_info, "add", quantity)

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
        TriggerClientEvent('qb-inventory:client:ItemBox', source, item_info, "remove", quantity)

        return player.Functions.RemoveItem(item_id, quantity)
    end

    --- Handles sending notifications to players
    --- Modify this function to integrate with your framework's notification system
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
        TriggerClientEvent('QBCore:Notify', source, opts.message, opts.type or 'primary', opts.duration or 4000)
    end

end

--- @section Client Functions

if not core.is_server then

    local QBCore = exports['qb-core']:GetCoreObject()

    --- Handles displaying notifications on the client
    --- Modify this function to integrate with your framework's notification system
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
        QBCore.Functions.Notify(opts.message, opts.type or 'primary', opts.duration or 4000)
    end

    --- Start lockpick minigame
    --- @param callback function: Callback with result
    function hooks.lockpick_minigame(callback)
        if not callback then return { success = false } end 

        --- @example QBCore
        local success = exports['qb-minigames']:Lockpick(3)
        callback({ success = success })
    end

end

return hooks