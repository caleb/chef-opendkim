default[:opendkim][:install_method] = case node[:platform_family]
                                      when 'debian'
                                        'package'
                                      when 'rhel', 'fedora'
                                        'source'
                                      when 'freebsd'
                                        'package'
                                      end

default[:opendkim][:packages] = case node[:platform_family]
                                when 'debian'
                                  ['opendkim', 'opendkim-tools']
                                when 'rhel', 'fedora'
                                  ['opendkim']
                                when 'freebsd'
                                  ['opendkim']
                                end

default[:opendkim][:source][:version] = '2.6.8'
default[:opendkim][:source][:url] = "http://downloads.sourceforge.net/project/opendkim/opendkim-#{default[:opendkim][:source][:version]}.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fopendkim%2Ffiles%2F&ts=1390452355&use_mirror=softlayer-ams"
default[:opendkim][:source][:configure_options] = '--enable-oversign --sysconfdir=/etc --prefix=/usr/local --localstatedir=/var'
default[:opendkim][:source][:checksum] = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'

config_dir = case node[:platform_family]
when 'debian'
  '/etc/opendkim'
when 'rhel', 'fedora'
  '/etc/opendkim'
when 'freebsd'
  '/usr/local/etc/opendkim'
end

default[:opendkim][:config_file] = case node[:platform_family]
                                   when 'debian'
                                     '/etc/opendkim.conf'
                                   when 'rhel', 'fedora'
                                     '/etc/opendkim.conf'
                                   when 'freebsd'
                                     '/usr/local/etc/opendkim.conf'
                                   end

case node[:platform_family]
when 'debian'
  default[:opendkim][:user] = 'opendkim'
  default[:opendkim][:group] = 'opendkim'
when 'rhel', 'fedora'
  default[:opendkim][:user] = 'opendkim'
  default[:opendkim][:group] = 'opendkim'
when 'freebsd'
  default[:opendkim][:user] = 'opendkim'
  default[:opendkim][:group] = 'opendkim'
end

default[:opendkim][:config_dir] = config_dir
default[:opendkim][:key_dir] = ::File.join config_dir, 'keys'
default[:opendkim][:key_table] = ::File.join config_dir, 'keytable'
default[:opendkim][:signing_table] = ::File.join config_dir, 'signingtable'
default[:opendkim][:signing_table_dir] = ::File.join config_dir, 'signingtable.d'
default[:opendkim][:key_table_dir] = ::File.join config_dir, 'keytable.d'
default[:opendkim][:wildcard_signing_table] = false
default[:opendkim][:service_name] = 'opendkim'
default[:opendkim][:socket] = 'local:/var/run/opendkim/opendkim.sock'

default[:opendkim][:config] = {}

default[:opendkim][:config][:syslog] = true
default[:opendkim][:config][:umask] = '002'
default[:opendkim][:config][:oversign_headers] = 'From'
default[:opendkim][:config][:canonicalization] = nil # simple
default[:opendkim][:config][:mode] = nil # sv
default[:opendkim][:config][:sub_domains] = nil # no
default[:opendkim][:config][:a_d_s_p_action] = nil # continue
default[:opendkim][:config][:a_t_p_s_domains] = nil

