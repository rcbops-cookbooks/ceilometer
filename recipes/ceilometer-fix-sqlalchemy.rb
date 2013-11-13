platform_options = node["ceilometer"]["platform"]

versions = {
  "2013.2-1.el6" =>
  ["/usr/lib/python2.6/site-packages/ceilometer/storage/impl_sqlalchemy.py",
   "/usr/lib/python2.6/site-packages/ceilometer/storage/sqlalchemy/models.py",
   "/usr/lib/python2.6/site-packages/ceilometer/utils.py",
   "/usr/lib/python2.6/site-packages/ceilometer/storage/sqlalchemy/migrate_repo/versions/020_add_metadata_tables.py"],
  "2013.2-0ubuntu1~cloud0" =>
  ["/usr/lib/python2.7/dist-packages/ceilometer/storage/impl_sqlalchemy.py",
   "/usr/lib/python2.7/dist-packages/ceilometer/storage/sqlalchemy/models.py",
   "/usr/lib/python2.7/dist-packages/ceilometer/utils.py",
   "/usr/lib/python2.7/dist-packages/ceilometer/storage/sqlalchemy/migrate_repo/versions/020_add_metadata_tables.py"
  ]}

versions.each do |version, files|
  files.each do |file|
    name = ::File.basename(file)
    template "#{version} #{name}" do
      source "patches/#{name}.erb"
      path file
      owner "root"
      group "root"
      mode "0644"
      only_if {
        ::Chef::Recipe::Patch.check_package_version("python-ceilometer", version, node)
      }
      notifies :restart, "service[#{platform_options["api_service"]}]", :delayed
    end
    if name == "020_add_metadata_tables.py" then
      execute "update ceilometer db (migration)" do
        user "ceilometer"
        group "ceilometer"
        command "ceilometer-dbsync"
        action :nothing
        subscribes :run, "template[#{version} #{name}]", :immediately
      end 
    end
  end
end
