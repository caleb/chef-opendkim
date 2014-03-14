include_recipe 'build-essential::default'

case node[:platform_family]
when 'debian'
  package 'libmilter-dev'
when 'rhel', 'fedora'
  package 'openssl-devel'
  package 'sendmail-devel'
when 'freebsd'
end

version = node[:opendkim][:source][:version]
url = node[:opendkim][:source][:url]
checksum  = node[:opendkim][:source][:checksum]
configure_options = node[:opendkim][:source][:configure_options]

remote_file "#{Chef::Config[:file_cache_path]}/opendkim-#{version}.tar.gz" do
  source "#{url}/opendkim-#{version}.tar.gz"
  checksum checksum
  mode '0644'
  not_if 'which opendkim'
end

script 'build opendkim' do
  interpreter 'sh'
  cwd Chef::Config[:file_cache_path]
  code <<-EOF
    tar -zxvf opendkim-#{version}.tar.gz
    (cd opendkim-#{version} && ./configure #{configure_options})
    (cd opendkim-#{version} && make && make install)
  EOF
  not_if 'which opendkim'
end

group node[:opendkim][:group] do
  action :create
end

user node[:opendkim][:user] do
  shell '/sbin/nologin'
  supports :manage_home => true
  gid node[:opendkim][:group]

  action :create
end

case node[:platform_family]
when 'debian'
  template "/etc/init.d/#{node[:opendkim][:service_name]}" do
    source 'opendkim.erb'
    user 'root'
    group 'root'
    mode '755'
  end
when 'rhel', 'fedora'
  script 'copy init.d script' do
    interpreter 'sh'
    cwd ::File.join(Chef::Config[:file_cache_path], "opendkim-#{version}")

    code <<-EOB
      cp contrib/init/redhat/opendkim /etc/init.d/#{node[:opendkim][:service_name]}
      chmod 755 /etc/init.d/#{node[:opendkim][:service_name]}
    EOB

    action :run
  end
when 'freebsd'
end
