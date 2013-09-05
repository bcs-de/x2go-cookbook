
require 'json'

default['x2go']['tce']['basedir'] = '/srv/x2gothinclient'

default['x2go']['tce']['sessions'] = JSON.parse('''[{
	"name": "ltsp02",
	"command": "KDE",
	"host": "ltsp02.bcs.bcs",
	"autostart": "true",
	"fullscreen": "true"
	},{
	"name": "ts64",
	"command": "RDP",
	"host": "ts64-2.bcs.bcs",
	"fullscreen": "true"
	}]''')

default['x2go']['tce']['config']['sessionedit'] = 'true'
default['x2go']['tce']['rootpassword'] = nil

default['x2go']['tce']['extra_packages'] = []
