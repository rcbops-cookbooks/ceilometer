template "/usr/lib/python2.7/dist-packages/ceilometer/storage/impl_sqlalchemy.py" do
  source "patches/impl_sqlalchemy.py.erb"
  owner "root"
  group "root"
  mode "0644"
  only_if {
    ::Chef::Recipe::Patch.check_package_version("python-ceilometer", "2013.2-0ubuntu1~cloud0", node)
  }
end

template "/usr/lib/python2.7/dist-packages/ceilometer/storage/sqlalchemy/migrate_repo/versions/020_add_metadata_tables.py" do
  source "patches/020_add_metadata_tables.py.erb"
  owner "root"
  group "root"
  mode "0644"
  only_if {
    ::Chef::Recipe::Patch.check_package_version("python-ceilometer", "2013.2-0ubuntu1~cloud0", node)
  }
end

template "/usr/lib/python2.7/dist-packages/ceilometer/storage/sqlalchemy/models.py" do
  source "patches/models.py.erb"
  owner "root"
  group "root"
  mode "0644"
  only_if {
    ::Chef::Recipe::Patch.check_package_version("python-ceilometer", "2013.2-0ubuntu1~cloud0", node)
  }
end

template "/usr/lib/python2.7/dist-packages/ceilometer/utils.py" do
  source "patches/utils.py.erb"
  owner "root"
  group "root"
  mode "0644"
  only_if {
    ::Chef::Recipe::Patch.check_package_version("python-ceilometer", "2013.2-0ubuntu1~cloud0", node)
  }
end
