#
# Cookbook Name:: opendkim
# Recipe:: default
#
# Copyright (C) 2014 Caleb Land
# 
# All rights reserved - Do Not Redistribute
#

include_recipe 'openssl::default'

include_recipe "opendkim::install_#{node[:opendkim][:install_method]}"

# create the config directory
directory node[:opendkim][:config_dir] do
  user node[:opendkim][:user]
  group node[:opendkim][:user]
  mode '0700'
  recursive true

  action :create
end

# create the keys directory
directory node[:opendkim][:key_dir] do
  user node[:opendkim][:user]
  group node[:opendkim][:user]
  mode '0700'
  recursive true

  action :create
end

# create the signature table directory
directory node[:opendkim][:key_table_dir] do
  user node[:opendkim][:user]
  group node[:opendkim][:user]
  mode '0700'
  recursive true

  action :create
end

# create the signature table directory
directory node[:opendkim][:signing_table_dir] do
  user node[:opendkim][:user]
  group node[:opendkim][:user]
  mode '0700'
  recursive true

  action :create
end

# create the socket directory if it doesn't exist
if node[:opendkim][:socket].start_with? 'local:'
  socket_dir = ::File.dirname node[:opendkim][:socket].gsub(/^local:/, '')
  directory socket_dir do
    user node[:opendkim][:user]
    group node[:opendkim][:group]
    mode '0755'
    recursive true

    action :create
  end
end

# create the config file

camelize = lambda do |key|
  ::Chef::Mixin::ConvertToClassName.convert_to_class_name key
end

config = {}
node[:opendkim][:config].each_pair do |key, value|
  unless value.nil?
    config[camelize[key]] = case value
                            when TrueClass
                              'yes'
                            when FalseClass
                              'no'
                            else
                              value
                            end
  end
end

config['KeyTable'] = "file:#{node[:opendkim][:key_table]}"
config['SigningTable'] = if node[:opendkim][:wildcard_signing_table]
                           "refile:#{node[:opendkim][:signing_table]}"
                         else
                           "file:#{node[:opendkim][:signing_table]}"
                         end
config['Socket'] = node[:opendkim][:socket]
config['UserID'] = "#{ node[:opendkim][:user] }:#{ node[:opendkim][:group] }"

template node[:opendkim][:config_file] do
  source 'opendkim.conf.erb'
  user node[:opendkim][:user]
  group node[:opendkim][:group]
  mode '644'

  variables settings: config

  notifies :restart, "service[#{node[:opendkim][:service_name]}]"
end

service node[:opendkim][:service_name] do
  supports restart: true, reload: true, status: true
  action [ :enable, :start ]
end
