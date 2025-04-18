# This will regenerate SSL fixtures.  It does not cover all fixtures yet.
# Run it from the spec/fixtures/ssl directory.

require_relative '../../lib/puppet_spec/ssl'

def make_subject(name)
  OpenSSL::X509::Name.new([["CN", name]])
end

def write_pem(content, path)
  File.write(path, "#{content.to_text}\n#{content.to_pem}")
  puts "Wrote #{content.class} to #{path}"
end

def read_pem(path, type)
  text = File.read(path, encoding: 'UTF-8')
  type.new(text)
end

def load_or_generate_key(path, size = nil)
  if File.exist?(path)
    puts "Loading RSA key from #{path}"
    read_pem(path, OpenSSL::PKey::RSA)
  else
    puts "Generating new RSA key"
    PuppetSpec::SSL.create_private_key(size)
  end
end

def load_or_generate_csr(path, key = nil, name = nil)
  if File.exist?(path)
    puts "Loading CSR from #{path}"
    return read_pem(path, OpenSSL::X509::Request)
  end

  raise "Must pass key and name parameters if CSR needs to be generated" unless key && name

  csr = PuppetSpec::SSL.create_csr(key, "CN=#{name}")
  puts "Generating new CSR for #{csr.subject}"
  write_pem(csr, 'request.pem')
end

# Load or generate request-key.pem and request.pem
req_key = load_or_generate_key('request-key.pem')
req_csr = load_or_generate_csr('request.pem', req_key, 'pending')

# Swap associated public key in request.pem to create a tampered CSR:
unless File.exist?('tampered-csr.pem')
  tampered_csr = load_or_generate_csr('request.pem')
  tampered_csr.subject = make_subject('signed')
  write_pem(tampered_csr, 'tampered-csr.pem')
end

puts "NOTE: Most fixtures are not yet able to be generated with this script"
