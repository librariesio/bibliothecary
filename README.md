# Bibliothecary

Dependency manifest parsing library for https://libraries.io

[![Build Status](https://travis-ci.org/librariesio/bibliothecary.svg?branch=master)](https://travis-ci.org/librariesio/bibliothecary)
[![license](https://img.shields.io/github/license/librariesio/bibliothecary.svg)](https://github.com/librariesio/bibliothecary/blob/master/LICENSE.txt)

## Installation

Requires Ruby 3.0 or above.

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

- npm
  - package.json
  - package-lock.json
  - npm-shrinkwrap.json
  - yarn.lock
- Maven
  - pom.xml
  - ivy.xml
  - build.gradle
  - gradle-dependencies-q.txt
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
  - pyproject.toml
  - poetry.lock
- Nuget
  - packages.config
  - Project.json
  - Project.lock.json
  - *.nuspec
  - paket.lock
  - *.csproj
  - project.assets.json
- CycloneDX
  - XML as cyclonedx.xml
  - JSON as cyclonedx.json
  - Note that CycloneDX manifests can contain information on multiple
    package manager's packages!
- SPDX
  - tag:value as *.spdx
  - JSON as *.spdx.json
  - Note that SPDX manifests can contain information on multiple
    package manager's packages!
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
  - go-resolved-dependencies.json
- Elm
  - elm-package.json
  - elm_dependencies.json
  - elm-stuff/exact-dependencies.json
- Haxelib
  - haxelib.json
- Hackage
  - \*.cabal
  - cabal.config

### `full_sbom` Option

By default, CycloneDX and SPDX sboms are just containers for dependencies from actual platforms, so the analysis results can contain results from multiple platforms, e.g.:

```
[
  { platform: "npm", path: "sbom.spdx.json", project_name: nil, dependencies: [...], kind: "lockfile", success: true },
  { platform: "rubygems", path: "sbom.spdx.json", project_name: nil, dependencies: [...], kind: "lockfile", success: true },
  ...
]
```

But if you need **all** dependencies in an SBOM (not just the ones with first-class support by Bibliothecary), you can use the `full_sbom: true` option, e.g.:

``` ruby
runner = Bibliothecary::Runner.new(Bibliothecary::Configuration.new, parser_options: { full_sbom: true })
runner.analyze_file("sbom.spdx.json", File.read("sbom.spdx.json"))
```

Then Bibliothecary will return a single analysis result per CycloneDX/SPDX file for a fake "sbom" platform name, containing all dependencies found, e.g.

```
[
  { platform: "sbom", path: "sbom.spdx.json", project_name: nil, dependencies: [... deps for npm, rubygems, deb, etc ...], kind: "lockfile", success: true },
  ...
]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version:
* in `CHANGELOG.md`, move the changes under `"Unreleased"` into a new section with your version number
* bump and commit the version number in `version.rb` in the `main` branch
* and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/librariesio/bibliothecary. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.
