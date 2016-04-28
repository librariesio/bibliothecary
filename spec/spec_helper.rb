$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bibliothecary'

def load_fixture(name)
  path = File.expand_path("../fixtures/#{name}", __FILE__)
  File.open(path).read
end
