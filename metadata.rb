name             'opendkim'
maintainer       'Caleb Land'
maintainer_email 'caleb@land.fm'
license          'All rights reserved'
description      'Installs/Configures opendkim'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'openssl'
depends 'build-essential'
depends 'freebsd'
depends 'apt'
depends 'yum'
