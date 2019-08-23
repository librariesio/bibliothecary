# Bibliothecary

Dependency manifest parsing library for https://libraries.io

[![Build Status](https://travis-ci.org/librariesio/bibliothecary.svg?branch=master)](https://travis-ci.org/librariesio/bibliothecary)
[![license](https://img.shields.io/github/license/librariesio/bibliothecary.svg)](https://github.com/librariesio/bibliothecary/blob/master/LICENSE.txt)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bibliothecary'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bibliothecary

## Usage

Identify package manager manifests from a list of files:

```ruby
Bibliothecary.identify_manifests(['package.json', 'README.md', 'index.js']) #=> 'package.json'
```

Parse a manifest file for it's dependencies:

```ruby
Bibliothecary.analyse_file 'bower.json', File.open('bower.json').read
```

Search a directory for manifest files and parse the contents:

```ruby
Bibliothecary.analyse('./')
```

There are a number of parsers that rely on web services to parse the file formats, those urls can be configured like so:

```ruby
Bibliothecary.configure do |config|
  config.carthage_parser_host = 'http://my-carthage-parsing-service.com'
end
```

All available config options are in: https://github.com/librariesio/bibliothecary/blob/master/lib/bibliothecary/configuration.rb

## Supported package manager file formats

- Hackage
  - \*.cabal
- npm
  - package.json
  - package-lock.json
  - npm-shrinkwrap.json
  - yarn.lock
- Maven
  - pom.xml
  - ivy.xml
  - build.gradle
- RubyGems
  - Gemfile
  - Gemfile.lock
  - gems.rb
  - gems.locked
  - *.gemspec
- Packagist
  - composer.json
  - composer.lock
- PyPi
  - setup.py
  - req*.txt
  - req*.pip
  - requirements/*.txt
  - requirements/*.pip
  - Pipfile
  - Pipfile.lock
- Nuget
  - packages.config
  - Project.json
  - Project.lock.json
  - *.nuspec
  - paket.lock
  - *.csproj
- Bower
  - bower.json
- CPAN
  - META.json
  - META.yml
- CocoaPods
  - Podfile
  - Podfile.lock
  - *.podspec
- Anaconda
  - environment.yml
  - environment.yaml
- Clojars
  - project.clj
- Meteor
  - versions.json
- CRAN
  - DESCRIPTION
- Cargo
  - Cargo.toml
  - Cargo.lock
- Hex
  - mix.exs
  - mix.lock
- Swift
  - Package.swift
- Pub
  - pubspec.yaml
  - pubspec.lock
- Carthage
  - Cartfile
  - Cartfile.private
  - Cartfile.resolved
- Dub
  - dub.json
  - dub.sdl
- Julia
  - REQUIRE
- Shards
  - shard.yml
  - shard.lock
- Go
  - glide.yaml
  - glide.lock
  - Godeps
  - Godeps/Godeps.json
  - vendor/manifest
  - vendor/vendor.json
  - Gopkg.toml
  - Gopkg.lock
  - go.mod
  - go.sum
- Elm
  - elm-package.json
  - elm_dependencies.json
  - elm-stuff/exact-dependencies.json
- Haxelib
  - haxelib.json
- Hackage
  - *.cabal
  - cabal.config

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/librariesio/bibliothecary. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.
