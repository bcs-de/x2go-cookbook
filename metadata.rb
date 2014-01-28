name             'x2go'
maintainer       'bcs kommunikationsloesungen'
maintainer_email 'Arnold Krille <a.krille@b-c-s.de>'
license          'Apache License, Version 2.0'
description      'Installs x2go on servers and for thinclients'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'

supports         'debian', '>= 7.0'

depends          'nfs'
depends          'pxe', '>= 2.0.2'
depends          'line'
