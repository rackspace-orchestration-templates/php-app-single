node.set_unless['apache']['listen_ports'] = [node['php_app']['http_port'], node['php_app']['https_port']]

include_recipe 'php'
include_recipe 'apache2'
include_recipe 'apache2::mod_php5'
include_recipe 'apache2::mod_rewrite'
include_recipe 'application'

begin
  databag = Chef::EncryptedDataBagItem.load(node["php_app"]["databag_name"], "secrets")
rescue
  Chef::Log.debug("No databag found. Using attributes.")
end

if node["php_app"]["databag_name"]
  node.set_unless['php_app']['sslcert'] = databag['php_app']['sslcert'] rescue nil
  node.set_unless['php_app']['sslkey'] = databag['php_app']['sslkey'] rescue nil
  node.set_unless['php_app']['sslcacert'] = databag['php_app']['sslcacert'] rescue nil
end


template "#{node['apache']['dir']}/ports.conf" do
  source "ports.conf.erb"
  variables :apache_listen_ports => node['apache']['listen_ports'].map { |p| p.to_i }.uniq
  notifies :restart, "service[apache2]"
  mode 00644
end

### If the repo provided is using git's SSH protocol, add the host to known_hosts ###
if node["php_app"]["repo"] =~ /^git@/
  require 'uri'
  ### Temporarily convert ssh address to http protocol to find host easier ###
  uri = URI(node["php_app"]["repo"].gsub(":","/").gsub(/git\@/, "http://"))
  host = uri.host
  ssh_known_hosts_entry host
end

key = databag['php_app']['deploy_key'] rescue node["php_app"]["deploy_key"]
if key
  key = key.gsub("-----BEGIN RSA PRIVATE KEY-----", "").gsub("-----END RSA PRIVATE KEY-----", "").gsub(" ", "\n")
  git_deploy_key = "-----BEGIN RSA PRIVATE KEY-----\n" + key + "-----END RSA PRIVATE KEY-----"
end

application "#{node["php_app"]["domain"]}" do
    path node["php_app"]["destination"]
    owner node["php_app"]["username"]
    group node["php_app"]["group"]
    repository node["php_app"]["repo"]
    revision node["php_app"]["rev"]
    if key
      deploy_key git_deploy_key
    end

    mod_php_apache2 do
      app_root "#{node['php_app']['public']}"
      webapp_template "app.conf.erb"
      server_aliases node["php_app"]["server_aliases"]
    end
  end
  
  if node["php_app"]["sslcert"] and node["php_app"]["sslkey"]
  
    include_recipe "apache2::mod_ssl"
  
    case node['platform']
    when "ubuntu", "debian"
      node.set["php_app"]["sslcert_file"] = "/etc/ssl/certs/#{node['php_app']['domain']}.crt"
      node.set["php_app"]["sslkey_file"] = "/etc/ssl/private/#{node['php_app']['domain']}.key"
      node.set["php_app"]["sslcacert_file"] = "/etc/ssl/certs/#{node['php_app']['domain']}.ca.crt" if node["php_app"]["sslcacert"]
  
      file node["php_app"]["sslcert_file"] do
        content node["php_app"]["sslcert"]
        owner "root"
        group "root"
        mode "0644"
        action :create
      end
      file node["php_app"]["sslkey_file"] do
        content node["php_app"]["sslkey"]
        owner "root"
        group "root"
        mode "0600"
        action :create
      end
      if node["php_app"]["sslcacert_file"]
        file node["php_app"]["sslcacert_file"] do
          content node["php_app"]["sslcacert"]
          owner "root"
          group "root"
          mode "0644"
          action :create
        end
      end
    else
      node.set["php_app"]["sslcert_file"] = "/etc/pki/tls/certs/#{node['php_app']['domain']}.crt"
      node.set["php_app"]["sslkey_file"] = "/etc/pki/tls/private/#{node['php_app']['domain']}.key"
      node.set["php_app"]["sslcacert_file"] = "/etc/pki/tls/certs/#{node['php_app']['domain']}.ca.crt" if node["php_app"]["sslcacert"]
  
      file node["php_app"]["sslcert_file"] do
        content node["php_app"]["sslcacert"]
        owner "root"
        group "root"
        mode "0644"
        action :create
      end
      file node["php_app"]["sslkey_file"] do
        content node["php_app"]["sslkey"]
        owner "root"
        group "root"
        mode "0600"
        action :create
      end
      if node["php_app"]["sslcacert_file"]
        file node["php_app"]["sslcacert_file"] do
          content node["php_app"]["sslcacert"]
          owner "root"
          group "root"
          mode "0644"
          action :create
        end
      end
    end
  
    web_app "#{node['php_app']['domain']}-ssl" do
      template "https_app.conf.erb"
      docroot "#{node['php_app']['destination']}/current#{node['php_app']['public']}"
      server_name node['domain']
      server_aliases node['php_app']['server_aliases']
      port node['php_app']['https_port']
      listen_ports [node['php_app']['http_port'], node['php_app']['https_port']]
      sslcert node["php_app"]["sslcert_file"]
      sslkey node["php_app"]["sslkey_file"]
      cacert node["php_app"]["sslcacert_file"] if node["php_app"]["sslcacert_file"]
    end
  end
