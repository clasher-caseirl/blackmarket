--- @script init
--- @description Main initialization file

--- @section Bootstrap

core = setmetatable({}, { __index = _G })

--- @section Natives

core.resource_name = GetCurrentResourceName()
core.is_server = IsDuplicityVersion()

--- @section Resource Metadata

core.resource_metadata = {
    name = GetResourceMetadata(core.resource_name, "name", 0) or "unknown",
    description = GetResourceMetadata(core.resource_name, "description", 0) or "unknown",
    version = GetResourceMetadata(core.resource_name, "version", 0) or "unknown",
    author = GetResourceMetadata(core.resource_name, "author", 0) or "Unknown"
}

--- @section Variables

core.vars = not core.is_server and {} or {}

--- @section Cache

core.cache = {}
core.locale = {}

--- @section Debugging

--- Gets the current time for debug logs
local function get_current_time()
    if core.is_server then return os.date("%Y-%m-%d %H:%M:%S") end
    if GetLocalTime then
        local y, m, d, h, min, s = GetLocalTime()
        return string.format("%04d-%02d-%02d %02d:%02d:%02d", y, m, d, h, min, s)
    end
    return "0000-00-00 00:00:00"
end

--- Logs a stylized print message
--- @param level string: Debug level (debug, info, success, warn, error, critical, dev)
--- @param message string: Message to print
function log(level, message)
    if not core.settings.debug_mode then return end

    local colors = { reset = "^7", debug = "^6", info = "^5", success = "^2", warn = "^3", error = "^8", critical = "^1", dev = "^9" }

    local clr = colors[level] or "^7"
    local time = get_current_time()

    print(("%s[%s] [%s] [%s]:^7 %s"):format(clr, time, core.resource_metadata.name, level:upper(), message))
end

core.log = log
_G.log = log

--- Translates a string to a locale key
--- @param key string: Locale key string
--- @param ... any: Arguments for string.format
--- @return string: Translated string
function translate(key, ...)
    local str = core.locale[key]
    if not str and type(key) == "string" then
        local v = core.locale
        for p in key:gmatch("[^%.]+") do v = v and v[p] end
        str = v
    end
    if type(str) == "string" then
        local ok, res = pcall(string.format, str, ...)
        return ok and res or str
    end
    return select("#", ...) > 0 and (tostring(key) .. " | " .. table.concat({...}, ", ")) or tostring(key)
end

core.translate = translate
_G.translate = translate

--- @section Safe Module Loader

--- Safe require function for loading internal modules
--- @param key string: Path key e.g. `src.server.modules.database`
function safe_require(key)
    if not key or type(key) ~= "string" then return nil end
    local rel_path = key:gsub("%.", "/")
    if not rel_path:match("%.lua$") then rel_path = rel_path .. ".lua" end
    local cache_key = ("%s:%s"):format(core.resource_name, rel_path)
    if core.cache[cache_key] then return core.cache[cache_key] end
    local file = LoadResourceFile(core.resource_name, rel_path)
    if not file then log("warn", translate("init.mod_missing", rel_path)) return nil end
    local module_env = setmetatable({}, { __index = _G })
    local chunk, err = load(file, ("@@%s/%s"):format(core.resource_name, rel_path), "t", module_env)
    if not chunk then log("error", translate("init.mod_compile", rel_path, err)) return nil end
    local ok, result = pcall(chunk)
    if not ok then log("error", translate("init.mod_runtime", rel_path, result)) return nil end
    if type(result) ~= "table" then log("error", translate("init.mod_return", rel_path, type(result))) return nil end
    core.cache[cache_key] = result
    return result
end

_G.require = safe_require

--- @section Settings

local settings = safe_require("custom.settings")

core.settings = {
    language = settings.language or "en",
    debug_mode = settings.debug or true,
    startup_message_enabled = settings.startup_message or false
}

--- @section Locales

local loaded_locale = require("locales." .. core.settings.language)
if loaded_locale then
    core.locale = loaded_locale
end

--- @section Core Data

if core.is_server then

    core.locations = require("custom.configs.locations")
    core.items = require("custom.configs.items")

end

--- @section Database Initialization

if core.is_server then
    
    local db = require("src.server.modules.database")
    
    --- Initialize database on resource start
    CreateThread(function()
        Wait(500)
        db.init()
    end)

end

--- @section Startup Message

if core.is_server and core.settings.startup_message_enabled then

    SetTimeout(350, function()
        print("^2")
        print("^2 ------------------------------------------------------------")
        print("^2 ^7Name:^2 " .. core.resource_metadata.name)
        print("^2 ^7Description:^2 " .. core.resource_metadata.description)
        print("^2 ^7Author:^2 " .. core.resource_metadata.author)
        print("^2 ^7Version:^2 " .. core.resource_metadata.version)
        print("^2 ^7Environment:^2 Server")
        print("^2 ^7Language:^2 " .. core.settings.language)
        print("^2 ------------------------------------------------------------")
        print("^2 ^7Settings:")
        for key, value in pairs(core.settings) do
            local val = tostring(value)
            local color = (val == "false" or val == "0") and "^1" or "^2"
            print("^7  • " .. key .. ": " .. color .. val)
        end
        print("^2 ------------------------------------------------------------")
    end)

end

--- @section Namespace Protection

SetTimeout(150, function()
    setmetatable(core, {
        __newindex = function(_, key)
            error(translate("init.ns_blocked", key), 2)
        end
    })
    
    log("success", translate("init.ns_ready", core.resource_metadata.name))
end)