# test for https://github.com/OpenVoxProject/openvox-agent/issues/66
test_name 'Warning about implementatin during puppet lookup' do
  require 'puppet/acceptance/puppet_type_test_tools.rb'
  extend Puppet::Acceptance::PuppetTypeTestTools

# bastelfreak: I've no idea what those tags do, I copied them from lookup/v4_hieradata_with_v5_configs.rb
tag 'audit:high',
    'audit:acceptance',
    'audit:refactor',  # Master is not needed for this test. Refactor
                       # to use puppet apply with a local module tree.

  app_type        = File.basename(__FILE__, '.*')
  tmp_environment = mk_tmp_environment_with_teardown(master, app_type)
  fq_tmp_environmentpath  = "#{environmentpath}/#{tmp_environment}"

  confdir = puppet_config(master, 'confdir', section: 'master')
  hiera_conf_backup = master.tmpfile('66-hiera-yaml')

  step "backup global hiera.yaml" do
    on(master, "cp -a #{confdir}/hiera.yaml #{hiera_conf_backup}", :acceptable_exit_codes => [0,1])
  end

  teardown do
    step "restore global hiera.yaml" do
      on(master, "mv #{hiera_conf_backup} #{confdir}/hiera.yaml", :acceptable_exit_codes => [0,1])
    end

    agents.each do |agent|
      on(agent, puppet('config print lastrunfile')) do |command_result|
        agent.rm_rf(command_result.stdout)
      end
    end
  end

  step "create global hiera.yaml and data" do
    create_remote_file(master, "#{confdir}/hiera.yaml", <<-HIERA)
---
version: 5
hierarchy:
  - name: common
    data_hash: yaml_data
    path: "common.yaml"
    HIERA
    on(master, "chmod 755 #{confdir}/hiera.yaml")
    create_remote_file(master, "#{confdir}/common.yaml", <<-YAML)
---
environment_key: environment_key-global_common_file
global_key: global_key-global_common_file
    YAML
  end

  step 'assert lookups using lookup subcommand' do
    on(master, puppet('lookup', 'environment_key'), :accept_all_exit_codes => true) do |result|
      assert_match(/Warning: The node parameter 'implementation' for node '.*' was already set to 'openvox'. It could not be set to 'openvox'/, result.stderr)
    end
  end
end
