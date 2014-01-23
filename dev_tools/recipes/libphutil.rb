#checkout LibPHUtil
git "/home/vagrant/libphutil" do
  user 'vagrant'
  group 'vagrant'
  repository 'https://github.com/facebook/libphutil.git'
  reference "master"
  action :sync
end