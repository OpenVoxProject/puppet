# Ensures that the /root/.ssh/environment file is
# set up with a path that includes /opt/puppetlabs/bin.
# Normally this would be called as part of beaker-puppet
# install steps, but we are installing openvox packages outside
# of beaker-puppet, since it doesn't handle openvox.
test_name('configure root ssh environment path') do
  configure_type_defaults_on(agents)
end
