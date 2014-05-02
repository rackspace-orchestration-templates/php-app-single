#
# Cookbook Name:: php_app
# Recipe:: default
#
# Copyright 2013, Rackspace Hosting
#

# Function to validate that packages provided be installed
def verify_pkgs(pkg_list)
  pkgs = Array.new
  pkg_list.each do |p|
    r = `apt-cache pkgnames | grep ^#{p}$`
    pkgs.push(r.chomp) unless r.empty?
  end
  return pkgs
end

include_recipe 'php'
include_recipe 'apache2'
include_recipe 'apache2::mod_php5'
include_recipe 'apache2::mod_rewrite'
include_recipe 'application'

if node["php_app"]["domain"].start_with?("www.")
  node.set_unless["php_app"]["server_aliases"] = [node["php_app"]["domain"], node["php_app"]["domain"].gsub(/^www./, "")]
else
  node.set_unless["php_app"]["server_aliases"] = [node["php_app"]["domain"], "www.#{node["php_app"]["domain"]}"]
end

case node.platform
  when "debian", "ubuntu"
    package "git-core"
  when "rhel", "centos"
    package "git"
end

if node["php"]["packages"]
  package_list = node["php_app"]["packages"].split(",")
end

verify_pkgs(package_list.collect(&:strip)).each do |pkg|
  package pkg.lstrip do
    action :install
  end
end

include_recipe "php_app::varnish" if node['php_app']['varnish']

if node["php_app"]["repo"]
  include_recipe "php_app::apache_deploy"
else
  include_recipe "php_app::apache_stack"
end

include_recipe "php_app::firewall"
