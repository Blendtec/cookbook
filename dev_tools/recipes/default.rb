#checkout Arcanist
git "/home/vagrant/arcanist" do
  user 'vagrant'
  group 'vagrant'
  repository 'https://github.com/facebook/arcanist.git'
  reference "master"
  action :sync
end

#checkout LibPHUtil
git "/home/vagrant/libphutil" do
  user 'vagrant'
  group 'vagrant'
  repository 'https://github.com/facebook/libphutil.git'
  reference "master"
  action :sync
end

#Copy CakePhpTestEngine into Arc
template "/home/vagrant/arcanist/src/unit/engine/CakePhpTestEngine.php" do
  source 'CakePhpTestEngine.php.erb'
  group 'vagrant'
  owner 'vagrant'
  only_if do
    File.directory?("/home/vagrant/arcanist")
  end
end

log "running /home/vagrant/libphutil/scripts/build_xhpast.sh" do
  level :debug
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

#Add arcanist to path
script 'arc_path' do
  interpreter 'bash'
  user 'vagrant'
  cwd '/home/vagrant/'
  code <<-EOH
    echo "PATH=\"$PATH:/home/vagrant/arcanist/bin/\"" >> .profile
  EOH
end

#Install PHPUnit
script 'phpunit' do
  interpreter 'bash'
  user 'root'
  cwd '/home/vagrant/'
  code <<-EOH
    pear channel-discover pear.phpunit.de
    pear install phpunit/PHPUnit
  EOH
end

#Install CakePHP code sniffer
script 'cakephp_codesniffer' do
  interpreter 'bash'
  user 'root'
  cwd '/home/vagrant/'
  code <<-EOH
    pear channel-discover pear.cakephp.org
    pear install cakephp/CakePHP_CodeSniffer
  EOH
end