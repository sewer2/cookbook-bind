if Chef::Config['solo'] && !node['bind']['allow_solo_search']
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else
  search(:zones).each do |zone|
    next unless zone['zone_info']

    template "#{node[:bind][:vardir]}/#{zone['type']}/#{zone['domain']}" do
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
      notifies :create, resources(:template => "#{node[:bind][:vardir]}/#{zone['type']}/#{zone['domain']}"), :immediately
    end
  end
end
