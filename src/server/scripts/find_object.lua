--- @script src.server.scripts.find_object
--- @description Find object delivery method

--- @section Modules

local hooks = require("custom.hooks")
local item_defs = require("custom.configs.items")

local db = require("src.server.modules.database")

--- @section Variables

local active_drops = {}

--- @section Helper Functions

--- Validate player exists and is online
--- @param source number: Player server ID
--- @return boolean: True if player is valid
local function validate_player(source)
    if not source or source < 1 then log("error", translate("find_object.invalid_source")) return false end
    local identifier = hooks.get_player_identifier(source)
    if not identifier then log("error", translate("find_object.player_not_found", source)) return false end
    return true
end

--- Validate drop exists in active drops
--- @param drop_id string: Drop identifier
--- @return table|nil: Drop data or nil if invalid
local function validate_drop(drop_id)
    if not drop_id or type(drop_id) ~= "string" then log("error", translate("find_object.invalid_drop_id")) return nil end
    local drop = active_drops[drop_id]
    if not drop then log("warn", translate("find_object.drop_not_found", drop_id)) return nil end
    return drop
end

--- Validate player proximity to drop location
--- @param source number: Player server ID
--- @param drop_coords vector3: Drop coordinates
--- @param max_distance number: Maximum allowed distance
--- @return boolean: True if player is within range
local function validate_proximity(source, drop_coords, max_distance)
    local player_ped = GetPlayerPed(source)
    if not player_ped or player_ped == 0 then log("error", translate("find_object.invalid_ped", source)) return false end 
    local player_coords = GetEntityCoords(player_ped)
    local distance = #(player_coords - drop_coords)
    if distance > max_distance then log("warn", translate("find_object.too_far", source, distance, max_distance)) return false end
    return true
end

--- @section Core Functions

--- Start find object delivery
--- Creates drop object and notifies clients
--- @param source number: Player server ID
--- @param delivery_id string: Delivery identifier
--- @param location table: Location data with zone information
--- @param spawn table: Spawn coordinates {x, y, z, w}
--- @param model string: Object model hash or name
function core.start_find_object(source, delivery_id, location, spawn, model)
    if not validate_player(source) then log("error", translate("find_object.start_failed_player", delivery_id)) return end
    if not delivery_id or type(delivery_id) ~= "string" then log("error", translate("find_object.invalid_delivery_id")) return end
    if not location or not location.zone then log("error", translate("find_object.invalid_location", delivery_id)) return end
    if not spawn or not spawn.x or not spawn.y or not spawn.z then log("error", translate("find_object.invalid_spawn", delivery_id)) return end
    if not model or type(model) ~= "string" then log("error", translate("find_object.invalid_model", delivery_id)) return end
    
    active_drops[delivery_id] = { model = model, coords = spawn }
    
    TriggerClientEvent("blackmarket:cl:set_delivery_location", source, location, "find_object")
    TriggerClientEvent("blackmarket:cl:add_drop", -1, delivery_id, active_drops[delivery_id])
    
    log("debug", translate("find_object.drop_created", delivery_id, source))
end

--- Complete find object delivery
--- @param source number: Player server ID
--- @param delivery_id string: Delivery identifier
--- @return boolean: True if successful, false otherwise
function core.complete_find_object(source, delivery_id)
    if not validate_player(source) then log("error", translate("find_object.complete_failed_player", delivery_id)) return false end
    local delivery = core.get_delivery(delivery_id)
    if not delivery then log("error", translate("find_object.delivery_not_found", delivery_id)) return false end

    if not hooks.has_inventory_space(source, delivery.item_id, delivery.quantity) then
        log("warn", translate("find_object.no_inventory_space", source, delivery.item_id))
        hooks.send_notification(source, {
            type = "error",
            header = translate("find_object.notifications.header"),
            message = translate("burner.messages.no_space"),
            duration = 5000
        })
        return false
    end

    if not hooks.add_item(source, delivery.item_id, delivery.quantity) then
        log("error", translate("find_object.add_item_failed", source, delivery.item_id))
        hooks.send_notification(source, {
            type = "error",
            header = translate("find_object.notifications.header"),
            message = translate("burner.messages.add_item_failed"),
            duration = 5000
        })
        return false
    end

    local identifier = hooks.get_player_identifier(source)
    if identifier then
        local item_config = item_defs[delivery.item_id] or {}
        local rep_config = item_config.reputation or item_defs._defaults.reputation
        local xp_range = rep_config.xp_on_success
        local xp_reward = math.random(xp_range.min, xp_range.max)
        
        local rep_data = db.get_or_create(identifier)
        if rep_data then
            local new_rep = rep_data.reputation + xp_reward
            local new_items = rep_data.items_bought + delivery.quantity
            local new_total = rep_data.total_paid + delivery.price
            
            db.update_reputation(identifier, new_rep, new_items, new_total)
            log("debug", ("Updated reputation for %s: +%d xp (now %d)"):format(identifier, xp_reward, new_rep))
        end
    end
    
    log("success", translate("deliveries.completed", delivery.identifier, delivery.quantity, delivery.item_id))
    hooks.send_notification(source, {
        type = "success",
        header = translate("find_object.notifications.header"),
        message = translate("find_object.notifications.items_received", delivery.quantity, delivery.item_id),
        duration = 6000
    })
    
    TriggerClientEvent("blackmarket:cl:clear_drops", source)
    active_drops[delivery_id] = nil
    core.remove_delivery(delivery_id)
    
    return true
end

--- @section Events

--- Request all active drops for client sync on join/rejoin
RegisterServerEvent("blackmarket:sv:request_drops", function()
    local _src = source
    if not validate_player(_src) then log("warn", translate("find_object.request_failed_player", _src)) return end
    
    TriggerClientEvent("blackmarket:cl:set_drops", _src, active_drops)
    log("debug", translate("find_object.drops_synced_to", _src))
end)

--- Validate pickup request before allowing player to pick up drop
--- @param drop_id string: Drop identifier
RegisterServerEvent("blackmarket:sv:validate_pickup", function(drop_id)
    local _src = source
    if not validate_player(_src) then log("warn", translate("find_object.validate_failed_player", _src, drop_id)) return end
    local drop = validate_drop(drop_id)
    if not drop then log("warn", translate("find_object.validate_failed_drop", _src, drop_id)) return end
    local drop_coords = vector3(drop.coords.x, drop.coords.y, drop.coords.z)

    if not validate_proximity(_src, drop_coords, 5.0) then 
        log("warn", translate("find_object.validate_failed_proximity", _src, drop_id))
        hooks.send_notification(_src, {
            type = "error",
            header = translate("find_object.notifications.header"),
            message = translate("find_object.notifications.too_far_away"),
            duration = 4000
        })
        return 
    end

    TriggerClientEvent("blackmarket:cl:execute_pickup", _src, drop_id)
    log("debug", translate("find_object.pickup_validated", _src, drop_id))
end)

--- Player stored drop in vehicle
--- @param drop_id string: Drop identifier
RegisterServerEvent("blackmarket:sv:pickup_drop", function(drop_id)
    local _src = source
    if not validate_player(_src) then log("warn", translate("find_object.store_failed_player", _src, drop_id)) return end
    if not drop_id or type(drop_id) ~= "string" then log("error", translate("find_object.store_failed_invalid_id", _src)) return end
    
    local delivery = core.get_delivery(drop_id)
    if delivery and delivery.source ~= _src then
        hooks.send_notification(delivery.source, {
            type = "error",
            header = translate("find_object.notifications.header"),
            message = "Someone stole your delivery!",
            duration = 6000
        })
        log("warn", translate("find_object.wrong_owner", _src, drop_id, delivery.source))
    end

    core.complete_find_object(_src, drop_id)
end)

--- Pickup animation completed
--- @param drop_id string: Drop identifier
RegisterServerEvent("blackmarket:sv:pickup_complete", function(drop_id)
    local _src = source
    if not validate_player(_src) then log("warn", translate("find_object.pickup_complete_failed_player", _src, drop_id)) return end
    local drop = validate_drop(drop_id)
    if not drop then log("warn", translate("find_object.pickup_complete_failed_drop", _src, drop_id)) return end

    TriggerClientEvent("blackmarket:cl:remove_drop", -1, drop_id)
    active_drops[drop_id] = nil
    
    log("debug", translate("find_object.pickup_completed", _src, drop_id))
end)

--- @section Clean Up

--- Cleanup drops on player disconnect
AddEventHandler("playerDropped", function()
    local _src = source
    
    for drop_id, _ in pairs(active_drops) do
        local delivery = core.get_delivery(drop_id)
        if delivery and delivery.source == _src then
            active_drops[drop_id] = nil
            log("debug", translate("find_object.drop_cleaned", drop_id, _src))
        end
    end
end)