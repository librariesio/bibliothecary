# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bibliothecary/version'

Gem::Specification.new do |spec|
  spec.name          = "bibliothecary"
  spec.version       = Bibliothecary::VERSION
  spec.authors       = ["Andrew Nesbitt"]
  spec.email         = ["andrewnez@gmail.com"]

  spec.summary       = "Find and parse manifests"
  spec.homepage      = "https://github.com/librariesio/bibliothecary"
  spec.license       = "AGPL-3.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "tomlrb", "~> 2.0"
  spec.add_dependency "librariesio-gem-parser"
  spec.add_dependency "ox", ">= 2.8.1"
  spec.add_dependency "typhoeus"
  spec.add_dependency "deb_control"
  spec.add_dependency "sdl4r"
  spec.add_dependency "commander"
  spec.add_dependency "strings-ansi" # NB this is also pegged to a git sha in Gemfile temporarily.  
  spec.add_dependency "strings"
  spec.add_dependency "packageurl-ruby"

  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rails"
end
