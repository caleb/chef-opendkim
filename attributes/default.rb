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

