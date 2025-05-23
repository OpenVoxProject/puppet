# frozen_string_literal: true

require 'open3'
require 'rake'
require 'rubygems'
require 'rubygems/package_task'

RED = "\033[31m"
GREEN = "\033[32m"
RESET = "\033[0m"

def run_command(cmd, silent: true, print_command: false, report_status: false)
  puts "#{GREEN}Running #{cmd}#{RESET}" if print_command
  output = ''
  Open3.popen2e(cmd) do |_stdin, stdout_stderr, thread|
    stdout_stderr.each do |line|
      puts line unless silent
      output += line
    end
    exitcode = thread.value.exitstatus
    unless exitcode.zero?
      err = "#{RED}Command failed! Command: #{cmd}, Exit code: #{exitcode}"
      # Print details if we were running silent
      err += "\nOutput:\n#{output}" if silent
      err += RESET
      abort err
    end
    puts "#{GREEN}Command finished with status #{exitcode}#{RESET}" if report_status
  end
  output.chomp
end

Dir.glob(File.join('tasks/**/*.rake')).each { |file| load file }

### Puppetlabs stuff ###

if Rake.application.top_level_tasks.grep(/^(pl:|package:)/).any?
  begin
    require 'packaging'
    Pkg::Util::RakeUtils.load_packaging_tasks
  rescue LoadError => e
    puts "Error loading packaging rake tasks: #{e}"
  end
end

namespace :package do
  task :bootstrap do
    puts 'Bootstrap is no longer needed, using packaging-as-a-gem'
  end
  task :implode do
    puts 'Implode is no longer needed, using packaging-as-a-gem'
  end
end

task :default do
  sh %{rake -T}
end

namespace :pl_ci do
  desc 'Build puppet gems'
  task :gem_build, [:gemspec] do |t, args|
    args.with_defaults(gemspec: 'puppet.gemspec')
    stdout, stderr, status = Open3.capture3(<<~END)
      gem build #{args.gemspec} --platform x86-mingw32 && \
      gem build #{args.gemspec} --platform x64-mingw32 && \
      gem build #{args.gemspec} --platform universal-darwin && \
      gem build #{args.gemspec}
    END
    if !status.exitstatus.zero?
      puts "Error building #{args.gemspec}\n#{stdout} \n#{stderr}"
      exit(1)
    else
      puts stdout
    end
  end

  desc 'build the nightly puppet gems'
  task :nightly_gem_build do
    # this is taken from `rake package:nightly_gem`
    extended_dot_version = %x{git describe --tags --dirty --abbrev=7}.chomp.tr('-', '.')

    # we must create tempfile in the same directory as puppetg.gemspec, since
    # it uses __dir__ to determine which files to include
    require 'tempfile'
    Tempfile.create('gemspec', __dir__) do |dst|
      File.open('puppet.gemspec', 'r') do |src|
        src.readlines.each do |line|
          if line.match?(/version\s*=\s*['"][0-9.]+['"]/)
            line = "spec.version = '#{extended_dot_version}'"
          end
          dst.puts line
        end
      end
      dst.flush
      Rake::Task['pl_ci:gem_build'].invoke(dst.path)
    end
  end
end

task :spec do
  ENV["LOG_SPEC_ORDER"] = "true"
  sh %{rspec #{ENV['TEST'] || ENV['TESTS'] || ENV['SPEC'] || 'spec'}}
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop) do |task|
    # These make the rubocop experience maybe slightly less terrible
    task.options = ['--display-cop-names', '--display-style-guide', '--extra-details']
    # Use Rubocop's Github Actions formatter if possible
    task.formatters << 'github' if ENV['GITHUB_ACTIONS'] == 'true'
  end
rescue LoadError
  # the gem is only used on MRI Ruby
end

desc "verify that changed files are clean of Ruby warnings"
task(:warnings) do
  # This rake task looks at all files modified in this branch.
  commit_range = 'HEAD^..HEAD'
  ruby_files_ok = true
  puts "Checking modified files #{commit_range}"
  %x{git diff --diff-filter=ACM --name-only #{commit_range}}.each_line do |modified_file|
    modified_file.chomp!
    # Skip racc generated file as it can have many warnings that cannot be manually fixed
    next if modified_file.end_with?("pops/parser/eparser.rb")
    next if modified_file.start_with?('spec/fixtures/', 'acceptance/fixtures/') || File.extname(modified_file) != '.rb'
    puts modified_file

    stdout, stderr, _ = Open3.capture3("ruby -wc \"#{modified_file}\"")
    unless stderr.empty?
      ruby_files_ok = false
      puts stderr
    end
    puts stdout
  end
  raise "One or more ruby files contain warnings." unless ruby_files_ok
end

if Rake.application.top_level_tasks.grep(/^gettext:/).any?
  begin
    spec = Gem::Specification.find_by_name 'gettext-setup'
    load "#{spec.gem_dir}/lib/tasks/gettext.rake"
    GettextSetup.initialize(File.absolute_path('locales', File.dirname(__FILE__)))
  rescue LoadError
    abort("Run `bundle install --with documentation` to install the `gettext-setup` gem.")
  end
end
