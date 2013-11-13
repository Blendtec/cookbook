# encoding: utf-8
# Author:: Joshua Timberman(<joshua@opscode.com>)
# Cookbook Name:: postfix
# Recipe:: default
#
# Copyright 2009-2012, Opscode, Inc.
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

package 'postfix'

if node['postfix']['use_procmail']
  package 'procmail'
end


if !node['postfix']['sender_canonical_map_entries'].empty?
  template "#{node['postfix']['conf_dir']}/sender_canonical" do
    owner 'root'
    group 0
    mode  '0644'
    notifies :restart, 'service[postfix]'
  end

  if !node['postfix']['main'].key?('sender_canonical_maps')
    node.set['postfix']['main']['sender_canonical_maps'] = "hash:#{node['postfix']['conf_dir']}/sender_canonical"
  end
end

%w{main master}.each do |cfg|
  template "#{node['postfix']['conf_dir']}/#{cfg}.cf" do
    source "#{cfg}.cf.erb"
    owner 'root'
    group 0
    mode 00644
    notifies :restart, 'service[postfix]'
    variables(settings: node['postfix'][cfg])
    cookbook node['postfix']["#{cfg}_template_source"]
  end
end

service 'postfix' do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end