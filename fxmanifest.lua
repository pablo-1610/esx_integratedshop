fx_version 'adamant'
games { 'gta5' };

client_scripts {
    "configuration.lua",
    "client/main.lua",
    "client/rage/RMenu.lua",
    "client/rage/menu/RageUI.lua",
    "client/rage/menu/Menu.lua",
    "client/rage/menu/MenuController.lua",
    "client/rage/components/*.lua",
    "client/rage/menu/elements/*.lua",
    "client/rage/menu/items/*.lua",
    "client/rage/menu/panels/*.lua",
    "client/rage/menu/windows/*.lua"
}

server_scripts {
    '@fox/server/mysql/MySQL.lua',
    'configuration.lua',
    'server/main.lua'
}