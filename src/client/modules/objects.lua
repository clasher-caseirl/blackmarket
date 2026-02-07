--- @module src.client.modules.objects
--- @description Handles creating and deleting drop objects

--- @section Guard

if rawget(_G, "__objects_module") then
    return _G.__objects_module
end

--- @section Module

local objects = {}
_G.__objects_module = objects

--- @section Tables

local created_entities = {}

--- @section Internal Functions

--- Requests a model and waits until it's loaded
--- @param model string: Model name to load
--- @param timeout number: Optional timeout in ms (default: 10000)
--- @return boolean: True if loaded successfully
local function request_model(model, timeout)
    local model_hash = GetHashKey(model)
    if HasModelLoaded(model_hash) then return true end
    
    RequestModel(model_hash)
    local start = GetGameTimer()
    local max_wait = timeout or 10000
    
    while not HasModelLoaded(model_hash) do
        if GetGameTimer() - start > max_wait then
            log("error", ("Model load timeout: %s"):format(model))
            return false
        end
        Wait(0)
    end
    return true
end

--- @section API Functions

--- Creates a drop object at location
--- @param model string: Model name to spawn
--- @param coords table: Spawn coordinates { x, y, z, w }
--- @return number: Entity handle or nil
function objects.create(model, coords)
    if not request_model(model) then return nil end
    local model_hash = GetHashKey(model)
    local entity = CreateObject(model_hash, coords.x, coords.y, coords.z, false, false, false)
    
    SetEntityHeading(entity, coords.w or 0.0)
    PlaceObjectOnGroundProperly(entity)
    FreezeEntityPosition(entity, true)
    SetEntityCollision(entity, true, true)
    SetModelAsNoLongerNeeded(model_hash)

    created_entities[entity] = true
    return entity
end

--- Removes a drop object
--- @param entity number: Entity handle to delete
function objects.remove(entity)
    if entity and DoesEntityExist(entity) then
        DeleteEntity(entity)
        created_entities[entity] = nil
    end
end

--- Track an entity that was created outside this module
--- @param entity number: Entity handle to track
function objects.track_entity(entity)
    if entity then
        created_entities[entity] = true
    end
end

--- Cleanup all created objects (for resource stop)
function objects.cleanup_all()
    for entity, _ in pairs(created_entities) do
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end
    created_entities = {}
end

--- Auto-cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        objects.cleanup_all()
    end
end)

return objects