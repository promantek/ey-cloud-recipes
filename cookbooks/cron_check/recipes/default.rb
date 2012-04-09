# Recipe for testing cron is working properly.
#


if node[:instance_role] == 'db_master' 
  cron "task_name" do 
    #minute '*/15' 
    user 'deploy' 
    command "/usr/bin/scout d6c45d0e-ff1f-4851-944f-2a4f5e64bc3d"
  end 
end 

if node[:name] == 'redis' 
  cron "task_name" do 
    #minute '*/15' 
    user 'deploy' 
    command "/usr/bin/scout 856c1874-e793-43b6-8098-f1e4fb320ec5"
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
