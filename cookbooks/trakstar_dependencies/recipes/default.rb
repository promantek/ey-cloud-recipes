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
