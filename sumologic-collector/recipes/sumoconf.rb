#
# Author:: Ben Newton (<ben@sumologic.com>)
# Cookbook Name:: sumologic-collector
# Recipe:: Configure sumo.conf for unattended installs and activation
#
# Copyright 2013, Sumo Logic
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# The template sumo.conf file includes variables to customize it (username, password, etc.)
#
# Sumo Logic Help Links
# https://service.sumologic.com/ui/help/Default.htm#Unattended_Installation_from_a_Linux_Script_using_the_Collector_Management_API.htm
# https://service.sumologic.com/ui/help/Default.htm#Deploying_a_Windows_Collector_Automatically.htm
# https://service.sumologic.com/ui/help/Default.htm#Using_sumo.conf.htm
# https://service.sumologic.com/ui/help/Default.htm#JSON_Source_Configuration.htm


#Use the credentials variable to keep the proper credentials - regardless of source
credentials = {}


if node[:sumologic][:credentials]
  creds = node[:sumologic][:credentials]
  Chef::Log.info "Loaded credentials"

  if creds[:secret_file]
    Chef::Log.info "Creds secret_file existed"
    secret = Chef::EncryptedDataBagItem.load_secret(creds[:secret_file]) 
    bag = Chef::EncryptedDataBagItem.load(creds[:bag_name], creds[:item_name], secret)
    Chef::Log.info "secret is #{secret.inspect} and bag is #{bag}"
  else
    bag = data_bag_item(creds[:bag_name], creds[:item_name])
    Chef::Log.info "Creds secret_file didn't exist bag is now #{bag.inspect}"
  end
   
  [:accessID,:accessKey,:email,:password].each do |sym|
    Chef::Log.info "going through each thing with sym = #{sym}"
    credentials[sym] = bag[sym.to_s] # Chef::DataBagItem 10.28 doesn't work with symbols
  end
    
else
  [:accessID,:accessKey,:email,:password].each do |sym|
    credentials[sym]  = node[:sumologic][sym] 
  end 
end

Chef::Log.info "Checking if default was overridden"
#Check to see if the default sumo.conf was overridden
conf_source = node['sumologic']['conf_template'] || 'sumo.conf.erb'

# Create the conf file's parent directory (generally for Windows support)
directory ::File.dirname(node['sumologic']['sumo_conf_path']) do
  recursive true
end

Chef::Log.info "Checked/created conf file"

template node['sumologic']['sumo_conf_path'] do
  Chef::Log.info "Setting cookbook node"
  cookbook node['sumologic']['conf_config_cookbook']
  Chef::Log.info "Set cookbook node"
  source conf_source

  unless platform?('windows')
    owner 'root'
    group 'root'
    mode 0600
  end
  
  # this may look strange, but one pair will be nil, so it all works out
  variables({
    :accessID  => credentials[:accessID],
    :accessKey => credentials[:accessKey],
    :email     => credentials[:email],
    :password  => credentials[:password],
  })
  Chef::Log.info "Finished in sumoconf"
end