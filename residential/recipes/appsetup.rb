node[:deploy].each do |app_name, deploy|

  log "message" do
    message "APPSETUP: installing composer"
    level :info
  end

  script "install_composer" do
    interpreter "bash"
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
    curl -s https://getcomposer.org/installer | php
    php composer.phar install
    EOH
  end

  log "message" do
    message "APPSETUP: generating database.php"
    level :info
  end

  template "#{deploy[:deploy_to]}/current/app/Config/database.php" do
    source "database.php.erb"
    mode 0660
    group deploy[:group]

    if platform?("ubuntu")
      owner "www-data"
    elsif platform?("amazon")
      owner "apache"
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

  log "message" do
    message "APPSETUP: generating core.php"
    level :info
  end

  template "#{deploy[:deploy_to]}/current/app/Config/core.php" do
    source "core.php.erb"
    mode 0660
    group deploy[:group]

    if platform?("ubuntu")
      owner "www-data"
    elsif platform?("amazon")
      owner "apache"
    end

    only_if do
      File.directory?("#{deploy[:deploy_to]}/current/app/Config")
    end
  end


  log "message" do
    message "APPSETUP: changing permissions to cake"
    level :info
  end

  file "#{deploy[:deploy_to]}/current/lib/Cake/Console/cake" do
    if platform?("ubuntu")
      owner "www-data"
    elsif platform?("amazon")
      owner "apache"
    end
    group deploy[:group]
    mode 0755
    action :touch
  end

  log "message" do
    message "APPSETUP: creating tmp directory"
    level :info
  end

  directory "#{deploy[:deploy_to]}/current/app/tmp" do
    mode 0777
    group deploy[:group]
    if platform?("ubuntu")
      owner "www-data"
    elsif platform?("amazon")
      owner "apache"
    end
    action :create
  end

  log "message" do
    message "APPSETUP: creating tmp/cache directory"
    level :info
  end

  directory "#{deploy[:deploy_to]}/current/app/tmp/cache" do
    mode 0777
    group deploy[:group]
    if platform?("ubuntu")
      owner "www-data"
    elsif platform?("amazon")
      owner "apache"
    end
    action :create
  end

  log "message" do
    message "APPSETUP: creating tmp/cache/{models, persistent, views} directories"
    level :info
  end

  %w{models persistent views}.each do |dir|
    directory "#{deploy[:deploy_to]}/current/app/tmp/cache/#{dir}" do
      mode 00777
      group deploy[:group]
      if platform?("ubuntu")
        owner "www-data"
      elsif platform?("amazon")
        owner "apache"
      end
      action :create
      recursive true
    end
  end

  log "message" do
    message "APPSETUP: running migrations"
    level :info
  end

  Dir.foreach("#{deploy[:deploy_to]}/current/app/Plugin") do |item|
    next if item == '.' or item == '..'
    log "message" do
      message "APPSETUP: running migrations for #{item}"
      level :info
    end
    execute "cake migration" do
      cwd "#{deploy[:deploy_to]}/current/app"
      command "../lib/Cake/Console/cake"
      returns 1 #temporary
      action :run
    end
  end

end
