$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require 'beaker-puppet'
require 'mkmf'

module Beaker
  module DSL
    module Helpers
      module PuppetAcceptance
        # A sad little abstraction around service/systemctl to handle
        # os differences for edge cases not suited to puppet resource
        # service calls.
        def service(host, action, service_name, acceptable_exit_codes: [0])
          if find_executable('systemctl')
            command = Command.new("systemctl #{action} #{service_name}")
          elsif find_executable('service')
            command = Command.new("service #{service_name} #{action}")
          else
            raise "Neither systemctl nor service found on #{host.name}"
          end

          host.exec(command, acceptable_exit_codes: acceptable_exit_codes)
        end

        # Override beaker-puppet BeakerPuppet::Helpers::PuppetHelpers#bounce_service
        # to allow for systems that only have systemctl now (el9+, etc.)
        #
        # Ostensibly we should fork beaker-puppet...I'm just not quite ready
        # to touch that yet...
        #
        # Restarts the named puppet service
        #
        # @param [Host] host Host the service runs on
        # @param [String] service Name of the service to restart
        # @param [Fixnum] curl_retries Number of seconds to wait for the restart to complete before failing
        # @param [Fixnum] port Port to check status at
        #
        # @return [Result] Result of last status check
        # @!visibility private
        def bounce_service(host, service, curl_retries = nil, port = nil)
          curl_retries = 120 if curl_retries.nil?
          port = options[:puppetserver_port] if port.nil?
          result = service(host, :reload, service, acceptable_exit_codes: [0, 1, 3])
          return result if result.exit_code == 0

          host.exec puppet_resource('service', service, 'ensure=stopped')
          host.exec puppet_resource('service', service, 'ensure=running')

          curl_with_retries(" #{service} ", host, "https://localhost:#{port}", [35, 60], curl_retries)
        end
      end
    end
  end
end


# Register the DSL extension
Beaker::DSL.register(Beaker::DSL::Helpers::PuppetAcceptance)
