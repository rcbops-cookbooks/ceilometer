
default["ceilometer"]["db"]["name"] = "ceilometer"
default["ceilometer"]["db"]["username"] = "ceilometer"

default["ceilometer"]["service_tenant_name"] = "service"
default["ceilometer"]["service_user"] = "ceilometer"
default["ceilometer"]["service_role"] = "admin"

default["ceilometer"]["services"]["api"]["scheme"] = "http"
default["ceilometer"]["services"]["api"]["network"] = "public"
default["ceilometer"]["services"]["api"]["port"] =  8777
default["ceilometer"]["services"]["api"]["path"] = ""
default["ceilometer"]["services"]["api"]["cert_file"] = "ceilometer.pem"
default["ceilometer"]["services"]["api"]["key_file"] = "ceilometer.key"
default["ceilometer"]["services"]["api"]["wsgi_file"] = "ceilometer-api"

default["ceilometer"]["services"]["internal-api"]["scheme"] = "http"
default["ceilometer"]["services"]["internal-api"]["network"] = "management"
default["ceilometer"]["services"]["internal-api"]["port"] =  8777
default["ceilometer"]["services"]["internal-api"]["path"] = ""

default["ceilometer"]["services"]["admin-api"]["scheme"] = "http"
default["ceilometer"]["services"]["admin-api"]["network"] = "management"
default["ceilometer"]["services"]["admin-api"]["port"] =  8777
default["ceilometer"]["services"]["admin-api"]["path"] = ""

default["ceilometer"]["services"]["central"]["scheme"] = "tcp"
default["ceilometer"]["services"]["central"]["network"] = "management"
default["ceilometer"]["services"]["central"]["port"] =  8777

# should there be syslog settings here?
default["ceilometer"]["syslog"]["use"] = true
default["ceilometer"]["syslog"]["facility"] = "LOG_LOCAL3"

default["ceilometer"]["logging"]["debug"] = "false"
default["ceilometer"]["logging"]["verbose"] = "true"

# metering secret should be secret and unguessable, to prevent
# spoofing metrics
# default["ceilometer"]["metering_secret"] = "ceilometer"

case platform_family
when "rhel"
  default["ceilometer"]["platform"] = {
    "supporting_packages" => ["openstack-ceilometer-common",
      "MySQL-python", "python-ceilometerclient"],
    "central_agent_package_list" => ["openstack-ceilometer-central"],
    "central_agent_service" => "openstack-ceilometer-central",
    "collector_package_list" => ["openstack-ceilometer-collector"],
    "collector_service" => "openstack-ceilometer-collector",
    "api_package_list" => ["openstack-ceilometer-api"],
    "api_service" => "openstack-ceilometer-api",
    "compute_package_list" => ["openstack-ceilometer-compute"],
    "compute_service" => "openstack-ceilometer-compute",
    "service_bin" => "/sbin/service",
    "package_overrides" => ""
  }
  default["ceilometer"]["ssl"]["dir"] = "/etc/pki/tls"
when "debian"
  default["ceilometer"]["platform"] = {
    "supporting_packages" => ["ceilometer-common", "python-mysqldb",
      "python-ceilometerclient"],
    "central_agent_package_list" => ["ceilometer-agent-central"],
    "central_agent_service" => "ceilometer-agent-central",
    "collector_package_list" => ["ceilometer-collector"],
    "collector_service" => "ceilometer-collector",
    "api_package_list" => ["ceilometer-api"],
    "api_service" => "ceilometer-api",
    "compute_package_list" => ["ceilometer-agent-compute"],
    "compute_service" => "ceilometer-agent-compute",
    "service_bin" => "/usr/sbin/service",
    "package_overrides" => "-o Dpkg::Options:='--force-confold'"\
      " -o Dpkg::Options:='--force-confdef'"
  }
  default["ceilometer"]["ssl"]["dir"] = "/etc/ssl"
end
