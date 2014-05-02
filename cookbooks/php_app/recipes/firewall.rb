include_recipe 'firewall'

firewall_rule "ssh" do
  port 22
  action :allow
end

firewall_rule "http" do
  port node["php_app"]["http_port"].to_i
  action :allow
end

if node["php_app"]["sslcert"] and node["php_app"]["sslkey"]
  firewall_rule "http" do
    port node["php_app"]["https_port"].to_i
    action :allow
  end
end