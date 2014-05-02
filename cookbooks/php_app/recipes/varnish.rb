node.set['varnish']['listen_port'] = node['php_app']['http_port']
node.set['php_app']['http_port'] = "8080"
node.set['apache']['listen_ports'] = ["8080", node['php_app']['https_port']]

# template "#{node['apache']['dir']}/ports.conf" do
#   source "ports.conf.erb"
#   variables :apache_listen_ports => node['apache']['listen_ports'].map { |p| p.to_i }.uniq
#   notifies :restart, "service[apache2]", :immediately
#   mode 00644
# end

include_recipe 'varnish'
include_recipe 'firewall'

firewall_rule "varnish" do
  port node["varnish"]["listen_port"].to_i
  action :allow
  notifies :restart, "service[varnish]", :delayed
end