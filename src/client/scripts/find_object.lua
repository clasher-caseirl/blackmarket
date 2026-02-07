--- @script src.client.scripts.find_object
--- @description Handles client side for find_object method

--- @section Modules

local blips = require("src.client.modules.blips")
local objects = require("src.client.modules.objects")
local animations = require("lib.animations")

--- @section Constants

local SPAWN_DISTANCE = 250.0
local DESPAWN_DISTANCE = 400.0

--- @section Variables

local active_delivery = nil
local delivery_blip = nil
local active_drops = {}
local active_interactions = {}

--- @section Helper Functions

--- Streams drop objects based on player distance
--- Spawns objects when player enters range, despawns when too far
--- @param player_coords vector3: Player position
local function stream_drops(player_coords)
    for drop_id, drop_data in pairs(active_drops) do
        local pos = vector3(drop_data.coords.x, drop_data.coords.y, drop_data.coords.z)
        local distance = #(player_coords - pos)
        
        if distance < SPAWN_DISTANCE and not drop_data.entity then
            drop_data.entity = objects.create(drop_data.model, drop_data.coords)
            active_interactions[drop_id] = { entity = drop_data.entity, coords = drop_data.coords }
        elseif distance >= DESPAWN_DISTANCE and drop_data.entity then
            objects.remove(drop_data.entity)
            drop_data.entity = nil
            active_interactions[drop_id] = nil
        end
    end
end

--- Monitor if player in vehicle to drop off the item
--- @param drop_id string: Drop identifier
--- @param attached_obj number: Attached object entity handle
local function monitor_drop(drop_id, attached_obj)
    CreateThread(function()
        while DoesEntityExist(attached_obj) do
            Wait(0)
            local player_ped = PlayerPedId()
            
            if IsPedInAnyVehicle(player_ped, false) then
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentString(translate("find_object.open_package"))
                EndTextCommandDisplayHelp(0, false, true, -1)
                
                if IsControlJustReleased(0, 38) then
                    ClearPedTasks(player_ped)
                    DetachEntity(attached_obj, true, false)
                    objects.remove(attached_obj)
                    TriggerServerEvent("blackmarket:sv:pickup_drop", drop_id)
                    break
                end
            end
        end
    end)
end

--- Executes pick up process
--- @param drop_id string: Drop identifier
--- @param entity number: Entity handle from active_drops
local function execute_pickup(drop_id, entity)
    local player_ped = PlayerPedId()

    animations.play(player_ped, {
        dict = "anim@mp_snowball",
        anim = "pickup_snowball",
        duration = 900,
        flags = 48
    }, function()
        local model_hash = GetEntityModel(entity)
        local attached_obj = CreateObject(model_hash, GetEntityCoords(player_ped), true, false, false)

        SetEntityCollision(attached_obj, false, true)
        AttachEntityToEntity(attached_obj, player_ped, GetPedBoneIndex(player_ped, 57005), 0.15, 0.05, 0.0, 160.0, 100.0, 100.0, true, true, false, true, 1, true)
        objects.track_entity(attached_obj)
        DeleteEntity(entity)
        active_interactions[drop_id] = nil
        active_drops[drop_id] = nil

        if delivery_blip then
            blips.delete(delivery_blip)
            delivery_blip = nil
        end
        
        TriggerServerEvent("blackmarket:sv:pickup_complete", drop_id)
        monitor_drop(drop_id, attached_obj)
    end)
end

--- Handle drop pickup request
--- @param drop_id string: Drop identifier
local function handle_pickup(drop_id)
    TriggerServerEvent("blackmarket:sv:validate_pickup", drop_id)
end

--- Cleanup delivery and drops
local function cleanup()
    if delivery_blip then
        blips.delete(delivery_blip)
        delivery_blip = nil
    end

    for drop_id, drop_data in pairs(active_drops) do
        if drop_data.entity then
            objects.remove(drop_data.entity)
        end
    end
    
    active_delivery = nil
    active_drops = {}
    active_interactions = {}
end

--- @section Events

--- Receive delivery location from server
--- @param location table: Location data with zone and spawns
--- @param method string: Delivery method type
RegisterNetEvent("blackmarket:cl:set_delivery_location", function(location, method)
    active_delivery = { location = location, method = method }
    if not location.zone then return end
    delivery_blip = blips.create_radius(location.zone.coords, location.zone.radius, location.zone.colour, location.label)
    log("debug", translate("find_object.location_set", location.label, method))
end)

--- Receive all drops from server
--- @param drops table: All active drops with model and coords
RegisterNetEvent("blackmarket:cl:set_drops", function(drops)
    active_drops = drops
    log("debug", translate("find_object.drops_synced"))
end)

--- Add new drop to active drops
--- @param drop_id string: Drop identifier
--- @param drop table: Drop data with model and coords
RegisterNetEvent("blackmarket:cl:add_drop", function(drop_id, drop)
    active_drops[drop_id] = drop
    log("debug", translate("find_object.drop_added", drop.model))
end)

--- Clear drops when delivery completes
RegisterNetEvent("blackmarket:cl:clear_drops", function()
    cleanup()
end)

--- Remove drop from client
--- @param drop_id string: Drop identifier
RegisterNetEvent("blackmarket:cl:remove_drop", function(drop_id)
    if active_drops[drop_id] then
        if active_drops[drop_id].entity then
            objects.remove(active_drops[drop_id].entity)
        end
        active_drops[drop_id] = nil
        active_interactions[drop_id] = nil
    end
end)

--- Execute pickup after server validation
--- @param drop_id string: Drop identifier
RegisterNetEvent("blackmarket:cl:execute_pickup", function(drop_id)
    local drop_data = active_drops[drop_id]
    if drop_data and drop_data.entity then
        execute_pickup(drop_id, drop_data.entity)
    end
end)

--- @section Threads

--- Interaction detection thread
CreateThread(function()
    while true do
        if next(active_interactions) then
            Wait(0)
            
            local player_coords = GetEntityCoords(PlayerPedId())
            local in_range = false
            local closest_drop_id = nil
            
            for drop_id, data in pairs(active_interactions) do
                local pos = vector3(data.coords.x, data.coords.y, data.coords.z)
                local distance = #(player_coords - pos)
                
                if distance < 2.0 then
                    in_range = true
                    closest_drop_id = drop_id
                    break
                end
            end
            
            if in_range then
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentString(translate("find_object.pickup_package"))
                EndTextCommandDisplayHelp(0, false, true, -1)
                if IsControlJustReleased(0, 38) then
                    handle_pickup(closest_drop_id)
                end
            end
        else
            Wait(1000)
        end
    end
end)

--- Streaming thread for drop objects
CreateThread(function()
    while true do
        local player_coords = GetEntityCoords(PlayerPedId())
        stream_drops(player_coords)
        Wait(500)
    end
end)

--- Request drops on join
CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(100)
    end
    
    Wait(3000)
    TriggerServerEvent("blackmarket:sv:request_drops")
end)

--- Cleanup on resource stop
AddEventHandler('onClientResourceStop', function(res)
    if GetCurrentResourceName() == res then
        cleanup()
        objects.cleanup_all()
    end
end)