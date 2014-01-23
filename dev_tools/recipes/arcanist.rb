
include_recipe 'dev_tools::libphutil'

#checkout Arcanist
git "/home/vagrant/arcanist" do
  user 'vagrant'
  group 'vagrant'
  repository 'https://github.com/facebook/arcanist.git'
  reference "master"
  action :sync
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