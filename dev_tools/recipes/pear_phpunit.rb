#Install PHPUnit
script 'phpunit' do
  interpreter 'bash'
  user 'root'
  cwd '/home/vagrant/'
  code <<-EOH
    pear config-set auto_discover 1
    pear install pear.phpunit.de/PHPUnit
  EOH
end