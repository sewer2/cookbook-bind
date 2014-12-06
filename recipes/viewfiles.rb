#
# Cookbook Name:: bind
# Recipe:: viewfiles
#
# Copyright 2014, Alexey Mochkin <alukardd@alukardd.org>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

unless node[:bind].has_key?(:views) && !node[:bind][:views].empty?
  Chef::Log.warn('You should specify one or more views to use this recipe.')
else
  template "#{node[:bind][:views_file]}" do
    source "named.conf.views.erb"
    owner "root"
    group "root"
    mode 0644
    notifies :restart, resources(:service => "bind9")
    action :create
  end

  node[:bind][:views].each do |view_name, view|
    template "#{node[:bind][:sysconfdir]}/views/#{view_name}.view" do
      source "view.erb"
      owner "root"
      group "root"
      mode 0644
      variables({
        :view_name => view_name,
        :view => view.dup.tap{ |h| h.delete(:zones) },
        :zones => view[:zones] || []
      })
      notifies :restart, resources(:service => "bind9")
      action :create
    end
  end
end

# vim: ts=2:sw=2:expandtab
