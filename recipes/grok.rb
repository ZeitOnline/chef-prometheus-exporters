#
# Cookbook Name:: prometheus_exporters
# Recipe:: grok
#
# Copyright 2017, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

unless node['prometheus_exporters']['disable']
  
    grok_exporter 'main' do
      conffile node['prometheus_exporters']['grok']['conffile']
      port node['prometheus_exporters']['grok']['port']
      user node['prometheus_exporters']['statsd']['user']
  
      action %i[install enable start]
    end
  end
