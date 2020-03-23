#
# Cookbook Name:: prometheus_exporters
# Recipe:: memcache
#
# Copyright 2017, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

unless node['prometheus_exporters']['disable']
  node_port = node['prometheus_exporters']['memcache']['port']

  memcache_exporter 'main' do
    memcache_address node['prometheus_exporters']['memcache']['memcache_address']
    user node['prometheus_exporters']['memcache']['user']
    telemetry_address ":#{node_port}"

    action %i[install enable start]
  end
end
