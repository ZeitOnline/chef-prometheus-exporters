default['prometheus_exporters']['apache']['version'] = '0.7.0'
default['prometheus_exporters']['apache']['url'] = "https://github.com/Lusitaniae/apache_exporter/releases/download/v#{node['prometheus_exporters']['apache']['version']}/apache_exporter-#{node['prometheus_exporters']['apache']['version']}.linux-amd64.tar.gz"
default['prometheus_exporters']['apache']['checksum'] = '0258660d53fb745283ef8d50eef3e50a20c4899997df787b085d52d879bd0561'

default['prometheus_exporters']['apache']['user'] = 'root'
default['prometheus_exporters']['apache']['scrape_uri'] = 'http://localhost/server-status/?auto'
default['prometheus_exporters']['apache']['host_override'] = ''
default['prometheus_exporters']['apache']['insecure'] = false
default['prometheus_exporters']['apache']['port'] = 9117
