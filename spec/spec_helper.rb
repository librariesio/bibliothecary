require "simplecov"
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bibliothecary'

def load_fixture(name)
  File.open("spec/fixtures/#{name}").read
end

RSpec.configure do |config|
  config.after(:each) do
    Bibliothecary.reset
  end
end

require 'vcr'
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.configure_rspec_metadata!
  c.hook_into :webmock
end
