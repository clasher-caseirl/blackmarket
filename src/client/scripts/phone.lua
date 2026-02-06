--- @script src.client.scripts.phone
--- @description Handles everything phone related on client; nui callbacks, animations etc.

--- @section Modules

local settings = require("custom.settings")

--- @section Variables

local is_open = false

--- @section NUI Callbacks

--- Removes NUI focus
RegisterNUICallback("nui:remove_focus", function()
    log("debug", "nui:remove_focus - Focus cleared.")
    SetNuiFocus(false, false)
end)

--- Sends item id player chose to server for validation
--- @param data table: NUI data containing the item id
RegisterNUICallback("nui:confirm_order", function(data)
    if not data or not data.item_id then log("error", "nui:confirm_order - data or item_id missing") return end
    log("debug", ("nui:confirm_order - Player trying to purchase: %s"):format(data.item_id))
    
    -- @todo
end)

--- @section Events

--- Opens burner phone
RegisterNetEvent("blackmarket:cl:open_burner", function()
    if is_open then return end
    is_open = true

    SetNuiFocus(true, true)
    SendNUIMessage({ func = "build", brand = settings.phone_brand or "CELLTOWA" })
end)