--[[ ================================================
    qb-scoreboard — Professional Events & Jobs UI
    Developed by: Nerd Developer
    Website: https://nerd-developer.com
    ================================================ --]]

fx_version 'cerulean'
game 'gta5'

name 'qb-scoreboard'
author 'REDMANE'
description 'QBCore Scoreboard — events & jobs UI'
version '3.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config/config.lua',
}

client_scripts {
    'client/client.lua',
}

server_scripts {
    'server/server.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js',
}

lua54 'yes'
