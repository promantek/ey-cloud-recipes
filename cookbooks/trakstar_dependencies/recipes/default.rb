#
# Cookbook Name:: trakstar_dependencies
# Recipe:: default
#


# 0.8.3 is there by default, we require 0.9.2
execute "sudo gem install rake -v0.9.2" do
end

# set timezone to PST
execute "sudo ln -sf /usr/share/zoneinfo/US/Pacific /usr/share/zoneinfo/localtime" do
end

directory '/data/dist/' do
  owner 'deploy'
  group 'users'
  mode '0755'
end

# install MSSQL adapter dependencies for r6 import
execute install_unixODBC do
  cwd "/data/dist"
end

execute install_freetds do
  cwd "/data/dist"
end

# remove selenium, causes production dependency issues
execute "cd /data/trakstar/current ; rm -rf #{troublesome_files_causing_class_loading_issues} " do
  cwd "/data/dist"
end


def install_unixODBC
  "wget ftp://ftp.unixodbc.org/pub/unixODBC/unixODBC-2.3.0.tar.gz ;
   tar -xzvf unixODBC-2.3.0.tar.gz ;
   cd unixODBC-2.3.0 ;
   #{configure_make_install}"
end

def install_freetds
  "wget http://ibiblio.org/pub/Linux/ALPHA/freetds/stable/freetds-stable.tgz ;
   tar -xzvf freetds-stable.tgz ;
   cd freetds-0.82 ;
   #{configure_make_install}"
end

def configure_make_install
  "./configure ;
   make ;
   sudo make install"
end

def troublesome_files_causing_class_loading_issues
  "spec/selenium spec/support/selenium_spec_helper.rb lib/tasks/rspec_mods.rake lib/tasks/rspec_plugins.rake rm lib/tasks/initech.rake"
end
