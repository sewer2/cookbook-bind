
search(:zones).each do |zone|
  next unless zone['zone_info']
  unless zone['autodomain'].nil? || zone['autodomain'] == ''
    search(:node, "domain:#{zone['autodomain']}").each do |host|
      next if host['ipaddress'] == '' || host['ipaddress'].nil?
      zone['zone_info']['records'].push( {
        "name" => host['hostname'],
        "type" => "A",
        "ip" => host['ipaddress']
      })
    end
  end

  template "#{node[:bind][:vardir]}/#{node[:bind][:zonetype]}/db.#{zone['domain']}" do
    source "#{node[:bind][:vardir]}/templates/#{zone['domain']}.erb"
    local true
    owner "root"
    group "root"
    mode 0644
    notifies :restart, resources(:service => "bind9")
    variables({
      :serial => Time.new.strftime("%Y%m%d%H%M%S")
    })
    action :nothing
  end

  template "#{node[:bind][:vardir]}/templates/#{zone['domain']}.erb" do
    source "zonefile.erb"
    owner "root"
    group "root"
    mode 0644
    variables({
      :domain => zone['domain'],
      :soa => zone['zone_info']['soa'],
      :contact => zone['zone_info']['contact'],
      :global_ttl => zone['zone_info']['global_ttl'],
      :nameserver => zone['zone_info']['nameserver'],
      :mail_exchange => zone['zone_info']['mail_exchange'],
      :records => zone['zone_info']['records']
    })
    notifies :create, resources(:template => "#{node[:bind][:vardir]}/#{node[:bind][:zonetype]}/db.#{zone['domain']}"), :immediately
  end
end
