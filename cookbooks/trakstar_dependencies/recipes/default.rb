#
# Cookbook Name:: trakstar_dependencies
# Recipe:: default
#


#
#  config for ALL node types
#

#
#  Updated 5-Nov-2012 to ensure that proper version of libyaml/psych/ruby are installed
#

# set timezone to PST
execute 'sudo ln -sf /usr/share/zoneinfo/US/Pacific /usr/share/zoneinfo/localtime'

directory '/data/dist/' do
  owner 'deploy'
  group 'users'
  mode '0755'
end

# build_unix_src = "./configure ;
#                   make ;
#                   sudo make install"

if ['solo', 'app', 'app_master', 'util'].include?(node[:instance_role])
  # 0.8.3 is there by default, we require 0.9.2
  execute 'sudo gem install rake -v0.9.2'
  # Building the linecache19 gem may fail during "bundle install" if the following gem is not installed
  execute 'sudo gem install ruby-debug19'

  install_libyaml_0_1_4 =
    "wget http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz ;
     tar xzvf yaml-0.1.4.tar.gz ;
     cd yaml-0.1.4 ;
     ./configure --prefix=/usr && make && sudo make install"

  libyaml_version = begin
    File.open('/tmp/get_libyaml_version.c', 'w') do |file|
      file.puts(%Q[#include <yaml.h>\nint main(void) { printf("%s", yaml_get_version_string()); }])
    end
    system('gcc -o /tmp/a.out /tmp/get_libyaml_version.c -L /usr/lib -I /usr/include -l yaml')
    `/tmp/a.out`
  end

  psych_version = `echo 'require "psych"; puts Psych::VERSION' |ruby`.chomp

  install_ruby_1_9_3_p286 =
    "wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p286.tar.gz ;
     tar xzvf ruby-1.9.3-p286.tar.gz ;
     cd ruby-1.9.3-p286 ;
     cat #{File.expand_path(File.dirname(__FILE__))}/ruby_perf_patch.diff | patch -p1 ;
     autoconf ;
    ./configure --prefix=/usr --enable-shared --disable-install-doc --with-opt-dir=/usr/lib ;
    make -j 8 && sudo make install"

  unless (RUBY_VERSION == '1.9.3' && RUBY_PATCHLEVEL == 286 && psych_version == '1.3.4' && libyaml_version == '0.1.4')
    execute install_libyaml_0_1_4
    execute install_ruby_1_9_3_p286
  end

  node[:applications].each do |app, data|
    template '/usr/local/bin/ruby_wrapper.sh' do
      owner 'root'
      group 'root'
      mode 0644
      source 'ruby_wrapper.sh.erb'
    end

    template '/etc/nginx/servers' do
      owner 'deploy'
      group 'deploy'
      mode 0422
      source 'trakstar.conf.erb'
    end
  end

  # install_freeimage =
  #   "wget http://downloads.sourceforge.net/freeimage/FreeImage3150.zip ;
  #    unzip FreeImage3150.zip ;
  #    cd FreeImage ;
  #    #{build_unix_src}"

  # filename = '/data/dist/FreeImage3150.zip'
#  if !File.exist?(filename)
#    execute install_freeimage do
#      cwd "/data/dist"
#    end
#  end

  # install MSSQL adapter dependencies for r6 import
  # install_unix_odbc =
  #     "wget ftp://ftp.unixodbc.org/pub/unixODBC/unixODBC-2.3.0.tar.gz ;
  #      tar -xzvf unixODBC-2.3.0.tar.gz ;
  #      cd unixODBC-2.3.0 ;
  #      #{build_unix_src}"

  # filename = '/data/dist/unixODBC-2.3.0.tar.gz'
#  if !File.exist?(filename)
#    execute install_unix_odbc do
#      cwd "/data/dist"
#    end
#  end

  # install_freetds =
  #    "wget http://ibiblio.org/pub/Linux/ALPHA/freetds/stable/freetds-stable.tgz ;
  #    tar -xzvf freetds-stable.tgz ;
  #    cd freetds-0.91 ;
  #    #{build_unix_src}"

  # filename = '/data/dist/freetds-stable.tgz'
#  if !File.exist?(filename)
#    execute install_freetds do
#      cwd "/data/dist"
#    end
#  end

  ## install in deploy hook
  # install_32bit_wkhtmltopdf =
  #    "sudo emerge libXext app-admin/eselect-fontconfig x11-libs/libXrender ;
  #    wget http://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-0.9.9-static-i386.tar.bz2 ;
  #    tar xvjf wkhtmltopdf-0.9.9-static-i386.tar.bz2 ;
  #    mv wkhtmltopdf-i386 /usr/local/bin/wkhtmltopdf ;
  #    chmod +x /usr/local/bin/wkhtmltopdf"

  # install_64bit_wkhtmltopdf =
  #    "sudo emerge libXext app-admin/eselect-fontconfig x11-libs/libXrender ;
  #     wget http://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-0.9.9-static-amd64.tar.bz2 ;
  #     tar xvjf wkhtmltopdf-0.9.9-static-amd64.tar.bz2 ;
  #     mv wkhtmltopdf-amd64 /usr/local/bin/wkhtmltopdf ;
  #     chmod +x /usr/local/bin/wkhtmltopdf"

  # filename = '/data/dist/wkhtmltopdf-0.9.9-static-amd64.tar.bz2'
#  if !File.exist?(filename)
#    execute install_64bit_wkhtmltopdf do
#      cwd "/data/dist"
#    end
#  end

  # install_imagemagick =
  #     "wget ftp://ftp.fifi.org/pub/ImageMagick/ImageMagick-6.7.9-10.tar.gz ;
  #     tar xvzf ImageMagick-6.7.9-10.tar.gz ;
  #     cd ImageMagick-6.7.9-10;
  #     #{build_unix_src}"

  # filename = '/data/dist/ImageMagick-6.7.9-10.tar.gz'
#  if !File.exist?(filename)
#    execute install_imagemagick do
#      cwd "/data/dist"
#    end
#  end
end

if ['solo', 'app', 'app_master', 'util', 'db_master'].include?(node[:instance_role])

  # configure SMTP
  node[:applications].each do |app, data|
    template '/etc/ssmtp/ssmtp.conf' do
      owner 'root'
      group 'root'
      mode 0644
      source 'ssmtp.conf.erb'
    end
    template '/etc/monit.d/alerts.monitrc' do
      owner 'root'
      group 'root'
      mode 0644
      source 'alerts.monitrc.erb'
    end
  end
  # Isn't this redundant with the "owner" / "group" and "mode" set in the template blocks above?
  execute 'chown deploy:deploy /etc/ssmtp/ssmtp.conf'

  execute 'chmod +x /usr/sbin/ssmtp /usr/bin/sendmail'

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
