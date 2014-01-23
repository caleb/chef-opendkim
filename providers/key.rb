action :create do
  name = new_resource.name
  selector = new_resource.selector
  domain = new_resource.domain
  signatures = if new_resource.signatures.nil?
                 [domain]
               else
                 Array(new_resource.signatures)
               end

  bits = new_resource.bits

  private_key = new_resource.private_key

  private_key_file = "#{node[:opendkim][:key_dir]}/#{name}.private"

  # generate a new key if one isn't provided and an existing key isn't found
  if private_key
    file private_key_file do
      user node[:opendkim][:user]
      group node[:opendkim][:group]
      mode '0600'
      content private_key

      action :create
    end
  elsif ! ::File.exist?(private_key_file)
    # generate a new key
    bash 'create dkim private key' do
      cwd node[:opendkim][:key_dir]
      user node[:opendkim][:user]
      code <<-EOB
        opendkim-genkey -a -b #{bits} -s "#{selector}" -d "#{domain}"
      EOB

      action :run
    end
  end

  # create the key table entry
  template "#{node[:opendkim][:key_table_dir]}/#{name}" do
    source "key_table.erb"
    user node[:opendkim][:user]
    group node[:opendkim][:group]
    cookbook 'opendkim'
    mode '0600'

    variables :name => name,
              :domain => domain,
              :selector => selector,
              :key_file => private_key_file

    action :create
  end

  # create the signing entry
  template "#{node[:opendkim][:signing_table_dir]}/#{name}" do
    source "signing_table.erb"
    user node[:opendkim][:user]
    group node[:opendkim][:group]
    cookbook 'opendkim'
    mode '0600'

    variables :name => name,
              :signatures => signatures

    action :create
  end

  # concatenate the key table entries
  bash 'concatenate key table entries' do
    user node[:opendkim][:user]
    cwd node[:opendkim][:key_table_dir]
    code <<-EOB
      cat * > #{node[:opendkim][:key_table]}
    EOB
    action :run
  end

  # concatenate the signing table entries
  bash 'concatenate signing table entries' do
    user node[:opendkim][:user]
    cwd node[:opendkim][:signing_table_dir]
    code <<-EOB
      cat * > #{node[:opendkim][:signing_table]}
    EOB
    action :run
  end

  service node[:opendkim][:service_name] do
    action :restart
  end
end

action :delete do

end
