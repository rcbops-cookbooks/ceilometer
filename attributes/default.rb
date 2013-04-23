
default["ceilometer"]["db"]["name"] = "ceilometer"
default["ceilometer"]["db"]["username"] = "ceilometer"

default["ceilometer"]["service_tenant_name"] = "service"
default["ceilometer"]["service_user"] = "ceilometer"
default["ceilometer"]["service_role"] = "admin"

default["ceilometer"]["services"]["api"]["scheme"] = "http"
default["ceilometer"]["services"]["api"]["network"] = "public"
default["ceilometer"]["services"]["api"]["port"] =  8777
default["ceilometer"]["services"]["api"]["path"] = "/"

# should there be syslog settings here?
default["ceilometer"]["syslog"]["use"] = true
default["ceilometer"]["syslog"]["facility"] = "LOG_LOCAL3"

default["ceilometer"]["logging"]["debug"] = "false"
default["ceilometer"]["logging"]["verbose"] = "false"

# metering secret should be secret and unguessable, to prevent
# spoofing metrics
# default["ceilometer"]["metering_secret"] = "ceilometer"

case platform
when "fedora", "redhat", "centos", "scientific", "amazon"
  default["ceilometer"]["platform"] = {
    "infra_package_list" => [],
    "compute_package_list" => [],
    "package_overrides" => ""
  }
when "ubuntu", "debian"
  default["ceilometer"]["platform"] = {
    "infra_package_list" => ["ceilometer-collector", "ceilometer-agent-central", "ceilometer-api"],
    "infra_service_list" => ["ceilometer-collector", "ceilometer-agent-central", "ceilometer-api"],
    "compute_package_list" => ["ceilometer-agent-compute"],
    "compute_service_list" => ["ceilometer-agent-compute"],
    "compute_package_list" => ["ceilometer-agent-compute"],
    "package_overrides" => "-o Dpkg::Options:='--force-confold' -o Dpkg::Options:='--force-confdef'"
  }
end
