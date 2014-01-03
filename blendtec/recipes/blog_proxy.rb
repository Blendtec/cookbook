node[:deploy].each do |app_name, deploy|

  application_name = params[:name]

  #Add proxypass entry for blog
  ruby_block "add proxypass blog entry" do
    block do
      rc = Chef::Util::FileEdit.new("#{node[:apache][:dir]}/sites-available/#{application_name}.conf")
      proxy_line = "YAY"
      rc.insert_line_after_match(/^.*\DocumentRoot\b.*$/, proxy_line)
      rc.write_file
    end
    only_if do
      ::File.exists?("#{node[:apache][:dir]}/sites-available/#{application_name}.conf")
    end
  end
end