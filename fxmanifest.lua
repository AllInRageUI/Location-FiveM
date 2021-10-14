fx_version 'cerulean'
games { 'gta5' };

name 'RageUI';
description 'RageUI, and a project specially created to replace the NativeUILua-Reloaded library. This library allows to create menus similar to the one of Grand Theft Auto online.'

client_scripts {
    "src/RMenu.lua",
    "src/menu/RageUI.lua",
    "src/menu/Menu.lua",
    "src/menu/MenuController.lua",

    "src/components/*.lua",

    "src/menu/elements/*.lua",

    "src/menu/items/*.lua",

    "src/menu/panels/*.lua",

    "src/menu/windows/*.lua",

}

client_scripts {
    "ICI/*-c.lua",
    "ICI/*-sh.lua"
}
server_scripts {
    "ICI/*-s.lua",
    "ICI/*-sh.lua"
}