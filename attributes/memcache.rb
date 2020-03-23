default['prometheus_exporters']['memcache']['version'] = '0.6.0'
default['prometheus_exporters']['memcache']['url'] = "https://github.com/prometheus/memcached_exporter/releases/download/v#{node['prometheus_exporters']['memcache']['version']}/memcached_exporter-#{node['prometheus_exporters']['memcache']['version']}.linux-386.tar.gz"
default['prometheus_exporters']['memcache']['checksum'] = '024a5b2c497b3f228d6438a37d102842b256742bdd30f80003b9c6e67e1379af'
default['prometheus_exporters']['memcache']['user'] = 'root'
default['prometheus_exporters']['memcache']['memcache_address'] = "localhost:11211"
default['prometheus_exporters']['memcache']['port'] = 9150
