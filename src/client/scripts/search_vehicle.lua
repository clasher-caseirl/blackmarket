--- @script src.client.scripts.search_vehicle
--- @description Handles client side for search_vehicle method

--- @section Modules

local vehicles = require("lib.vehicles")
local requests = require("lib.requests")

local hooks = require("custom.hooks")

local blips = require("src.client.modules.blips")

--- @section Variables

local active_delivery = nil
local delivery_blip = nil
local active_vehicles = {}

--- @section Helper Functions

--- Cleanup delivery blip
local function cleanup()
    if delivery_blip then
        blips.delete(delivery_blip)
        delivery_blip = nil
    end
    active_delivery = nil
end

--- @section Events

--- Receive delivery location from server
--- @param location table: Location data with zone and spawns
--- @param method string: Delivery method type
RegisterNetEvent("blackmarket:cl:set_vehicle_location", function(location, method)
    active_delivery = { location = location, method = method }
    if not location.zone then return end
    delivery_blip = blips.create_radius(location.zone.coords, location.zone.radius, location.zone.colour, location.label)
    log("debug", translate("search_vehicle.location_set", location.label, method))
end)

--- Start lockpick minigame
--- @param vehicle_id string: Vehicle identifier
RegisterNetEvent("blackmarket:cl:start_lockpick", function(vehicle_id)
    local player_ped = PlayerPedId()
    requests.anim("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
    TaskPlayAnim(player_ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 8.0, -8.0, -1, 1, 0, false, false, false)

    hooks.lockpick_minigame(function(result)
        ClearPedTasks(player_ped)
        if result.success then
            TriggerServerEvent("blackmarket:sv:lockpick_success", vehicle_id)
        end
    end)
end)

--- Add vehicle to tracking (EVERYONE receives this)
--- @param vehicle_id string: Vehicle identifier
--- @param vehicle table: Vehicle data with net_id and coords
RegisterNetEvent("blackmarket:cl:add_vehicle", function(vehicle_id, vehicle)
    active_vehicles[vehicle_id] = vehicle
    log("debug", translate("search_vehicle.vehicle_added", vehicle_id))
end)

--- Remove specific vehicle from tracking (EVERYONE receives this)
--- @param vehicle_id string: Vehicle identifier
RegisterNetEvent("blackmarket:cl:remove_vehicle", function(vehicle_id)
    if active_vehicles[vehicle_id] then
        active_vehicles[vehicle_id] = nil
        log("debug", translate("search_vehicle.vehicle_removed", vehicle_id))
    end
    if delivery_blip then
        blips.delete(delivery_blip)
        delivery_blip = nil
    end
end)

--- Unlock vehicle and open trunk
--- @param vehicle_id string: Vehicle identifier
--- @param net_id number: Vehicle network ID
RegisterNetEvent("blackmarket:cl:unlock_vehicle", function(vehicle_id, net_id)
    if active_vehicles[vehicle_id] then
        active_vehicles[vehicle_id].unlocked = true
    end
    
    local veh_entity = NetworkGetEntityFromNetworkId(net_id)
    if DoesEntityExist(veh_entity) then
        SetVehicleDoorOpen(veh_entity, 5, false, false)
        log("debug", translate("search_vehicle.trunk_opened_client", vehicle_id))
    end
end)

--- Search trunk animation
--- @param vehicle_id string: Vehicle identifier
RegisterNetEvent("blackmarket:cl:search_trunk", function(vehicle_id)
    local player_ped = PlayerPedId()
    local animations = require("lib.animations")
    
    animations.play(player_ped, {
        dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
        anim = "machinic_loop_mechandplayer",
        duration = 3000,
        flags = 1
    })
end)

--- @section Threads

--- Distance tracking thread - lockpick/search prompt
CreateThread(function()
    while true do
        if next(active_vehicles) then
            Wait(0)
            
            local player_ped = PlayerPedId()
            local player_coords = GetEntityCoords(player_ped)
            local in_range = false
            local closest_vehicle_id = nil
            local is_trunk_search = false
            
            for vehicle_id, vehicle_data in pairs(active_vehicles) do
                if not NetworkDoesEntityExistWithNetworkId(vehicle_data.net_id) then
                    break
                end
                local veh_entity = NetworkGetEntityFromNetworkId(vehicle_data.net_id)
                if DoesEntityExist(veh_entity) then
                    if vehicle_data.unlocked then
                        local model = GetEntityModel(veh_entity)
                        local model_name = GetDisplayNameFromVehicleModel(model):lower()
                        local min, max = GetModelDimensions(model)
                        local is_rear_engine = core.settings.rear_engine_vehicles[model_name]
                        local trunk_offset = is_rear_engine and GetOffsetFromEntityInWorldCoords(veh_entity, 0.0, max.y + 0.5, 0.0) or GetOffsetFromEntityInWorldCoords(veh_entity, 0.0, min.y - 0.5, 0.0)
                        local trunk_distance = #(player_coords - trunk_offset)
                        
                        if trunk_distance < 2.0 then
                            in_range = true
                            closest_vehicle_id = vehicle_id
                            is_trunk_search = true
                            break
                        end
                    else
                        local veh_coords = GetEntityCoords(veh_entity)
                        local distance = #(player_coords - veh_coords)
                        
                        if distance < 3.0 and not IsPedInAnyVehicle(player_ped, false) then
                            in_range = true
                            closest_vehicle_id = vehicle_id
                            is_trunk_search = false
                            break
                        end
                    end
                end
            end
            
            if in_range then
                BeginTextCommandDisplayHelp("STRING")
                if is_trunk_search then
                    AddTextComponentString(translate("search_vehicle.search_vehicle"))
                else
                    AddTextComponentString(translate("search_vehicle.lockpick_vehicle"))
                end
                EndTextCommandDisplayHelp(0, false, true, -1)
                
                if IsControlJustReleased(0, 38) then
                    if is_trunk_search then
                        TriggerServerEvent("blackmarket:sv:search_vehicle", closest_vehicle_id)
                    else
                        TriggerServerEvent("blackmarket:sv:attempt_lockpick", closest_vehicle_id)
                    end
                end
            end
        else
            Wait(1000)
        end
    end
end)

--- Cleanup on resource stop
AddEventHandler('onClientResourceStop', function(res)
    if GetCurrentResourceName() == res then
        cleanup()
        active_vehicles = {}
    end
end)