fx_version "cerulean"
lua54 'yes'
game "gta5"

author 'レズナ（開発元：DemiAutomatic）'
version '1.0.0'
description 'demi_lootboxをQboxで使用するために改造したものです。演出に変更は加えていません。'

ui_page 'web/build/index.html'

shared_scripts {
  '@ox_lib/init.lua',
  'init.lua'
}

client_script "client/**/*"

server_scripts {
  "server/server.lua",
  "server/data.lua",
}

files {
  'web/build/index.html',
  'web/build/**/*',
  'web/src/assets/roulette.mp3',
}