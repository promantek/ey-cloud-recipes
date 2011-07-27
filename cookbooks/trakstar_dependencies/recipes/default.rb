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
build_unix_src = "./configure ;
                  make ;
                  sudo make install"

install_unix_odbc =
    "wget ftp://ftp.unixodbc.org/pub/unixODBC/unixODBC-2.3.0.tar.gz ;
     tar -xzvf unixODBC-2.3.0.tar.gz ;
     cd unixODBC-2.3.0 ;
     #{build_unix_src}"

execute install_unix_odbc do
  cwd "/data/dist"
end

install_freetds =
   "wget http://ibiblio.org/pub/Linux/ALPHA/freetds/stable/freetds-stable.tgz ;
   tar -xzvf freetds-stable.tgz ;
   cd freetds-0.82 ;
   #{build_unix_src}"

execute install_freetds do
  cwd "/data/dist"
end

install_freeimage =
   "wget http://downloads.sourceforge.net/freeimage/FreeImage3150.zip ;
   unzip FreeImage3150.zip ;
   cd FreeImage ;
   #{build_unix_src}"

execute install_freeimage do
  cwd "/data/dist"
end

#configure r6SQL after deploy
# manually configure r6 in /data/trakstar/shared/config/database.yml
# r6_incentivation:
#   adapter: sqlserver
#   username: import
#   password: 1mp0rt
#   dataserver: r6_incentivation
#   database: incentivation-test
#   mode: dblib
#   timeout: 6000000
# # manually copy freetds.conf.sample to /usr/local/etc/freetds.conf
# # replace r6_incentivation stanza
# [r6_incentivation]
#  host             = 10.162.126.63
#  port             = 1433
#  tds version      = 8.0
#  client encoding  = UTF-8
#  client charset   = UTF-8



