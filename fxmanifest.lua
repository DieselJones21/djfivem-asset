fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'dj_nocturne'
author 'DJ FiveM'
description 'Nocturne — paid Discord-synced ERP menu with a custom NUI'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/assets/*.svg'
}

shared_scripts {
    'config.lua',
    'locales/en.lua'
}

client_scripts {
    'client/utils.lua',
    'client/animations.lua',
    'client/nui.lua',
    'client/main.lua'
}

server_scripts {
    'server/discord.lua',
    'server/access.lua',
    'server/main.lua'
}

escrow_ignore {
    'config.lua',
    'locales/*.lua',
    'html/*.css',
    'html/*.js',
    'html/*.html',
    'html/assets/*.svg'
}
