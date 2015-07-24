group 'opsworks'
group 'extra'

#added into create the new group we need
Chef::Log.warn("Creating groups")
create_weddingwire_ng_group
Chef::Log.error("This list of groups is #{node[:etc][:groups]}")

existing_ssh_users = load_existing_ssh_users
Chef::Log.info("SSH user node at start is #{node[:ssh_users]}")
Chef::Log.info("Existing user list is #{existing_ssh_users}")
existing_ssh_users.each do |id, name|
  Chef::Log.error("Checking #{id}  #{name}    #{node[:ssh_users][id]} ")
  unless node[:ssh_users][id]
    Chef::Log.info("Tearing down #{name} #{id}")
    teardown_user(name)
  end
end

#Basically what is happening is that the check for existing users is using the setup UID and not the new one that we want for the users at 4000+


node[:ssh_users].each_key do |id|
  if existing_ssh_users.has_key?(id)
    unless existing_ssh_users[id] == node[:ssh_users][id][:name]
      new_id = next_free_uid
      rename_user(existing_ssh_users[id], node[:ssh_users][id][:name])
      #added in to set the new users to the groups we want
      Chef::Log.warn("Adding user for exisiting SSH user ")
      add_user_to_default_groups(node[:ssh_users][id])
    end
    #set_public_key(node[:ssh_users][id])
  else
    new_id = next_free_uid
    Chef::Log.info("Setting up new user with id #{new_id}")
    Chef::Log.error("Checked out #{[id]} has #{node[:ssh_users][id]}")
    Chef::Log.info("SSH user node before change #{node[:ssh_users]}")
    node.set[:ssh_users][id][:uid] = id
    #node.set[:ssh_users][new_id] = node[:ssh_users][id]
    setup_user(node[:ssh_users][id])
    #added in to set the new users to the groups we want
    Chef::Log.warn("Copied node to #{node[:ssh_users][new_id]}")
    Chef::Log.error("New out #{[id]} has #{node[:ssh_users][id]}")
    Chef::Log.info("SSH user node now is #{node[:ssh_users]}")
    #Chef::Log.warn("Adding user for new SSH user #{new_id}   #{id} #{node[:ssh_users][new_id][:name]}")
    add_user_to_default_groups(node[:ssh_users][id])
    #set_public_key(node[:ssh_users][new_id])
  end
  set_public_key(node[:ssh_users][id])
end

Chef::Log.error("SSH user node after everything is #{node[:ssh_users]}")


system_sudoer = case node[:platform]
                when 'debian'
                  'admin'
                when 'ubuntu'
                  'ubuntu'
                when 'redhat','centos','fedora','amazon'
                   'ec2-user'
                end

template '/etc/sudoers' do
  backup false
  source 'sudoers.erb'
  owner 'root'
  group 'root'
  mode 0440
  variables :sudoers => node[:sudoers], :system_sudoer => system_sudoer
  only_if { infrastructure_class? 'ec2' }
end

template '/etc/sudoers.d/opsworks' do
  backup false
  source 'sudoers.d.erb'
  owner 'root'
  group 'root'
  mode 0440
  variables :sudoers => node[:sudoers], :system_sudoer => system_sudoer
  not_if { infrastructure_class? 'ec2' }
end
