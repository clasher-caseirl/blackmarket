--- @script src.server.scripts.deliveries
--- @description Core delivery system handles routing into different methods, and delivery tracking.

--- @section Modules

local location_defs = require("custom.configs.locations")

--- @section Variables

local active_deliveries = {}

--- @section Helper Functions

--- Get available locations for delivery method
--- @param method string: Delivery method key
--- @return table|nil: Available location or nil
local function get_available_location(method)
    local locations = location_defs[method]
    if not locations then 
        log("error", translate("deliveries.no_locations_config", method))
        return nil 
    end
    
    local available = {}
    for _, location in ipairs(locations) do
        if not active_deliveries[location.label] then
            available[#available + 1] = location
        end
    end
    
    if #available == 0 then return nil end
    return available[math.random(1, #available)]
end

--- @section Core Functions

--- Start delivery - routes to method-specific function
--- @param source number: Player server ID
--- @param data table: Order data
function core.start_delivery(source, data)
    local method = data.delivery_method
    if not method then
        TriggerClientEvent("blackmarket:cl:set_text", source, translate("burner.messages.no_method"), true, true)
        return
    end

    local handlers = {
        find_object = function(source, delivery_id, location, spawn, model)
            core.start_find_object(source, delivery_id, location, spawn, model)
        end,
        search_vehicle = function(source, delivery_id, location, spawn, model)
            core.start_search_vehicle(source, delivery_id, location, spawn, model)
        end,
        deliver_vehicle = function(source, delivery_id, location, spawn, model)
            core.start_deliver_vehicle(source, delivery_id, location, spawn, model)
        end,
    }
    local handler = handlers[method]
    if not handler then
        log("error", translate("deliveries.no_handler", method))
        TriggerClientEvent("blackmarket:cl:set_text", source, translate("burner.messages.no_method"), true, true)
        return
    end
    
    local location = get_available_location(method)
    if not location then
        TriggerClientEvent("blackmarket:cl:set_text", source, translate("burner.messages.no_locations"), true, true)
        return
    end
    
    local random_spawn = location.spawns[math.random(1, #location.spawns)]
    local random_model = data.delivery_models[math.random(1, #data.delivery_models)]
    
    local delivery_id = ("%s_%d"):format(location.label, GetGameTimer())
    
    active_deliveries[delivery_id] = {
        source = source,
        identifier = data.identifier,
        item_id = data.item_id,
        quantity = data.quantity,
        price = data.price,
        method = method,
        location = location,
        timestamp = GetGameTimer()
    }
    
    log("debug", translate("deliveries.started", source, data.item_id, location.label))
    
    handler(source, delivery_id, location, random_spawn, random_model)
end

--- Get delivery by ID
--- @param delivery_id string: Delivery identifier
--- @return table|nil: Delivery data
function core.get_delivery(delivery_id)
    return active_deliveries[delivery_id]
end

--- Remove delivery
--- @param delivery_id string: Delivery identifier
function core.remove_delivery(delivery_id)
    active_deliveries[delivery_id] = nil
end

--- Cleanup on disconnect
AddEventHandler('playerDropped', function()
    local _src = source
    for delivery_id, delivery in pairs(active_deliveries) do
        if delivery.source == _src then
            active_deliveries[delivery_id] = nil
        end
    end
end)