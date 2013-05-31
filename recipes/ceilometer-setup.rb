#
# Cookbook Name:: ceilometer
# Recipe:: ceilometer-setup
#
# Copyright 2013, Rackspace US, Inc.
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
# this does setup, registers the service with keystone
# and lays down the central agent (which can only exist once currently)

# die early if setup has already been run on another node
if get_role_count('ceilometer-setup', false) > 0
  Chef::Application.fatal! "You can only have one"\
    " node with the ceilometer-setup role"
end

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

platform_options = node["ceilometer"]["platform"]

if node["developer_mode"]
  node.set_unless["ceilometer"]["db"]["password"] = "ceilometer"
else
  node.set_unless["ceilometer"]["db"]["password"] = secure_password
end

# set a secure ceilometer metering secret
node.set_unless["ceilometer"]["metering_secret"] = secure_password

# set a secure ceilometer service password
node.set_unless["ceilometer"]["service_pass"] = secure_password

include_recipe "mysql::client"
include_recipe "mysql::ruby"

ks_admin_endpoint = get_access_endpoint("keystone-api", "keystone", "admin-api")

keystone = get_settings_by_role("keystone-setup", "keystone")
keystone_admin_user = keystone["admin_user"]
keystone_admin_password = keystone["users"][keystone_admin_user]["password"]
keystone_admin_tenant = keystone["users"][keystone_admin_user]["default_tenant"]

mysql_info = create_db_and_user(
  "mysql",
  node["ceilometer"]["db"]["name"],
  node["ceilometer"]["db"]["username"],
  node["ceilometer"]["db"]["password"]
)

include_recipe "ceilometer::ceilometer-common"

execute "ceilometer db sync" do
  command "ceilometer-dbsync"
  user "ceilometer"
  group "ceilometer"
  action :nothing
  subscribes :run, "template[/etc/ceilometer/ceilometer.conf]", :immediately
end

# register the service
keystone_service "Register Ceilometer Service" do
  auth_host ks_admin_endpoint["host"]
  auth_port ks_admin_endpoint["port"]
  auth_protocol ks_admin_endpoint["scheme"]
  api_ver ks_admin_endpoint["path"]
  auth_token keystone["admin_token"]
  service_name "ceilometer"
  service_type "metering"
  service_description "Ceilometer Service"
  action :create
end

# register the service user
keystone_user "Register Service User" do
  auth_host ks_admin_endpoint["host"]
  auth_port ks_admin_endpoint["port"]
  auth_protocol ks_admin_endpoint["scheme"]
  api_ver ks_admin_endpoint["path"]
  auth_token keystone["admin_token"]
  tenant_name node["ceilometer"]["service_tenant_name"]
  user_name node["ceilometer"]["service_user"]
  user_pass node["ceilometer"]["service_pass"]
  user_enabled true
  action :create
end

# grant the role
keystone_role "Grant Ceilometer service role" do
  auth_host ks_admin_endpoint["host"]
  auth_port ks_admin_endpoint["port"]
  auth_protocol ks_admin_endpoint["scheme"]
  api_ver ks_admin_endpoint["path"]
  auth_token keystone["admin_token"]
  tenant_name node["ceilometer"]["service_tenant_name"]
  user_name node["ceilometer"]["service_user"]
  role_name node["ceilometer"]["service_role"]
  action :grant
end
