%w{nginx awscli}.each do |pkg|
   package pkg do
      action :install
   end
end
service 'nginx' do
  action :start
end

template "/etc/nginx/sites-available/default" do
  source "default.erb"
  mode "0644"
  notifies :reload, 'service[nginx]'
end

