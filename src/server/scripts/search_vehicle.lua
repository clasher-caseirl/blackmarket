--- @script src.server.scripts.search_vehicle
--- @description Search vehicle delivery method

--- @section Modules

local hooks = require("custom.hooks")
local vehicles = require("lib.vehicles")
local db = require("src.server.modules.database")
local item_defs = require("custom.configs.items")

--- @section Variables

local active_vehicles = {}

--- @section Helper Functions

--- Validate player exists and is online
--- @param source number: Player server ID
--- @return boolean: True if player is valid
local function validate_player(source)
    if not source or source < 1 then log("error", translate("search_vehicle.invalid_source")) return false end
    local identifier = hooks.get_player_identifier(source)
    if not identifier then log("error", translate("search_vehicle.player_not_found", source)) return false end
    return true
end

--- Validate vehicle exists in active vehicles
--- @param vehicle_id string: Vehicle identifier
--- @return table|nil: Vehicle data or nil if invalid
local function validate_vehicle(vehicle_id)
    if not vehicle_id or type(vehicle_id) ~= "string" then log("error", translate("search_vehicle.invalid_vehicle_id")) return nil end
    local vehicle = active_vehicles[vehicle_id]
    if not vehicle then log("warn", translate("search_vehicle.vehicle_not_found", vehicle_id)) return nil end
    return vehicle
end

--- @section Core Functions

--- Start search vehicle delivery
--- @param source number: Player server ID (buyer)
--- @param delivery_id string: Delivery identifier
--- @param location table: Location data with zone information
--- @param spawn table: Spawn coordinates {x, y, z, w}
--- @param model string: Vehicle model hash or name
function core.start_search_vehicle(source, delivery_id, location, spawn, model)
    if not validate_player(source) then log("error", translate("search_vehicle.start_failed_player", delivery_id)) return end
    if not delivery_id or type(delivery_id) ~= "string" then log("error", translate("search_vehicle.invalid_delivery_id")) return end
    if not location or not location.zone then log("error", translate("search_vehicle.invalid_location", delivery_id)) return end
    if not spawn or not spawn.x or not spawn.y or not spawn.z then log("error", translate("search_vehicle.invalid_spawn", delivery_id)) return end
    if not model or type(model) ~= "string" then log("error", translate("search_vehicle.invalid_model", delivery_id)) return end
    
    TriggerClientEvent("blackmarket:cl:preload_model", -1, model)

    local entity, net_id = vehicles.spawn(model, { coords = spawn, vehicle_type = "automobile" })
    if not net_id then log("error", translate("search_vehicle.spawn_failed", delivery_id, model)) return end

    SetVehicleDoorsLocked(entity, 2)
    
    active_vehicles[delivery_id] = {
        entity = entity,
        net_id = net_id,
        model = model,
        coords = spawn,
        unlocked = false,
        searched = false
    }
    
    TriggerClientEvent("blackmarket:cl:set_vehicle_location", source, location, "search_vehicle")
    TriggerClientEvent("blackmarket:cl:add_vehicle", -1, delivery_id, active_vehicles[delivery_id])
    log("debug", translate("search_vehicle.vehicle_created", delivery_id, source))
end

--- Complete search vehicle delivery
--- @param source number: Player server ID
--- @param delivery_id string: Delivery identifier
--- @return boolean: True if successful, false otherwise
function core.complete_search_vehicle(source, delivery_id)
    if not validate_player(source) then log("error", translate("search_vehicle.complete_failed_player", delivery_id)) return false end
    
    local delivery = core.get_delivery(delivery_id)
    if not delivery then log("error", translate("search_vehicle.delivery_not_found", delivery_id)) return false end

    if not hooks.has_inventory_space(source, delivery.item_id, delivery.quantity) then
        log("warn", translate("search_vehicle.no_inventory_space", source, delivery.item_id))
        hooks.send_notification(source, { type = "error", header = translate("search_vehicle.notifications.header"), message = translate("burner.messages.no_space"), duration = 5000 })
        return false
    end

    if not hooks.add_item(source, delivery.item_id, delivery.quantity) then
        log("error", translate("search_vehicle.add_item_failed", source, delivery.item_id))
        hooks.send_notification(source, { type = "error", header = translate("search_vehicle.notifications.header"), message = translate("burner.messages.add_item_failed"), duration = 5000 })
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
    
    hooks.send_notification(source, { type = "success", header = translate("search_vehicle.notifications.header"), message = translate("search_vehicle.notifications.items_received", delivery.quantity, delivery.item_id), duration = 6000 })

    TriggerClientEvent("blackmarket:cl:remove_vehicle", -1, delivery_id)
    
    local vehicle_data = active_vehicles[delivery_id]
    active_vehicles[delivery_id] = nil
    core.remove_delivery(delivery_id)
    
    local delete_delay = math.random(10000, 18000)
    SetTimeout(delete_delay, function()
        if vehicle_data and vehicle_data.entity and DoesEntityExist(vehicle_data.entity) then
            DeleteEntity(vehicle_data.entity)
            log("debug", translate("search_vehicle.vehicle_deleted_delay", delivery_id))
        end
    end)
    
    return true
end

--- @section Events

--- Attempt lockpick on vehicle - ANYONE CAN LOCKPICK
--- @param vehicle_id string: Vehicle identifier
RegisterServerEvent("blackmarket:sv:attempt_lockpick", function(vehicle_id)
    local _src = source
    if not validate_player(_src) then log("warn", translate("search_vehicle.lockpick_failed_player", _src, vehicle_id)) return end
    
    local vehicle_data = validate_vehicle(vehicle_id)
    if not vehicle_data then log("warn", translate("search_vehicle.lockpick_failed_vehicle", _src, vehicle_id)) return end
    
    if vehicle_data.unlocked then
        log("warn", translate("search_vehicle.already_unlocked", _src, vehicle_id))
        return
    end
    
    if not hooks.has_item(_src, "lockpick", 1) then
        log("warn", translate("search_vehicle.no_lockpick", _src))
        hooks.send_notification(_src, {
            type = "error",
            header = translate("search_vehicle.notifications.header"),
            message = translate("search_vehicle.notifications.need_lockpick"),
            duration = 4000
        })
        return
    end
    
    hooks.remove_item(_src, "lockpick", 1)
    TriggerClientEvent("blackmarket:cl:start_lockpick", _src, vehicle_id)
    log("debug", translate("search_vehicle.lockpick_started", _src, vehicle_id))
end)

--- Lockpick success - open trunk for ALL clients
--- @param vehicle_id string: Vehicle identifier
RegisterServerEvent("blackmarket:sv:lockpick_success", function(vehicle_id)
    local _src = source
    if not validate_player(_src) then log("warn", translate("search_vehicle.lockpick_failed_player", _src, vehicle_id)) return end
    local vehicle_data = validate_vehicle(vehicle_id)
    if not vehicle_data then log("warn", translate("search_vehicle.lockpick_failed_vehicle", _src, vehicle_id)) return end
    if vehicle_data.unlocked then log("warn", translate("search_vehicle.already_unlocked", _src, vehicle_id)) return end
    
    hooks.send_notification(_src, {
        type = "success",
        header = translate("search_vehicle.notifications.header"),
        message = translate("search_vehicle.notifications.unlocked"),
        duration = 3000
    })
    
    active_vehicles[vehicle_id].unlocked = true

    TriggerClientEvent("blackmarket:cl:unlock_vehicle", -1, vehicle_id, vehicle_data.net_id)
    log("debug", translate("search_vehicle.vehicle_unlocked", _src, vehicle_id))
end)

--- Search vehicle for items - ANYONE CAN SEARCH ONCE UNLOCKED
--- @param vehicle_id string: Vehicle identifier
RegisterServerEvent("blackmarket:sv:search_vehicle", function(vehicle_id)
    local _src = source
    if not validate_player(_src) then log("warn", translate("search_vehicle.lockpick_failed_player", _src, vehicle_id)) return end
    local vehicle_data = validate_vehicle(vehicle_id)
    if not vehicle_data then log("warn", translate("search_vehicle.lockpick_failed_vehicle", _src, vehicle_id)) return end
    
    if not vehicle_data.unlocked then
        log("warn", translate("search_vehicle.search_locked", _src, vehicle_id))
        hooks.send_notification(_src, {
            type = "error",
            header = translate("search_vehicle.notifications.header"),
            message = translate("search_vehicle.notifications.trunk_locked"),
            duration = 4000
        })
        return
    end
    
    if vehicle_data.searched then
        log("warn", translate("search_vehicle.already_searched", _src, vehicle_id))
        hooks.send_notification(_src, {
            type = "error",
            header = translate("search_vehicle.notifications.header"),
            message = translate("search_vehicle.notifications.already_looted"),
            duration = 4000
        })
        return
    end
    active_vehicles[vehicle_id].searched = true
    TriggerClientEvent("blackmarket:cl:search_trunk", _src, vehicle_id)

    SetTimeout(3000, function()
        local delivery = core.get_delivery(vehicle_id)
        if delivery and delivery.source ~= _src then
            hooks.send_notification(delivery.source, {
                type = "error",
                header = translate("search_vehicle.notifications.header"),
                message = translate("search_vehicle.notifications.someone_stole"),
                duration = 6000
            })
            log("warn", translate("search_vehicle.wrong_owner", _src, vehicle_id, delivery.source))
        end
        
        core.complete_search_vehicle(_src, vehicle_id)
    end)
end)

--- Cleanup all vehicles on resource stop
AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() == res then
        for vehicle_id, vehicle_data in pairs(active_vehicles) do
            if vehicle_data.entity and DoesEntityExist(vehicle_data.entity) then
                DeleteEntity(vehicle_data.entity)
            end
        end
        active_vehicles = {}
        log("debug", "All search vehicles cleaned up on resource stop")
    end
end)