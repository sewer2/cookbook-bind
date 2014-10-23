package 'pdns2bind' do
    action :upgrade
end

template "/etc/pdns2bind.conf" do
    source "pdns2bind.conf"
    mode 0600
    user 'root'
    group 'root'
    variables(node['bind']['pdns2bind'])
end

cron "pdns2bind.py" do
    action :create
    command "flock -x -w 5 /var/lock/pdns2bind.lock -c /opt/pdns2bind/bin/pdns2bind.py"
end

