--- @script src.server.scripts.phone
--- @description Handles server side for phone; confirming orders essentially

--- @section Modules

local item_defs = require("custom.configs.items")
local level_defs = require("custom.configs.levels")
local hooks = require("custom.hooks")

local db = require("src.server.modules.database")

local cooldowns = require("lib.cooldowns")

--- @section Variables

local active_menus = {}

--- @section Item Registration

local function register_phone()
    hooks.register_usable_item("blackmarket_phone", function(source)
        TriggerClientEvent("blackmarket:cl:open_burner", source)
    end)
end
SetTimeout(50, function()
    register_phone()
end)

--- @section Functions

--- Gets config value with default fallback
--- @param item_id string: Item identifier to lookup
--- @param key string: Config key to retrieve
--- @return any: Config value from item or defaults
local function item_cfg(item_id, key)
    local item = item_defs[item_id]
    local item_value = item and item[key]
    local default_value = item_defs._defaults[key]

    if type(default_value) ~= "table" then
        return item_value or default_value
    end
    
    local merged = {}
    for k, v in pairs(default_value) do
        merged[k] = v
    end
    
    if item_value then
        for k, v in pairs(item_value) do
            merged[k] = v
        end
    end
    
    return merged
end

--- Get reputation level from points
--- @param rep_points integer: Player reputation points
--- @param level_defs table: Level definitions table
--- @return integer: Reputation level
local function get_rep_level(rep_points, level_defs)
    for level = #level_defs, 1, -1 do
        if rep_points >= level_defs[level].range.min then
            return level
        end
    end

    return 1
end

--- Calculates final price based on reputation
--- @param base_price number: Base item price
--- @param rep_points integer: Player reputation points
--- @param item_id string: Item identifier for config lookup
--- @return number: Final calculated price
local function calculate_price(base_price, rep_points, item_id)
    local price_config = item_cfg(item_id, "price")
    if price_config.disable_scaling then return base_price end
    local discount_percent = math.min(rep_points / 100 * price_config.rep_discount, price_config.max_discount)
    local discount_amount = (base_price * discount_percent) / 100
    return math.floor(base_price - discount_amount)
end

--- Calculates final quantity based on reputation
--- @param base_quantity number: Base item quantity
--- @param rep_points integer: Player reputation points
--- @param item_id string: Item identifier for config lookup
--- @return number: Final calculated quantity
local function calculate_quantity(base_quantity, rep_points, item_id)
    local quantity_config = item_cfg(item_id, "quantity")
    if quantity_config.disable_scaling then return base_quantity end
    local increase_percent = math.min(rep_points / 100 * quantity_config.rep_increase, quantity_config.max_increase)
    local increase_amount = (base_quantity * increase_percent) / 100
    return math.floor(base_quantity + increase_amount)
end

--- Build menu from items based on reputation
--- @param rep_points integer: Player reputation points
--- @return table: Array of menu items with id, name, price, quantity
local function build_menu(rep_points)
    local menu_items = {}
    for item_id, item_def in pairs(item_defs) do
        if item_id ~= "_defaults" then
            local rep_config = item_cfg(item_id, "reputation")
            if rep_points >= rep_config.required_level then
                local price_config = item_cfg(item_id, "price")
                local quantity_config = item_cfg(item_id, "quantity")
                local final_price = calculate_price(price_config.base, rep_points, item_id)
                local final_quantity = calculate_quantity(quantity_config.base, rep_points, item_id)
                local rep_level = get_rep_level(rep_points, level_defs)
                
                menu_items[#menu_items + 1] = { id = item_id, name = item_def.label, price = final_price, quantity = final_quantity }
            end
        end
    end
    return menu_items, rep_level
end

--- Validate order cooldown
--- @param source number: Player server ID
--- @return boolean: True if valid (not on cooldown)
--- @return string: Error message if validation fails
local function validate_cooldown(source)
    if cooldowns.check(source, "blackmarket_order", false) then
        return false, "burner.messages.on_cooldown"
    end
    return true
end

--- Validate player has active menu
--- @param source number: Player server ID
--- @return boolean: True if valid
--- @return string: Error message if validation fails
local function validate_menu(source)
    if not active_menus[source] then
        return false, "burner.messages.no_active_order"
    end
    return true
end

--- Validate item exists
--- @param item_id string: Item identifier
--- @return boolean: True if item exists
--- @return string: Error message if validation fails
local function validate_item(item_id)
    if not item_defs[item_id] then
        return false, "burner.messages.item_not_found"
    end
    return true
end

--- Validate rep requirement
--- @param rep_points integer: Player reputation points
--- @param item_id string: Item identifier
--- @return boolean: True if player meets requirement
--- @return string: Error message if validation fails
local function validate_rep_requirement(rep_points, item_id)
    local rep_config = item_cfg(item_id, "reputation")
    if rep_points >= rep_config.required_level then return true end
    return false, "burner.messages.rep_too_low"
end

--- Validate inventory and affordability
--- @param source number: Player server ID
--- @param item_id string: Item identifier
--- @param price number: Final calculated price
--- @param quantity number: Final calculated quantity
--- @return boolean: True if player can complete transaction
--- @return string: Error message if validation fails
local function validate_transaction(src, item_id, price, quantity)
    local price_config = item_cfg(item_id, "price")
    if not hooks.can_afford(src, price_config.payment_method, "balance", price) then
        return false, "burner.messages.cannot_afford"
    end
    if not hooks.has_inventory_space(src, item_id, quantity) then
        return false, "burner.messages.no_space"
    end
    return true
end

--- @section Events

--- Requests menu for player
RegisterServerEvent("blackmarket:sv:request_menu", function()
    local _src = source
    local identifier = hooks.get_player_identifier(_src)
    if not identifier then log("error", ("request_menu: Could not get identifier for player %s"):format(_src)) return end

    local rep_record = db.get_or_create(identifier)
    local rep_points = rep_record.reputation
    
    local can_give_menu = true -- @todo replace with some method? police counts? no available locs? etc.
    if not can_give_menu then
        TriggerClientEvent("blackmarket:cl:set_text", _src, translate("burner.messages.response_busy"), true, true)
        return
    end
    
    active_menus[_src] = { identifier = identifier, rep_points = rep_points, timestamp = GetGameTimer() }
    
    local menu_items, rep_level = build_menu(rep_points, level_defs)

    core.timeout_chain({
        { delay = 1500, fn = function()
            TriggerClientEvent("blackmarket:cl:set_text", _src, translate("burner.messages.response_success"), true, true)
        end },
        { delay = 2000, fn = function()
            TriggerClientEvent("blackmarket:cl:set_text", _src, translate("burner.messages.received_menu"))
        end },
        { delay = 2000, fn = function()
            TriggerClientEvent("blackmarket:cl:set_menu", _src, menu_items, rep_level)
            TriggerClientEvent("blackmarket:cl:toggle_nui_focus", _src)
        end }
    })
end)

--- Confirms order and validates everything
--- Payment is processed first, then delivery is started
--- @param item_id string: Item identifier being purchased
RegisterServerEvent("blackmarket:sv:confirm_order", function(item_id)
    local _src = source
    
    local ok, err = validate_cooldown(_src)
    if not ok then
        TriggerClientEvent("blackmarket:cl:set_text", _src, translate(err), true, true)
        return
    end
    
    local ok, err = validate_menu(_src)
    if not ok then
        TriggerClientEvent("blackmarket:cl:set_text", _src, translate(err), true, true)
        return
    end
    
    local ok, err = validate_item(item_id)
    if not ok then
        TriggerClientEvent("blackmarket:cl:set_text", _src, translate(err), true, true)
        return
    end
    
    local menu = active_menus[_src]
    
    local ok, err = validate_rep_requirement(menu.rep_points, item_id)
    if not ok then
        TriggerClientEvent("blackmarket:cl:set_text", _src, translate(err), true, true)
        return
    end
    
    local price_config = item_cfg(item_id, "price")
    local quantity_config = item_cfg(item_id, "quantity")
    
    local final_price = calculate_price(price_config.base, menu.rep_points, item_id)
    local final_quantity = calculate_quantity(quantity_config.base, menu.rep_points, item_id)
    
    local ok, err = validate_transaction(_src, item_id, final_price, final_quantity)
    if not ok then
        TriggerClientEvent("blackmarket:cl:set_text", _src, translate(err), true, true)
        return
    end
    
    if not hooks.remove_payment(_src, price_config.payment_method, "balance", final_price) then
        TriggerClientEvent("blackmarket:cl:set_text", _src, translate("burner.messages.payment_failed"), true, true)
        return
    end
    
    local delivery_config = item_cfg(item_id, "delivery")
    
    local order_data = {
        identifier = menu.identifier,
        item_id = item_id,
        quantity = final_quantity,
        price = final_price,
        delivery_method = delivery_config.method,
        delivery_models = delivery_config.models,
        timestamp = GetGameTimer()
    }
    
    log("success", translate("deliveries.order_confirmed", menu.identifier, final_quantity, item_id, final_price))

    core.start_delivery(_src, order_data)
    cooldowns.add(_src, "blackmarket_order", core.settings.menu_order_cooldown, false)
    active_menus[_src] = nil
end)

--- @section Clean Up

--- Cleanup menu on player disconnect
AddEventHandler('playerDropped', function()
    local _src = source
    active_menus[_src] = nil
end)