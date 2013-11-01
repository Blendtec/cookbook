#
# Cookbook Name:: cakephp
# Recipe:: deploy
#

node[:deploy].each do |app_name, deploy|

  script "install_composer" do
    interpreter "bash"
    user 'root'
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
    curl -s https://getcomposer.org/installer | php
    php composer.phar install
    EOH
  end

  template "#{deploy[:deploy_to]}/current/app/Config/database.php" do
    source 'database.php.erb'
    mode 0440
    group deploy[:group]

    if platform?('ubuntu')
      owner 'www-data'
    elsif platform?('amazon')
      owner 'apache'
    end

    variables(
        :host =>     (deploy[:database][:host] rescue nil),
        :user =>     (deploy[:database][:username] rescue nil),
        :password => (deploy[:database][:password] rescue nil),
        :db =>       (deploy[:database][:database] rescue nil)
    )

    only_if do
      File.directory?("#{deploy[:deploy_to]}/current/app/Config")
    end
  end

  template "#{deploy[:deploy_to]}/current/app/Config/core.php" do
    source 'core.php.erb'
    mode 0440
    group deploy[:group]

    if platform?('ubuntu')
      owner 'www-data'
    elsif platform?('amazon')
      owner 'apache'
    end

    only_if do
      File.directory?("#{deploy[:deploy_to]}/current/app/Config")
    end
  end

  file "#{deploy[:deploy_to]}/current/lib/Cake/Console/cake" do
    if platform?('ubuntu')
      owner 'www-data'
    elsif platform?('amazon')
      owner 'apache'
    end
    group deploy[:group]
    mode 0550
    action :touch
  end

  directory "#{deploy[:deploy_to]}/current/app/tmp" do
    mode 0740
    group deploy[:group]
    if platform?('ubuntu')
      owner 'www-data'
    elsif platform?('amazon')
      owner 'apache'
    end
    action :create
  end

  directory "#{deploy[:deploy_to]}/current/app/tmp/cache" do
    mode 0740
    group deploy[:group]
    if platform?('ubuntu')
      owner 'www-data'
    elsif platform?('amazon')
      owner 'apache'
    end
    action :create
  end

  %w{models persistent views}.each do |dir|
    directory "#{deploy[:deploy_to]}/current/app/tmp/cache/#{dir}" do
      mode 0740
      group deploy[:group]
      if platform?('ubuntu')
        owner 'www-data'
      elsif platform?('amazon')
        owner 'apache'
      end
      action :create
      recursive true
    end
  end


  Dir.foreach("#{deploy[:deploy_to]}/current/app/Plugin") do |item|
    next if item == '.' or item == '..'
    execute 'cake migration' do
      cwd "#{deploy[:deploy_to]}/current/app"
      command "../lib/Cake/Console/cake Migrations.migration run all --plugin #{item}"
      if platform?('ubuntu')
        user 'www-data'
      elsif platform?('amazon')
        user 'apache'
      end
      action :run
      returns 0
    end

    log "message" do
      message "SEARCHING FOR #{deploy[:deploy_to]}/current/app/Plugin/#{item}/Config/Migration"
      level :info
    end
  end


  execute 'cake migration' do
    cwd "#{deploy[:deploy_to]}/current/app"
    command '../lib/Cake/Console/cake Migrations.migration run all'
    if platform?('ubuntu')
      user 'www-data'
    elsif platform?('amazon')
      user 'apache'
    end
    action :run
    returns 0

    log "message" do
      message "SEARCHING FOR #{deploy[:deploy_to]}/current/app/Config/Migration"
      level :info
    end
  end

end


