test_name 'C100567: puppet apply of module should translate messages' do
  confine :except, :platform => /^solaris/ # translation not supported

  tag 'audit:medium',
      'audit:acceptance'

  skip_test('i18n test module uses deprecated function; update module to resume testing.')
  # function validate_absolute_path used https://github.com/eputnam/eputnam-i18ndemo/blob/621d06d/manifests/init.pp#L15

  require 'puppet/acceptance/temp_file_utils'
  extend Puppet::Acceptance::TempFileUtils

  require 'puppet/acceptance/i18n_utils'
  extend Puppet::Acceptance::I18nUtils

  require 'puppet/acceptance/i18ndemo_utils'
  extend Puppet::Acceptance::I18nDemoUtils

  language = 'ja_JP'

  agents.each do |agent|
    skip_test('on windows this test only works on a machine with a japanese code page set') if agent['platform'] =~ /windows/ && agent['locale'] != 'ja'

    # REMIND - It was noted that skipping tests on certain platforms sometimes causes
    # beaker to mark the test as a failed even if the test succeeds on other targets. 
    # Hence we just print a message and skip w/o telling beaker about it.
    if on(agent, facter("fips_enabled")).stdout =~ /true/
      puts "Module build, loading and installing is not supported on fips enabled platforms"
      next
    end

    agent_language = enable_locale_language(agent, language)
    skip_test("test machine is missing #{agent_language} locale. Skipping") if agent_language.nil?
    shell_env_language = { 'LANGUAGE' => agent_language, 'LANG' => agent_language }

    type_path = agent.tmpdir('provider')
    step 'install a i18ndemo module' do
      install_i18n_demo_module(agent)
    end

    disable_i18n_default_agent = agent.puppet['disable_i18n']
    teardown do
      on(agent, puppet("config set disable_i18n #{ disable_i18n_default_agent }"))
      uninstall_i18n_demo_module(agent)
      on(agent, "rm -rf '#{type_path}'")
    end

    step 'enable i18n' do
      on(agent, puppet("config set disable_i18n false"))
    end

    step "Run puppet apply of a module with language #{agent_language} and verify the translations" do
      step 'verify custom fact translations' do
        on(agent, puppet("apply -e \"class { 'i18ndemo': filename => '#{type_path}' }\"", 'ENV' => shell_env_language)) do |apply_result|
          assert_match(/.*\w+-i18ndemo fact: これは\w+-i18ndemoからのカスタムファクトからのレイズです/, apply_result.stderr, 'missing translation for raise from ruby fact')
        end
      end unless agent['platform'] =~ /ubuntu-16.04/ # Condition to be removed after FACT-2799 gets resolved

      step 'verify custom translations' do
        on(agent, puppet("apply -e \"i18ndemo_type { 'hello': }\"", 'ENV' => shell_env_language), :acceptable_exit_codes => 1) do |apply_result|
          assert_match(/Warning:.*\w+-i18ndemo type: 良い値/, apply_result.stderr, 'missing warning from custom type')
        end

        on(agent, puppet("apply -e \"i18ndemo_type { '12345': }\"", 'ENV' => shell_env_language), :acceptable_exit_codes => 1) do |apply_result|
          assert_match(/Error: .* \w+-i18ndemo type: 値は有12345効な値ではありません/, apply_result.stderr, 'missing error from invalid value for custom type param')
        end
      end

      step 'verify custom provider translation' do
        on(agent, puppet("apply -e \"i18ndemo_type { 'hello': ensure => present, dir => '#{type_path}', }\"", 'ENV' => shell_env_language)) do |apply_result|
          assert_match(/Warning:.*\w+-i18ndemo provider: i18ndemo_typeは存在しますか/, apply_result.stderr, 'missing translated provider message')
        end
      end

      step 'verify function string translation' do
        on(agent, puppet("apply -e \"notify { 'happy': message => happyfuntime('happy') }\"", 'ENV' => shell_env_language)) do |apply_result|
          assert_match(/Notice: --\*\w+-i18ndemo function: それは楽しい時間です\*--/, apply_result.stdout, 'missing translated notice message')
        end
      end
    end
  end
end
