test_name 'Ensure the master is running'
skip_test 'not testing with puppetserver' unless @options['is_puppetserver']

on(master, puppet('resource', 'service', master['puppetservice'], 'ensure=running', 'enable=true'))
