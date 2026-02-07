--- @module src.client.modules.blips
--- @description Handles creating and deleting blips nothing fancy

--- @section Guard

if rawget(_G, "__blips_module") then
    return _G.__blips_module
end

--- @section Module

local blips = {}
_G.__blips_module = blips

--- @section Functions

--- Creates a map blip for a given location
--- @param location_id string: Location identifier used as fallback label
--- @param coords table: World coordinates { x, y, z }
--- @param blip_cfg table: Blip configuration (enabled, sprite, scale, colour)
--- @param label string|nil: Optional display label for the blip
--- @return number|nil: Blip handle or nil if blip creation is disabled
function blips.create(location_id, coords, blip_cfg, label)
    if not blip_cfg or not blip_cfg.enabled then return nil end
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(blip, blip_cfg.sprite or 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, blip_cfg.scale or 0.7)
    SetBlipColour(blip, blip_cfg.colour or 0)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label or location_id)
    EndTextCommandSetBlipName(blip)
    return blip
end

--- Creates a radius blip for a zone
--- @param zone_coords table: Zone center coordinates { x, y, z }
--- @param radius number: Zone radius in meters
--- @param colour number: Blip colour
--- @param label string|nil: Optional label for the zone
--- @return number: Blip handle
function blips.create_radius(zone_coords, radius, colour, label)
    local blip = AddBlipForRadius(zone_coords.x, zone_coords.y, zone_coords.z, radius)
    
    SetBlipColour(blip, tonumber(colour) or 0)
    SetBlipDisplay(blip, 2)
    SetBlipAsShortRange(blip, false)
    SetBlipAlpha(blip, 128)
    if label then
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(label)
        EndTextCommandSetBlipName(blip)
    end
    return blip
end

--- Deletes a blip if it exists
--- @param blip number: Blip handle to remove
function blips.delete(blip)
    if blip and DoesBlipExist(blip) then RemoveBlip(blip) end
end

return blips