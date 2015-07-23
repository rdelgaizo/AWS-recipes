module extra
  module User
    @@allocated_uids = []
    def create_weddingwire_ng_group
      Chef::Log.info("Something something")
      group 'weddingwire-ng' do
        action :create
        gid '3001'
        append true
      end
    end
    def add_user_to_default_groups(params)
      Chef::Log.info("Something something2")
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

class Chef::Recipe::groups
  @@allocated_uids = []
  def create_weddingwire_ng_group
    Chef::Log.info("Something something")
    group 'weddingwire-ng' do
      action :create
      gid '3001'
      append true
    end
  end
  def add_user_to_default_groups(params)
    Chef::Log.info("Something something2")
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
  
  

class Chef::Recipe
  include OpsWorks::User
end
class Chef::Resource::User
  include OpsWorks::User
end
