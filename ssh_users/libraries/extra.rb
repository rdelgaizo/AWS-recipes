module Extra
  module User
    @@allocated_uids = []
    
    def create_weddingwire_ng_group
      group 'weddingwire-ng' do
        action :create
        gid '3001'
      end
      Chef::Log.warn("created weddingwire-ng group")
    end
    def add_user_to_default_groups(params)
      Chef::Log.error("Add user #{params[:name]} to groups")
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
