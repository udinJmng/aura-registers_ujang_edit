fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
author 'Aura Development'
description 'Free register system for jobs.'
version '1.0.0'

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua',
}

client_scripts {
  'client/main.lua',
}

server_scripts {
  'server/locale.lua',
  'server/main.lua',
}

ui_page 'web/build/index.html'

files {
  'locales/*.json',
  'web/build/index.html',
  'web/build/assets/*.css',
  'web/build/assets/*.js',
  'web/build/audio/*.mp3',
  'web/build/audio/*.wav',
}
