default['prometheus_exporters']['grok']['version'] = '1.0.0.RC2'
default['prometheus_exporters']['grok']['url'] = "https://github.com/fstab/grok_exporter/releases/download/v1.0.0.RC2/grok_exporter-#{node['prometheus_exporters']['grok']['version']}.linux-amd64.zip"
default['prometheus_exporters']['grok']['checksum'] = '3d7457888baa20166051bc6da2e38717c195ccdaa0e219787e0ca034d29b879f'

default['prometheus_exporters']['grok']['port'] = "9144"
default['prometheus_exporters']['grok']['user'] = 'root'
default['prometheus_exporters']['grok']['patterns_dir'] = '/usr/lib/grok-patterns'
default['prometheus_exporters']['grok']['conffile'] = '/etc/grok-config.yaml'