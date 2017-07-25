require 'spec_helper'

describe Bibliothecary do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  it 'lists supported package managers' do
    expect(described_class.package_managers).to eq([
          Bibliothecary::Parsers::Bower,
          Bibliothecary::Parsers::Cargo,
          Bibliothecary::Parsers::Carthage,
          Bibliothecary::Parsers::Clojars,
          Bibliothecary::Parsers::CocoaPods,
          Bibliothecary::Parsers::CPAN,
          Bibliothecary::Parsers::CRAN,
          Bibliothecary::Parsers::Dub,
          Bibliothecary::Parsers::Elm,
          Bibliothecary::Parsers::Go,
          Bibliothecary::Parsers::Haxelib,
          Bibliothecary::Parsers::Hex,
          Bibliothecary::Parsers::Julia,
          Bibliothecary::Parsers::Maven,
          Bibliothecary::Parsers::Meteor,
          Bibliothecary::Parsers::NPM,
          Bibliothecary::Parsers::Nuget,
          Bibliothecary::Parsers::Packagist,
          Bibliothecary::Parsers::Pub,
          Bibliothecary::Parsers::Pypi,
          Bibliothecary::Parsers::Rubygems,
          Bibliothecary::Parsers::Shard,
          Bibliothecary::Parsers::SwiftPM
        ])
  end

  it 'identifys manifests from a list of file paths' do
    expect(described_class.identify_manifests(['package.json', 'README.md', 'index.js'])).to eq([
      'package.json'
      ])
  end

  it 'identifys manifests from a list of file paths except ignored ones' do
    expect(described_class.identify_manifests(['package.json', 'bower_components/package.json', 'README.md', 'index.js'])).to eq([
      'package.json'
      ])
  end

  it 'analyses contents of a file' do
    expect(described_class.analyse_file('bower.json', load_fixture('bower.json'))).to eq([{
      :platform=>"bower",
      :path=>"bower.json",
      :dependencies=>[
        {:name=>"jquery", :requirement=>">= 1.9.1", :type=>"runtime"}
      ],
      :kind => 'manifest'
    }])
  end

  it 'ignores certain files' do
    expect(described_class.ignored_files_regex).to eq(".git|node_modules|bower_components|spec/fixtures|vendor/bundle|dist")
  end

  it 'searches a folder for manifests and parses them' do
    expect(described_class.analyse('./')).to eq(
      [{:platform=>"rubygems",
        :path=>"Gemfile",
        :dependencies=>
         [{:name=>"simplecov", :requirement=>">= 0", :type=>:development},
          {:name=>"codeclimate-test-reporter",
           :requirement=>"~> 1.0.0",
           :type=>:development}],
         :kind => 'manifest'},
       {:platform=>"rubygems",
        :path=>"Gemfile.lock",
        :dependencies=>
         [{:name=>"bibliothecary", :requirement=>"5.4.0", :type=>"runtime"},
          {:name=>"citrus", :requirement=>"3.0.2", :type=>"runtime"},
          {:name=>"codeclimate-test-reporter",
           :requirement=>"1.0.8",
           :type=>"runtime"},
          {:name=>"deb_control", :requirement=>"0.0.1", :type=>"runtime"},
          {:name=>"diff-lcs", :requirement=>"1.3", :type=>"runtime"},
          {:name=>"docile", :requirement=>"1.1.5", :type=>"runtime"},
          {:name=>"ethon", :requirement=>"0.10.1", :type=>"runtime"},
          {:name=>"ffi", :requirement=>"1.9.18", :type=>"runtime"},
          {:name=>"json", :requirement=>"2.1.0", :type=>"runtime"},
          {:name=>"librariesio-gem-parser", :requirement=>"1.0.0", :type=>"runtime"},
          {:name=>"ox", :requirement=>"2.5.0", :type=>"runtime"},
          {:name=>"rake", :requirement=>"12.0.0", :type=>"runtime"},
          {:name=>"rspec", :requirement=>"3.6.0", :type=>"runtime"},
          {:name=>"rspec-core", :requirement=>"3.6.0", :type=>"runtime"},
          {:name=>"rspec-expectations", :requirement=>"3.6.0", :type=>"runtime"},
          {:name=>"rspec-mocks", :requirement=>"3.6.0", :type=>"runtime"},
          {:name=>"rspec-support", :requirement=>"3.6.0", :type=>"runtime"},
          {:name=>"sdl4r", :requirement=>"0.9.11", :type=>"runtime"},
          {:name=>"simplecov", :requirement=>"0.13.0", :type=>"runtime"},
          {:name=>"simplecov-html", :requirement=>"0.10.1", :type=>"runtime"},
          {:name=>"toml-rb", :requirement=>"1.0.0", :type=>"runtime"},
          {:name=>"typhoeus", :requirement=>"1.1.2", :type=>"runtime"}],
        :kind => 'lockfile'},
       {:platform=>"rubygems",
        :path=>"bibliothecary.gemspec",
        :dependencies=>
         [{:name=>"toml-rb", :requirement=>"~> 1.0", :type=>:runtime},
          {:name=>"librariesio-gem-parser", :requirement=>">= 0", :type=>:runtime},
          {:name=>"ox", :requirement=>">= 0", :type=>:runtime},
          {:name=>"typhoeus", :requirement=>">= 0", :type=>:runtime},
          {:name=>"deb_control", :requirement=>">= 0", :type=>:runtime},
          {:name=>"sdl4r", :requirement=>">= 0", :type=>:runtime},
          {:name=>"bundler", :requirement=>"~> 1.11", :type=>:development},
          {:name=>"rake", :requirement=>"~> 12.0", :type=>:development},
          {:name=>"rspec", :requirement=>"~> 3.0", :type=>:development}],
        :kind => 'manifest'}])
  end
end
