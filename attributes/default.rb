default[:opendkim][:install_method] = case node[:platform_family]
                                      when 'debian'
                                        'package'
                                      when 'rhel'
                                        'source'
                                      when 'fedora'
                                        'package'
                                      when 'freebsd'
                                        'package'
                                      end

default[:opendkim][:packages] = case node[:platform_family]
                                when 'debian'
                                  [ 'opendkim', 'opendkim-tools' ]
                                when 'rhel',
                                  []
                                when 'fedora'
                                  [ 'opendkim', 'bind-utils' ]
                                when 'freebsd'
                                  [ 'opendkim' ]
                                end

default[:opendkim][:source][:version] = '2.6.8'
default[:opendkim][:source][:url] = "http://downloads.sourceforge.net/project/opendkim/opendkim-#{default[:opendkim][:source][:version]}.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fopendkim%2Ffiles%2F&ts=1390452355&use_mirror=softlayer-ams"
default[:opendkim][:source][:configure_options] = '--enable-oversign --sysconfdir=/etc --prefix=/usr/local --localstatedir=/var'
default[:opendkim][:source][:checksum] = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'

config_dir = case node[:platform_family]
when 'debian'
  '/etc/opendkim'
when 'rhel'
  '/etc/opendkim'
when 'fedora'
  '/etc/opendkim'
when 'freebsd'
  '/usr/local/etc/opendkim'
end

default[:opendkim][:config_file] = case node[:platform_family]
                                   when 'debian'
                                     '/etc/opendkim.conf'
                                   when 'rhel'
                                     '/etc/opendkim.conf'
                                   when 'fedora'
                                     '/etc/opendkim.conf'
                                   when 'freebsd'
                                     '/usr/local/etc/mail/opendkim.conf'
                                   end

case node[:platform_family]
when 'debian'
  default[:opendkim][:user] = 'opendkim'
  default[:opendkim][:group] = 'opendkim'
when 'rhel'
  default[:opendkim][:user] = 'opendkim'
  default[:opendkim][:group] = 'opendkim'
when 'fedora'
  default[:opendkim][:user] = 'opendkim'
  default[:opendkim][:group] = 'opendkim'
when 'freebsd'
  default[:opendkim][:user] = 'mailnull'
  default[:opendkim][:group] = 'mailnull'
end

default[:opendkim][:config_dir] = config_dir
default[:opendkim][:key_dir] = ::File.join config_dir, 'keys'
default[:opendkim][:key_table] = ::File.join config_dir, 'KeyTable'
default[:opendkim][:signing_table] = ::File.join config_dir, 'SigningTable'
default[:opendkim][:trusted_hosts_file] = ::File.join config_dir, 'TrustedHosts'
default[:opendkim][:signing_table_dir] = ::File.join config_dir, 'SigningTable.d'
default[:opendkim][:key_table_dir] = ::File.join config_dir, 'KeyTable.d'
default[:opendkim][:wildcard_signing_table] = false
default[:opendkim][:service_name] = value_for_platform_family ['debian', 'rhel', 'fedora'] => 'opendkim',
                                                              'freebsd' => 'milter-opendkim'

default[:opendkim][:socket] = 'local:/var/run/opendkim/opendkim.sock'
default[:opendkim][:trusted_hosts] = [ '127.0.0.1' ]

default[:opendkim][:config] = {}

default[:opendkim][:config][:syslog] = true
default[:opendkim][:config][:umask] = '002'
default[:opendkim][:config][:oversign_headers] = 'From'
default[:opendkim][:config][:canonicalization] = nil # simple
default[:opendkim][:config][:mode] = nil # sv
default[:opendkim][:config][:sub_domains] = nil # no
default[:opendkim][:config][:a_d_s_p_action] = nil # continue
default[:opendkim][:config][:a_t_p_s_domains] = nil

