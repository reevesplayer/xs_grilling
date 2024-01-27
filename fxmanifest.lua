fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Cryptic @ X-Studios'
description 'X-Studios Grilling Script'
version '1.0.0'

data_file 'DLC_ITYP_REQUEST' 'stream/small_bbq.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/large_bbq.ytyp'


shared_scripts { '@ox_lib/init.lua', 'configuration/*.lua' }
client_scripts { 'bridge/**/client.lua', 'client/*.lua' }
server_scripts { 'bridge/**/server.lua', 'server/*.lua' }

dependencies { 'ox_lib' }

escrow_ignore {
    'configuration/*.lua',
    'client/cl_customize.lua',
    'target/client.lua',
    'bridge/esx/*.lua',
    'bridge/qb/*.lua',
    'bridge/target/*.lua',
}
