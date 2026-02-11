--- @script src.client.scripts.phone
--- @description Handles everything phone related on client; nui callbacks, animations etc.

--- @section Modules

local animations = require("lib.animations")
local requests = require("lib.requests")

local settings = require("custom.settings")
local hooks = require("custom.hooks")

--- @section Variables

local is_open = false
local phone_prop = nil

--- @section Functions 

--- Closes burner phone
local function close_phone(player_ped)
    is_open = false
    ClearPedTasks(player_ped)
    SetNuiFocus(false, false)
    SendNUIMessage({ func = "close_phone" })
    if phone_prop and DoesEntityExist(phone_prop) then
        DeleteObject(phone_prop)
        phone_prop = nil
        log("debug", "nui:close_burner - Phone prop deleted.")
    end
    log("debug", "nui:close_burner - Focus cleared.")
end

--- @section NUI Callbacks

--- Removes NUI focus
RegisterNUICallback("nui:close_burner", function()
    local player_ped = PlayerPedId()
    is_open = false
    ClearPedTasks(player_ped)
    SetNuiFocus(false, false)
    if phone_prop and DoesEntityExist(phone_prop) then
        DeleteObject(phone_prop)
        phone_prop = nil
        log("debug", "nui:close_burner - Phone prop deleted.")
    end
    log("debug", "nui:close_burner - Focus cleared.")
end)

--- Sends item id player chose to server for validation
--- @param data table: NUI data containing the item id
RegisterNUICallback("nui:confirm_order", function(data)
    if not data or not data.item_id then log("error", "nui:confirm_order - data or item_id missing") return end
    log("debug", ("nui:confirm_order - Player trying to purchase: %s"):format(data.item_id))
    TriggerServerEvent("blackmarket:sv:confirm_order", data.item_id)
end)

--- Removes NUI focus
RegisterNUICallback("nui:remove_focus", function()
    SetNuiFocus(false, false)
end)

--- @section Events

--- Opens burner phone
RegisterNetEvent("blackmarket:cl:open_burner", function()
    if is_open then return end
    is_open = true
    local player_ped = PlayerPedId()
    requests.model(settings.phone_prop)
    requests.anim("cellphone@")
    local coords = GetEntityCoords(player_ped)
    phone_prop = CreateObject(settings.phone_prop, coords.x + 2, coords.y, coords.z, true, true, true)
    AttachEntityToEntity(phone_prop, player_ped, GetPedBoneIndex(PlayerPedId(), 28422), 0, 0, 0, 50, 320, 50, false, false, false, false, 2, true)
    TaskPlayAnim(player_ped, "cellphone@", "cellphone_text_in", 3.0, 3.0, -1, 50, 0, false, false, false)
    core.timeout_chain({
        { delay = 1000, fn = function()
            SendNUIMessage({ func = "build", brand = translate("burner.brand_name") or "CELLTOWA" })
        end },
        { delay = 1000, fn = function()
            TriggerEvent("blackmarket:cl:set_text", translate("burner.messages.contact"), true, true)
        end },
        { delay = 2200, fn = function()
            TriggerEvent("blackmarket:cl:set_text", translate("burner.messages.sent"))
        end },
        { delay = 1500, fn = function()
            TriggerServerEvent("blackmarket:sv:request_menu")
        end }
    })
end)

--- Displays text message on phone screen
--- @param text string: Message to display with typewriter effect
--- @param is_message? boolean: Flags text as a message will display header and footer
--- @param send? boolean: Flag message as sending just replaces "REPLY" with "SEND" on ui isnt important
RegisterNetEvent("blackmarket:cl:set_text", function(text, is_message, send)
    if not is_open then return end
    SendNUIMessage({ func = "set_text", text = text, is_message = is_message, send = send })
end)

--- Displays menu items on phone screen
--- @param items table: Array of item objects with id, name, price, quantity
RegisterNetEvent("blackmarket:cl:set_menu", function(items, should_focus)
    if not is_open then return end
    SendNUIMessage({ func = "set_menu", items = items })
end)

--- Displays text message on phone screen
--- @param text string: Message to display with typewriter effect
--- @param send boolean: Flags a message as sending just replaces "REPLY" with "SEND" on ui isnt important
RegisterNetEvent("blackmarket:cl:set_screen", function(text, send)
    if not is_open then return end
    SendNUIMessage({ func = "set_screen", screen = "home" })
end)

--- Toggles nui focus
RegisterNetEvent("blackmarket:cl:toggle_nui_focus", function()
    local is_nui_focused = IsNuiFocused()
    SetNuiFocus(not is_nui_focused, not is_nui_focused)
end)

--- Triggered by server with zone coords
--- @param coords vector3: The zone coordinates to check scumminess for
RegisterNetEvent("blackmarket:cl:get_zone_scumminess", function(coords)
    local zone = GetZoneAtCoords(coords.x, coords.y, coords.z)
    local scumminess = GetZoneScumminess(zone)
    print("scum level: ", scumminess)
    TriggerServerEvent("blackmarket:sv:check_police_alert", scumminess, coords)
end)

--- Triggers hooks to display police alerts to correct players
--- This is handled server side, make sure to setup hooks correctly for your framework.
--- @param coords vector3: Coordinates where the alert originated
--- @param label string: Alert message to display to police
RegisterNetEvent("blackmarket:cl:police_alert", function(coords, label)
    hooks.display_police_alert({ coords = coords, label = label })
end)

--- Closes phone 
--- Used if anything fails serverside mainly
RegisterNetEvent("blackmarket:cl:close_phone", function()
    if not is_open then return end
    local player_ped = PlayerPedId()
    close_phone(player_ped)
end)