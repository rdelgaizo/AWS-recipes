module OpsWorks
  module User
    @@allocated_uids = []
    def create_weddingwire_ng_group
      group 'weddingwire-ng' do
        action :create
        gid '3001'
      end
    end
    def add_user_to_default_groups(params)
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
  include OpsWorks::User
end
class Chef::Resource::User
  include OpsWorks::User
end
