test_name 'Ensure locales are present' do
  agents.each do |agent|
    package = case agent.platform
              when /^el/ then 'glibc-all-langpacks'
              when /debian/ then 'locales-all'
              else nil
              end
    on(agent, puppet_resource('package', package, 'ensure=present')) if !package.nil?
  end
end
