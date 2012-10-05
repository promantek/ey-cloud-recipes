#
# Cookbook Name:: trakstar_dependencies
# Recipe:: default
#


#
#  config for ALL node types
#

# set timezone to PST
execute "sudo ln -sf /usr/share/zoneinfo/US/Pacific /usr/share/zoneinfo/localtime" do
end

directory '/data/dist/' do
  owner 'deploy'
  group 'users'
  mode '0755'
end

build_unix_src = "./configure ;
                  make ;
                  sudo make install"

if ['solo', 'app', 'app_master', 'util'].include?(node[:instance_role])
  # 0.8.3 is there by default, we require 0.9.2
  execute "sudo gem install rake -v0.9.2" do
  end

  install_freeimage =
     "wget http://downloads.sourceforge.net/freeimage/FreeImage3150.zip ;
     unzip FreeImage3150.zip ;
     cd FreeImage ;
     #{build_unix_src}"

  execute install_freeimage do
    cwd "/data/dist"
  end

  # install MSSQL adapter dependencies for r6 import
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
     cd freetds-stable ;
     #{build_unix_src}"

  execute install_freetds do
    cwd "/data/dist"
  end
  
  
  ## install in deploy hook
  install_32bit_wkhtmltopdf =
     "sudo emerge libXext app-admin/eselect-fontconfig x11-libs/libXrender ;
     wget http://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-0.9.9-static-i386.tar.bz2 ;
     tar xvjf wkhtmltopdf-0.9.9-static-i386.tar.bz2 ;
     mv wkhtmltopdf-i386 /usr/local/bin/wkhtmltopdf ;
     chmod +x /usr/local/bin/wkhtmltopdf"

  install_64bit_wkhtmltopdf =
     "sudo emerge libXext app-admin/eselect-fontconfig x11-libs/libXrender ;
      wget http://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-0.9.9-static-amd64.tar.bz2 ;
      tar xvjf wkhtmltopdf-0.9.9-static-amd64.tar.bz2 ;
      mv wkhtmltopdf-amd64 /usr/local/bin/wkhtmltopdf ;
      chmod +x /usr/local/bin/wkhtmltopdf"

  execute install_32bit_wkhtmltopdf do
    cwd "/data/dist"
  end
  
  install_imagemagick =
      wget ftp://ftp.fifi.org/pub/ImageMagick/ImageMagick-6.6.8-10.tar.gz ;
      tar xvzf ImageMagick-6.6.8-10.tar.gz ;
      cd ImageMagick-6.6.8-10;
      #{build_unix_src}"

  execute install_imagemagick do
    cwd "/data/dist"
  end
end
 
if ['solo', 'app', 'app_master', 'util', 'db_master'].include?(node[:instance_role])
   
  # configure SMTP
  node[:applications].each do |app, data|
    template "/etc/ssmtp/ssmtp.conf" do 
      owner 'root' 
      group 'root' 
      mode 0644 
      source "ssmtp.conf.erb" 
    end
    template "/etc/monit.d/alerts.monitrc" do 
      owner 'root' 
      group 'root' 
      mode 0644 
      source "alerts.monitrc.erb"
      variables({
       :role => node[:instance_rolea]
      })
    end
  end
  execute "chown deploy:deploy /etc/ssmtp/ssmtp.conf" do
  end
  execute "chmod +x /usr/sbin/ssmtp /usr/bin/sendmail" do
  end

end
  
  # TODO
  # install tiny_tds gem
  # mkdir -p data/trakstar/shared/config/environments/
  # copy localized production.rb yml data/trakstar/shared/config
  # copy resque.yml to 
  
  # engineyard/portage/www-servers/nginx/files/nginx.conf
  # upload_max_file_size 10m;
  #   client_max_body_size 50m;
  #   
  
  # config for resque-web
  # sudo gem install bundler
  # sudo gem install resque-web
  # create /data/trakstar/current/Gemfile gem 'resque', '1.19.0'
  # RAILS_ENV=production bundle exec resque-web -p 8282
  
  
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
# # manually copy freetds.conf.sample to /e
# # replace r6_incentivation stanza
# [r6_incentivation]
#  host             = 10.162.126.63
#  port             = 1433
#  tds version      = 8.0
#  client encoding  = UTF-8
#  client charset   = UTF-8



