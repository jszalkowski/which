directories = ['/usr/local/bin', '/tmp/app']

package 'gccgo-go'


for directories in directories
  	directory directories do
	    owner 'root'
	    group 'root'
	    mode '750'
	    action :create
	    recursive true
	 end
end


cookbook_file '/tmp/app/app.go' do
	  source 'app.go'
	  owner 'root'
	  group 'root'
	  mode '750'
	  action :create
	  notifies :run, 'execute[app]', :immediately
end


execute 'app' do
	  command 'go build -o /usr/local/bin/app /tmp/app/app.go'
end

cookbook_file '/etc/init/app.conf' do
	  source 'app.conf'
	  owner 'root'
	  group 'root'
	  mode '0750'
	  action :create
end

link '/etc/init.d/app' do
	  to '/etc/init/app.conf'
end
service 'app' do
	  action [:enable, :start]
end

