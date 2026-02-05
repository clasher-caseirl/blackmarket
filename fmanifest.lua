--[[
   █████████    █████████    █████████  ██████████
  ███▒▒▒▒▒███  ███▒▒▒▒▒███  ███▒▒▒▒▒███▒▒███▒▒▒▒▒█
 ███     ▒▒▒  ▒███    ▒███ ▒███    ▒▒▒  ▒███  █ ▒ 
▒███          ▒███████████ ▒▒█████████  ▒██████   
▒███          ▒███▒▒▒▒▒███  ▒▒▒▒▒▒▒▒███ ▒███▒▒█   
▒▒███     ███ ▒███    ▒███  ███    ▒███ ▒███ ▒   █
 ▒▒█████████  █████   █████▒▒█████████  ██████████
  ▒▒▒▒▒▒▒▒▒  ▒▒▒▒▒   ▒▒▒▒▒  ▒▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒▒▒                                                                              
]]

fx_version "cerulean"
games { "gta5" }

--- Metadata
name "Blackmarket"
version "0.1.0"
description "A blackmarket script built for QBCore Community Clash Event #1"
author "Case"
lua54 "yes"

--- UI
ui_page "ui/index.html"
nui_callback_strict_mode "true"
files { "**" }

--- OxMySql
server_script "@oxmysql/lib/MySQL.lua"

--- Core
shared_scripts {
    "locales/*.lua",
    "lib/*.lua",
    "init.lua",
    "src/shared/*.lua"
}
client_scripts {
    "src/client/*.lua"
}
server_scripts {
    "src/server/*.lua"
}

--- Custom
server_scripts {
    "custom/configs/*.lua"
}
shared_scripts {
    "custom/hooks.lua"
}

--- Escrow
escrow_ignore {
    "**"
}