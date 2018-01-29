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
