package 'pdns2bind' do
    action :upgrade
end

template "#{node['bind']['pdns2bind']['config']}" do
  source "pdns2bind.conf.erb"
    mode 0600
    user 'root'
    group 'root'
    variables(node['bind']['pdns2bind'])
end

cron "pdns2bind.py" do
    action :create
    command "flock -x -w 5 /var/lock/pdns2bind.lock -c \"/opt/pdns2bind/bin/sql2dns.py -c #{node['bind']['pdns2bind']['config']}\""
end

