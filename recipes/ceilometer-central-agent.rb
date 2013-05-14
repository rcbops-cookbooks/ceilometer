#
# Cookbook Name:: ceilometer
# Recipe:: ceilometer-central-agent
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

# TODO(mancdaz)only a single central-agent can be running at any one time so we need to
# add in the keepalived stuff here to sit an ip on top of multiple instances

platform_options["central_agent_package_list"].each do |pkg|
  package pkg do
    action node["osops"]["do_package_upgrades"] == true ? :upgrade : :install
    options platform_options["package_overrides"]
  end
end

include_recipe "ceilometer::ceilometer-common"

execute "ceilometer db sync" do
  command "ceilometer-dbsync"
  user "ceilometer"
  group "ceilometer"
  action :run
end

platform_options["central_agent_service_list"].each do |svc|
  service svc do
    supports :status => true, :restart => true
    action [ :enable, :start ]
    subscribes :restart, "template[/etc/ceilometer/ceilometer.conf]", :delayed
  end
end
