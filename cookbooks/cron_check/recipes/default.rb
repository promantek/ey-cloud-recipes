# Recipe for testing cron is working properly.
#

#
# NOTE: crontab for redis servers managed by whenever in a deploy hook.
#       all scheduled tasks are run single server named "redis", since there is just one of them

if node[:instance_role] == 'db_master' 
  cron "task_name" do 
    #minute '*/15' 
    user 'deploy' 
     command "/usr/bin/scout d6c45d0e-ff1f-4851-944f-2a4f5e64bc3d"
  end 

#  cron "db backups" do
#    hour "2"
#    minute "0"
#    command "/mnt/backups/backup_postgres.sh"
#  end

#  cron "s3 backups" do
#    hour "2"
#    minute "0"
#    command "/mnt/backups/backup_s3_assets.sh"
#  end

end

if node[:name] == 'app_master' 
  cron "task_name" do 
    #minute '*/15' 
    user 'deploy' 
    command "/usr/bin/scout 91fe7a32-64f3-4536-898b-b76ccee9e330"
  end 
end 

#
# redundant with the EY use cronjob
#
#if node[:instance_role] == 'app_master'
  #cron "task_name" do 
    ##minute '*/15' 
    #user 'deploy' 
    #command "/usr/bin/scout 91fe7a32-64f3-4536-898b-b76ccee9e330"
  #end 
#end 
