#
# Cookbook Name:: prometheus_exporters
# Resource:: memcache
#
# Copyright 2017, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

resource_name :memcache_exporter

property :memcache_address, String, default: 'localhost:11211'
property :telemetry_address, String, default: ':9150'
property :telemetry_endpoint, String, default: '/metrics'
property :user, String, default: 'root'

action :install do
  # Set property that can be queried with Chef search
  node.default['prometheus_exporters']['memcache']['enabled'] = true

  options = "--web.listen-address #{new_resource.telemetry_address}"
  options += " --web.telemetry-path #{new_resource.telemetry_endpoint}"
  options += " --memcached.address #{new_resource.memcache_address}"

  service_name = "memcache_exporter_#{new_resource.name}"

  remote_file 'memcache_exporter' do
    path "#{Chef::Config[:file_cache_path]}/memcache_exporter.tar.gz"
    owner 'root'
    group 'root'
    mode '0644'
    source node['prometheus_exporters']['memcache']['url']
    checksum node['prometheus_exporters']['memcache']['checksum']
  end

  bash 'untar memcache_exporter' do
    code "tar -xzf #{Chef::Config[:file_cache_path]}/memcache_exporter.tar.gz -C /opt"
    action :nothing
    subscribes :run, 'remote_file[memcache_exporter]', :immediately
  end

  link '/usr/local/sbin/memcached_exporter' do
    to "/opt/memcached_exporter-#{node['prometheus_exporters']['memcache']['version']}.linux-386/memcached_exporter"
  end

  service service_name do
    action :nothing
  end

  case node['init_package']
  when /init/
    %w[
      /var/run/prometheus
      /var/log/prometheus
    ].each do |dir|
      directory dir do
        owner 'root'
        group 'root'
        mode '0755'
        recursive true
        action :create
      end
    end

    directory "/var/log/prometheus/#{service_name}" do
      owner new_resource.user
      group 'root'
      mode '0755'
      action :create
    end

    template "/etc/init.d/#{service_name}" do
      cookbook 'prometheus_exporters'
      source 'initscript.erb'
      owner 'root'
      group 'root'
      mode '0755'
      variables(
        name: service_name,
        user: new_resource.user,
        cmd: "/usr/local/sbin/memcached_exporter #{options}",
        service_description: 'Prometheus memcache Exporter',
      )
      notifies :restart, "service[#{service_name}]"
    end

  when /systemd/
    systemd_unit "#{service_name}.service" do
      content(
        'Unit' => {
          'Description' => 'Systemd unit for Prometheus memcache Exporter',
          'After' => 'network.target remote-fs.target apiserver.service',
        },
        'Service' => {
          'Type' => 'simple',
          'User' => new_resource.user,
          'ExecStart' => "/usr/local/sbin/memcached_exporter #{options}",
          'WorkingDirectory' => '/',
          'Restart' => 'on-failure',
          'RestartSec' => '30s',
        },
        'Install' => {
          'WantedBy' => 'multi-user.target',
        },
      )
      notifies :restart, "service[#{service_name}]"
      action :create
    end

  when /upstart/
    p environment_list

    template "/etc/init/#{service_name}.conf" do
      cookbook 'prometheus_exporters'
      source 'upstart.conf.erb'
      owner 'root'
      group 'root'
      mode '0644'
      variables(
        env: environment_list,
        user: new_resource.user,
        cmd: "/usr/local/sbin/memcached_exporter #{options}",
        service_description: 'Prometheus memcache Exporter',
      )
      notifies :restart, "service[#{service_name}]"
    end

  else
    raise "Init system '#{node['init_package']}' is not supported by the 'prometheus_exporters' cookbook"
  end
end

action :enable do
  action_install
  service "memcache_exporter_#{new_resource.name}" do
    action :enable
  end
end

action :start do
  service "memcache_exporter_#{new_resource.name}" do
    action :start
  end
end

action :disable do
  service "memcache_exporter_#{new_resource.name}" do
    action :disable
  end
end

action :stop do
  service "memcache_exporter_#{new_resource.name}" do
    action :stop
  end
end
