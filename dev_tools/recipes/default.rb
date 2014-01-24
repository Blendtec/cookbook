include_recipe 'dev_tools::libphutil'
include_recipe 'dev_tools::arcanist'
include_recipe 'dev_tools::pear_phpcs'
include_recipe 'dev_tools::pear_phpunit'

#Copy CakePhpTestEngine into Arc
template "/home/vagrant/arcanist/src/unit/engine/CakePhpTestEngine.php" do
  source 'CakePhpTestEngine.php.erb'
  group 'vagrant'
  owner 'vagrant'
  only_if do
    File.directory?("/home/vagrant/arcanist")
  end
end

#Build xh_past
script 'build_xhpast' do
  interpreter 'bash'
  cwd '/home/vagrant/libphutil/scripts/'
  code <<-EOH
    ./build_xhpast.sh
  EOH
  only_if do File.exists?("/home/vagrant/libphutil/scripts/build_xhpast.sh") end
end

#Index arc classes
script 'arc_liberate' do
  interpreter 'bash'
  cwd '/home/vagrant/arcanist'
  code <<-EOH
    ./bin/arc liberate
  EOH
end

