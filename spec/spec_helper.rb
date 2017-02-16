require "simplecov"
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bibliothecary'

def fixture_path(name)
  "spec/fixtures/#{name}"
end
