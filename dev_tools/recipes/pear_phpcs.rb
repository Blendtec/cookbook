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