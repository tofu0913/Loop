_addon.name = 'Loop'
_addon.author = 'Cliff'
_addon.version = '0.1'
_addon.commands = {'loop'}

require('logger')
require('mylibs/res')
require('mylibs/utils')

PROFILES = {
	['limbo-a'] = {
		['limbo'] = {
			go_to = 'マウラ',
			next_action = 'ryu',
			cmd = 'ryu loop',
		},
		['ryu'] = {
			next_action = 'limbo',
			cmd = 'lm auto a',
		},
	},
	['limbo-t'] = {
		['limbo'] = {
			go_to = 'マウラ',
			next_action = 'ryu',
			cmd = 'ryu loop',
		},
		['ryu'] = {
			next_action = 'limbo',
			cmd = 'lm auto t',
		},
	},
}

local RUNNING = nil


-- Settings
config = require('config')
default = {
	profile = 'limbo-a',
	text_setting = {
		pos = {
			x = 555,
			y = 514
		}
	},
}
settings = config.load(default)

-- Widget
local texts = require('texts')
local function setup_text(text)
    text:bg_alpha(255)
    text:bg_visible(true)
    text:font('ＭＳ ゴシック')
    text:size(11)
    text:color(255,255,255,255)
    text:stroke_alpha(200)
    text:stroke_color(20,20,20)
    text:stroke_width(2)
	text:show()
end
widget = texts.new("${msg}", default.text_setting)
setup_text(widget)

COUNTER = {}

function add_counter(key)
	if COUNTER[key] == nil then
		COUNTER[key] = 0
	end
	COUNTER[key] = COUNTER[key] + 1
end

function update_widget()
	local str = ''
	for key,value in pairs(COUNTER) do
		str = str..(key..': '..value..'\n')
	end
	widget.msg = str
end

windower.register_event('status change', function(new, old)
    if new == 2 then
		add_counter('dead')
		update_widget()
		coroutine.sleep(10)
		windower.send_command('wait 5;'..
							'setkey enter; wait 0.1; setkey enter up; wait 2;'..
							'setkey left; wait 0.1; setkey left up; wait 2;'..
							'setkey enter; wait 0.1; setkey enter up;')
    end
end)

windower.register_event('addon command', function (...)
	local args	= T{...}:map(string.lower)
	local command = args[1]:lower()
	if RUNNING ~= nil then
		log('Busy...')
		return
	end
	if command == 'set' and args[2] and PROFILES[args[2]:lower()] then
		local newcmd = args[2]:lower()
		windower.add_to_chat(2, 'Setting profile: '..newcmd)
		settings.profile = newcmd
		settings:save()
	elseif command == 'show' then
		windower.add_to_chat(2, 'Setting profile: '..settings.profile)
	else
		RUNNING = PROFILES[settings.profile][command]
		if RUNNING then
			log('Loop profile accepted: '..command)
			add_counter(command)
			update_widget()
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
	end
end)

windower.register_event('unload', function()
end)

windower.register_event('load', function()
    log('===========loaded===========')
	windower.add_to_chat(2, 'Setting profile: '..settings.profile)
end)