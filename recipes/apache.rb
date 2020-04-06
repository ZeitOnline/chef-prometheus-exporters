unless node['prometheus_exporters']['disable']
  apache_exporter 'main' do
    user node["prometheus_exporters"]["apache"]["user"]
    host_override node["prometheus_exporters"]["apache"]["host_override"]
    insecure node["prometheus_exporters"]["apache"]["insecure"]
    scrape_uri node["prometheus_exporters"]["apache"]["scrape_uri"]
    
    action %i[install enable start]
  end
end