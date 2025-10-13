_addon.name = 'Loop'
_addon.author = 'Cliff'
_addon.version = '0.1'
_addon.commands = {'loop'}

require('logger')
require('mylibs/res')
require('mylibs/utils')

PROFILES = {
	['limbo'] = {
		go_to = 'マウラ',
		next_action = 'ryu',
		cmd = 'ryu loop',
	},
	-- ['card'] = {
		-- next_action = 'ryu',
	-- },
	['ryu'] = {
		next_action = 'limbo',
		cmd = 'lm auto a',
	},
}

local RUNNING = nil

windower.register_event('addon command', function (...)
	local args	= T{...}:map(string.lower)
	local command = args[1]:lower()
	if RUNNING ~= nil then
		log('Busy...')
		return
	end
	RUNNING = PROFILES[command]
	if RUNNING then
		log('Loop profile accepted: '..command)
		if RUNNING.go_to then
			local zone = get_zone(RUNNING.go_to)
			if zone.id ~= windower.ffxi.get_info().zone then
				if isNpcNear('Home Point') then
					windower.send_command('sw hp '..zone.en..' '..(RUNNING.sw_num or ''))
					coroutine.sleep(20)
					windower.send_command('sw hp set')
				else
					log('No Home point nearby...')
					return
				end
			end
		end
		if RUNNING.next_action then
			windower.send_command('lua u '..command..';'..
								'wait 1;'..
								'lua r '..RUNNING.next_action..';'..
								'wait 1;'..
								RUNNING.cmd)
		end
		RUNNING = nil
	end
end)

windower.register_event('unload', function()
end)

windower.register_event('load', function()
    log('===========loaded===========')
end)