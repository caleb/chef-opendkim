include_recipe 'build-essential::default'

case node[:platform_family]
when 'debian'
when 'rhel', 'fedora'
  package 'openssl-devel'
  package 'sendmail-devel'
when 'freebsd'
end

version = node['opendkim']['version'] || '2.6.8'
url = "http://downloads.sourceforge.net/project/opendkim/opendkim-#{version}.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fopendkim%2Ffiles%2F&ts=1390452355&use_mirror=softlayer-ams"
checksum  = nil
configure_options = '--enable-oversign --sysconfdir=/etc --prefix=/usr/local --localstatedir=/var'

remote_file "#{Chef::Config[:file_cache_path]}/opendkim-#{version}.tar.gz" do
  source "#{url}/opendkim-#{version}.tar.gz"
  checksum checksum if checksum
  mode '0644'
  not_if 'which opendkim'
end

bash 'build opendkim' do
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

bash 'copy init.d script' do
  cwd ::File.join(Chef::Config[:file_cache_path], "opendkim-#{version}")
  code <<-EOB
    cp contrib/init/redhat/opendkim /etc/init.d/#{node[:opendkim][:service_name]}
    chmod 755 /etc/init.d/#{node[:opendkim][:service_name]}
  EOB
  action :run
end

