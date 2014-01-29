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

  private_key_file = "#{node[:opendkim][:key_dir]}/#{selector}_#{domain}.private"
  public_key_file = "#{node[:opendkim][:key_dir]}/#{selector}_#{domain}.txt"

  # if a private key is provided, use it
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
    script 'create dkim private key' do
      interpreter 'sh'
      cwd Chef::Config[:file_cache_path]
      code <<-EOB
        opendkim-genkey -a -b #{bits} -s "#{selector}" -d "#{domain}"
      EOB

      action :run
    end

    # move the key files into their proper place
    script 'move key files' do
      interpreter 'sh'
      cwd Chef::Config[:file_cache_path]
      code <<-EOB
        mv #{selector}.private #{private_key_file}
        mv #{selector}.txt     #{public_key_file}
      EOB

      notifies :create, "ruby_block[save generated public key for #{name}]"
      action :run
    end

    # change the owner and group of the key files
    file private_key_file do
      user node[:opendkim][:user]
      group node[:opendkim][:group]
      mode '0600'
    end
    file public_key_file do
      user node[:opendkim][:user]
      group node[:opendkim][:group]
      mode '0644'
    end
  end

  # if we don't have a public key try to fetch it from dns
  ruby_block "fetch public key for #{name}" do
    action :create

    block do
      dig = `dig +short -t ns #{domain}`
      ns = dig.split(/\s+/)

      if ns.size > 0
        dig = `dig +short -t txt #{selector}._domainkey.#{domain} #{ns.first}`
        unless dig.strip.empty?
          ::File.open public_key_file, 'w' do |f|
            f.write dig
          end

          ::File.chmod 0600, public_key_file

          require 'fileutils'

          ::FileUtils.chown node[:opendkim][:user],
                            node[:opendkim][:group],
                            public_key_file
        end
      end
    end

    notifies :create, "ruby_block[save generated public key for #{name}]"
    not_if { ::File.exist? public_key_file }
  end

  # if we're not running in chef-solo, save the public key to the node
  ruby_block "save generated public key for #{name}" do
    action :nothing
    not_if { Chef::Config[:solo] || ! ::File.exist?(public_key_file) }

    block do
      node[:opendkim][:generated_public_keys] ||= {}
      node[:opendkim][:generated_public_keys][name] = File.read public_key_file
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

    notifies :run, 'script[concatenate key table entries]'
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

    notifies :run, 'script[concatenate signing table entries]'
    action :create
  end

  # concatenate the key table entries
  script 'concatenate key table entries' do
    interpreter 'sh'
    user node[:opendkim][:user]
    cwd node[:opendkim][:key_table_dir]
    code <<-EOB
      cat * > #{node[:opendkim][:key_table]}
    EOB

    notifies :restart, "service[#{node[:opendkim][:service_name]}]"
    action :nothing
  end

  # concatenate the signing table entries
  script 'concatenate signing table entries' do
    interpreter 'sh'
    user node[:opendkim][:user]
    cwd node[:opendkim][:signing_table_dir]
    code <<-EOB
      cat * > #{node[:opendkim][:signing_table]}
    EOB

    notifies :restart, "service[#{node[:opendkim][:service_name]}]"
    action :nothing
  end
end

action :delete do

end
