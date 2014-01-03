#
# Cookbook Name:: wordpress
# Recipe:: default
#
# Copyright 2013, K-TEC, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node[:deploy].each do |app_name, deploy|

  git "#{deploy[:deploy_to]}/shared/wp-content" do
    repository 'https://github.com/Blendtec/blog-content.git'
    reference 'master'
    enable_submodules true
    action :sync
    user deploy[:user]
    group deploy[:group]
  end

  template "#{deploy[:deploy_to]}/current/wp-config.php" do
    source 'wp-config.php.erb'
    variables(
        :db_name => (deploy[:database][:database] rescue nil),
        :db_user => (deploy[:database][:username] rescue nil),
        :db_password => (deploy[:database][:password] rescue nil),
        :db_host => (deploy[:database][:host] rescue nil),
        :auth_key => node['wordpress']['keys']['auth'],
        :secure_auth_key => node['wordpress']['keys']['secure_auth'],
        :logged_in_key => node['wordpress']['keys']['logged_in'],
        :nonce_key => node['wordpress']['keys']['nonce'],
        :auth_salt => node['wordpress']['salt']['auth'],
        :secure_auth_salt => node['wordpress']['salt']['secure_auth'],
        :logged_in_salt => node['wordpress']['salt']['logged_in'],
        :nonce_salt => node['wordpress']['salt']['nonce'],
        :lang => node['wordpress']['languages']['lang'],
        :aws_key => node['wordpress']['aws']['key'],
        :aws_secret_key => node['wordpress']['aws']['secret']
    )
    action :create
    user deploy[:user]
    group deploy[:group]
  end

  file "#{deploy[:deploy_to]}/current/.htaccess" do
    mode 00664
  end

  #Temporary until uploads are migrated fully to S3
  source_path = "https://s3.amazonaws.com/blog.blendtec.com/uploads.tar.gz"
  install_path = "#{deploy[:deploy_to]}/shared/wp-content/uploads.tar.gz"

  remote_file install_path do
    source source_path
    mode "0775"
    not_if { ::File.exists?(install_path) }
  end

  bash "extract-uploads-archive" do
    cwd "#{deploy[:deploy_to]}/shared/wp-content/"
    code <<-EOF
    tar -jxvf uploads.tar.gz
    EOF
    not_if { ::File.exists?(install_path) }
  end

  directory "#{deploy[:deploy_to]}/shared/wp-content" do
    mode 00775
    recursive true
  end
end
