require "simplecov"
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "bibliothecary"

require_relative "./shared_examples/cyclonedx.rb"
require_relative "./shared_examples/dependencies_csv.rb"

def fixture_path(name)
  "spec/fixtures/#{name}"
end

def load_fixture(name)
  File.open(fixture_path(name)).read
end

RSpec.configure do |config|
  config.after(:each) do
    Bibliothecary.reset
  end
end

require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)

require "pry"
