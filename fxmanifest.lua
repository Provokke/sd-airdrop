fx_version 'cerulean'
game 'gta5'

author 'SD Scripts'
description 'Advanced Airdrop System with LB-Phone Integration'
version '2.1.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/cl_main.lua'
}

server_scripts {
    'server/sv_main.lua'
}

dependencies {
    'qb-core',
    'qb-target',
    'qb-polyzone',
    'lb-phone'
}

lua54 'yes'