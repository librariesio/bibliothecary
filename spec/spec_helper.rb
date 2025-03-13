# frozen_string_literal: true

require "simplecov"
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "bibliothecary"

require_relative "shared_examples/cyclonedx"
require_relative "shared_examples/dependencies_csv"

require "super_diff/rspec"

def fixture_path(name)
  "spec/fixtures/#{name}"
end

def load_fixture(name)
  File.read(fixture_path(name))
end

RSpec.configure do |config|
  config.after(:each) do
    Bibliothecary.reset
  end
end

require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)

require "pry"
