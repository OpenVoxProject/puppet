test_name 'Validate Sign Cert' do
  need_to_run = false
  hosts.each do |host|
    need_to_run ||= !host['use_existing_container']
  end
  skip_test 'No new hosts to create, skipping' unless need_to_run
  skip_test 'not testing with puppetserver' unless @options['is_puppetserver']
  hostname = on(master, 'facter hostname').stdout.strip
  fqdn = on(master, 'facter fqdn').stdout.strip

  step 'Ensure puppet is stopped'
  on(master, puppet('resource', 'service', master['puppetservice'], 'ensure=stopped'))

  step 'Clear SSL on all hosts'
  hosts.each do |host|
    ssldir = on(host, puppet('agent --configprint ssldir')).stdout.chomp
    # preserve permissions for master's ssldir so puppetserver can read it
    on(host, "rm -rf '#{ssldir}/'*")
  end

  step "Set 'server' setting"
  hosts.each do |host|
    on(host, puppet("config set server #{master.hostname} --section main"))
  end

  step 'Start puppetserver' do
    master_opts = {
      main: {
        dns_alt_names: "puppet,#{hostname},#{fqdn}",
        server: fqdn,
        autosign: true,
      },
    }

    on(master, 'puppetserver ca setup')
    with_puppet_running_on(master, master_opts) do
      step 'Agents: Run agent --test with autosigning enabled to get cert'
      on(agents, puppet('agent --test'), acceptable_exit_codes: [0, 2])
    end
  end
end
