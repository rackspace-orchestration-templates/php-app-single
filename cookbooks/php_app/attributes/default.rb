default["php_app"]["destination"] = "/var/www/vhosts/application"
default["php_app"]["public"] = "/"
default["php_app"]["username"] = "www-data"
default["php_app"]["group"] = "www-data"
default["php_app"]["repo"] = nil 
default["php_app"]["rev"] = "HEAD"
default["php_app"]["deploy_key"] = nil 
default["php_app"]["domain"] = "example.com"
default["php_app"]["server_aliases"] = []
default["php_app"]["http_port"] = "80"
default["php_app"]["https_port"] = "443"
default["php_app"]["sslcert"] = nil
default["php_app"]["sslkey"] = nil
default["php_app"]["sslcacert"] = nil
default["php_app"]["varnish"] = nil
default["php_app"]["varnish_port"] = "80"
#A comma separated string of packages
default["php_app"]["packages"] = ""
