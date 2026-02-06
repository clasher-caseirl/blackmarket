--- @script src.client.scripts.phone
--- @description Handles everything phone related on client; nui callbacks, animations etc.

--- @section Modules

local item_defs = require("custom.configs.items")
local hooks = require("custom.hooks")

--- @section Functions

--- @section Events

--- Requests a menu for player, rejects based on various settings: no zones available, no police *(if enabled)* etc
--- @todo test event...
--- @todo rep based items, rejections, police stuff.. etc
RegisterServerEvent("blackmarket:sv:request_menu", function()
    local _src = source
    
    local can_give_menu = true
    
    local items = {
        { id = 'weed', name = 'Weed', price = 100, quantity = 10 },
        { id = 'coke', name = 'Coke', price = 250, quantity = 2 },
        { id = 'heroin', name = 'Heroin', price = 500, quantity = 3 },
        { id = 'mdma', name = 'MDMA', price = 175, quantity = 5 },
        { id = 'meth', name = 'Meth', price = 300, quantity = 1 },
    }

    if can_give_menu then
        TriggerEvent("blackmarket:cl:set_text", translate("burner.messages.received"))
        core.timeout_chain({
            { delay = 1500, fn = function()
                TriggerClientEvent("blackmarket:cl:set_text", _src, translate("burner.messages.response_success"), true, true)
            end },
            { delay = 2000, fn = function()
                TriggerClientEvent("blackmarket:cl:set_text", _src, translate("burner.messages.received_menu"))
            end },
            { delay = 2000, fn = function()
                TriggerClientEvent("blackmarket:cl:focus_nui", _src)
                TriggerClientEvent("blackmarket:cl:set_menu", _src, items)
            end }
        })
    else
        TriggerClientEvent("blackmarket:cl:set_text", _src, translate("burner.messages.response_busy"), true, true)
    end

end)