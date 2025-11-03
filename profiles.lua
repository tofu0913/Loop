
return {
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
	['ryu'] = {
		['merit'] = {
			next_action = 'ryu',
			cmd = 'ryu loop',
		},
		['ryu'] = {
			next_action = 'merit',
			cmd = 'mrt go',
		},
	},
}
