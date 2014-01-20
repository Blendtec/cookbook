#checkout Arcanist
git "/opt/arcanist" do
  repository 'https://github.com/facebook/arcanist.git'
  reference "master"
  action :sync
end

#checkout LibPHUtil
git "/opt/libphutil" do
  repository 'https://github.com/facebook/libphutil.git'
  reference "master"
  action :sync
end

#Copy CakePhpTestEngine into Arc
template "/opt/dev_tools/src/unit/engine/CakePhpTestEngine.php" do
  source 'CakePhpTestEngine.php.erb'
  group 'vagrant'
  owner 'vagrant'
  only_if do
    File.directory?("/opt/dev_tools")
  end
end


#Add arcanist to path
script 'arc_path' do
  interpreter 'bash'
  user 'vagrant'
  cwd '/home/vagrant'
  code <<-EOH
    echo "PATH=\"$PATH:/opt/arcanist/bin/\"" >> .profile
  EOH
end

#Install phpunit
script 'phpunit' do
  interpreter 'bash'
  user 'root'
  cwd '/home/vagrant'
  code <<-EOH
    pear channel-discover pear.phpunit.de
    pear install phpunit/PHPUnit
  EOH
end

#Install CakePHP code sniffer
script 'cakephp_codesniffer' do
  interpreter 'bash'
  user 'root'
  cwd '/home/vagrant'
  code <<-EOH
    pear channel-discover pear.cakephp.org
    pear install cakephp/CakePHP_CodeSniffer
  EOH
end