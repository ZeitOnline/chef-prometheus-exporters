#
# Cookbook Name:: prometheus_exporters
# Resource:: grok
#
# Copyright 2017, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

resource_name :grok_exporter

property :conffile, String, default: "/etc/grok-config.yaml"
property :port, String, default: '9144'
property :user, String, default: 'root'

action :install do
  # Set property that can be queried with Chef search
  node.default['prometheus_exporters']['grok']['enabled'] = true

  options = "-config #{new_resource.conffile}"

  service_name = "grok_exporter_#{new_resource.name}"

  package 'unzip'

  # Download binary
  remote_file 'grok_exporter' do
    path "#{Chef::Config[:file_cache_path]}/grok_exporter.zip"
    owner 'root'
    group 'root'
    mode '0644'
    source node['prometheus_exporters']['grok']['url']
    checksum node['prometheus_exporters']['grok']['checksum']
    notifies :restart, "service[#{service_name}]"
  end
  
  bash 'unzip grok_exporter' do
    code "unzip #{Chef::Config[:file_cache_path]}/grok_exporter.zip -d /opt"
    action :nothing
    subscribes :run, 'remote_file[grok_exporter]', :immediately
  end

  link 'patterns dir' do
    target_file node['prometheus_exporters']['grok']['patterns_dir']
    to "/opt/grok_exporter-#{node['prometheus_exporters']['grok']['version']}.linux-amd64/patterns"
  end

  link '/usr/local/sbin/grok_exporter' do
    to "/opt/grok_exporter-#{node['prometheus_exporters']['grok']['version']}.linux-amd64/grok_exporter"
  end

  # Configure to run as a service
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
        cmd: "/usr/local/sbin/grok_exporter #{options}",
        service_description: 'Prometheus Grok Exporter',
      )
      notifies :restart, "service[#{service_name}]"
    end

  when /systemd/
    systemd_unit "#{service_name}.service" do
      content(
        'Unit' => {
          'Description' => 'Systemd unit for Prometheus Grok Exporter',
          'After' => 'network.target remote-fs.target apiserver.service',
        },
        'Service' => {
          'Type' => 'simple',
          'User' => new_resource.user,
          'ExecStart' => "/usr/local/sbin/grok_exporter #{options}",
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
    template "/etc/init/#{service_name}.conf" do
      cookbook 'prometheus_exporters'
      source 'upstart.conf.erb'
      owner 'root'
      group 'root'
      mode '0644'
      variables(
        env: environment_list,
        user: new_resource.user,
        cmd: "/usr/local/sbin/grok_exporter #{options}",
        service_description: 'Prometheus Grok Exporter',
      )
      notifies :restart, "service[#{service_name}]"
    end

  else
    raise "Init system '#{node['init_package']}' is not supported by the 'prometheus_exporters' cookbook"
  end
end

action :enable do
  action_install
  service "grok_exporter_#{new_resource.name}" do
    action :enable
  end
end

action :start do
  service "grok_exporter_#{new_resource.name}" do
    action :start
  end
end

action :disable do
  service "grok_exporter_#{new_resource.name}" do
    action :disable
  end
end

action :stop do
  service "grok_exporter_#{new_resource.name}" do
    action :stop
  end
end
