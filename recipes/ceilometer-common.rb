#
# Cookbook Name:: ceilometer
# Recipe:: ceilometer-common
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

platform_options = node["ceilometer"]["platform"]

ceilometer = get_settings_by_recipe("ceilometer\:\:ceilometer-setup", "ceilometer")
ks_service_endpoint = get_access_endpoint("keystone-api", "keystone", "service-api")
ks_admin_endpoint = get_access_endpoint("keystone-api", "keystone", "admin-api")

mysql_connect_ip = get_access_endpoint("mysql-master", "mysql", "db")["host"]
rabbit_info = get_access_endpoint("rabbitmq-server", "rabbitmq", "queue")

platform_options["supporting_packages"].each do |pkg|
  package pkg do
    action node["osops"]["do_package_upgrades"] == true ? :upgrade : :install
    options platform_options["package_overrides"]
  end
end

# all ceilometers, server or client can share the same conf file

directory "/etc/ceilometer" do
  action :create
  owner "ceilometer"
  group "ceilometer"
  mode "0770"
end

# signing dir is here, even for clients
directory "/var/lib/ceilometer" do
  action :create
  owner "ceilometer"
  group "ceilometer"
  mode "770"
end

template "/etc/ceilometer/ceilometer.conf" do
  source "ceilometer.conf.erb"
  owner "ceilometer"
  group "ceilometer"
  mode "0660"
  variables(
    "metering_secret" => ceilometer["metering_secret"],
    "mysql_user" => ceilometer["db"]["username"],
    "mysql_password" => ceilometer["db"]["password"],
    "mysql_host" => mysql_connect_ip,
    "mysql_db" => ceilometer["db"]["name"],
    "ceilometer_admin" => ceilometer["service_user"],
    "ceilometer_password" => ceilometer["service_pass"],
    "ceilometer_tenant" => ceilometer["service_tenant_name"],
    "keystone_auth_url" => ks_service_endpoint["uri"],
    "keystone_service_protocol" => ks_service_endpoint["scheme"],
    "keystone_service_port" => ks_service_endpoint["port"],
    "keystone_service_host" => ks_service_endpoint["host"],
    "keystone_auth_protocol" => ks_admin_endpoint["scheme"],
    "keystone_auth_port" => ks_admin_endpoint["port"],
    "keystone_auth_host" => ks_admin_endpoint["host"]
  )
end
