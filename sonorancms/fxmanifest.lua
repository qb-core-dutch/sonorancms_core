fx_version 'cerulean'
games {'gta5'}

author 'Sonoran Software Systems'
real_name 'Sonoran CMS FiveM Integration'
description 'Sonoran CMS to FiveM translation layer'
version '1.2.0'
lua54 'yes'

server_scripts {'server/*.lua', 'config.lua', 'server/util/unzip.js', 'server/util/http.js', 'server/util/sonoran.js'}

ui_page 'nui/index.html'
dependency '/assetpacks'