node[:deploy].each do |app_name, deploy|

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
    message "SETUP: generating database.php"
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
    message "SETUP: generating core.php"
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
    message "SETUP: creating tmp directory"
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
    recursive true
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

end
