
require 'json'

default['x2go']['tce']['basedir'] = '/srv/x2gothinclient'

## settings for the sessions
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

## Settings for calling x2goclient inside the TCE
default['x2go']['tce']['config']['sessionedit'] = 'true'

## screens to use with xinerama/xrandr for different mac-addresses
# Screens are listet left-to-right
default['x2go']['tce']['config']['xinerama'] = {
  #"00:30:05:bc:3d:dd" => ['--output VGA1 --rotate left', '--output DVI1 --rotate right', '--output VGA1 --left-of DVI1']
  "00:30:05:bc:3d:dd" => ['--output VGA1 --left-of DVI1']
}
## encrypted version of the root-password to use
default['x2go']['tce']['rootpassword'] = nil

## extra packages to install inside the TCE
default['x2go']['tce']['extra_packages'] = []

