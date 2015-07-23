module Extra
  module User
    @@allocated_uids = []
    
    def load_existing_ssh_users2
      return {} unless node[:opsworks_gid]
      existing_ssh_users = {}
      (node[:passwd] || node[:etc][:passwd]).each do |username, entry|
        Chef::Log.warn("Checking #{username} with entry of #{entry}")
        if entry[:gid] == node[:opsworks_gid]
          Chef::Log.warn("Entry global id #{entry[:gid]} is equal to opsworks_gid #{node[:opsworks_gid]} with username #{username}")
          existing_ssh_users[entry[:uid].to_s] = username
        end
      end
      existing_ssh_users
    end
    
    def create_weddingwire_ng_group
      group 'weddingwire-ng' do
        action :create
        gid '3001'
      end
    end
    def add_user_to_default_groups(params)
      sleep(30)
      group "www-data" do
        action :modify
        members params[:name]
        append true
      end

      group 'weddingwire-ng' do
        action :modify
        members params[:name]
        append true
      end
    end
  end
end

class Chef::Recipe
  include Extra::User
end
class Chef::Resource::User
  include Extra::User
end
